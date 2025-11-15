import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cargoclick/models/usuario.dart';
import 'package:cargoclick/models/transportista.dart';
import 'package:cargoclick/services/notification_service.dart';

class AuthService {
  bool get _isBackendReady => Firebase.apps.isNotEmpty;

  User? get currentUser {
    if (!_isBackendReady) return null;
    return FirebaseAuth.instance.currentUser;
  }

  Stream<User?> get authStateChanges {
    if (!_isBackendReady) {
      // Provide a stream that immediately emits null and closes when backend is not ready
      return Stream<User?>.value(null);
    }
    return FirebaseAuth.instance.authStateChanges();
  }

  Future<Usuario?> getCurrentUsuario() async {
    if (!_isBackendReady) {
      throw StateError(
        'Firebase no está configurado. Abre el panel Firebase en Dreamflow y completa la configuración.',
      );
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    
    return Usuario.fromJson(doc.data()!);
  }

  Future<Usuario?> registrar({
    required String email,
    required String password,
    required String displayName,
    required String empresa,
    required String phoneNumber,
    required String tipoUsuario,
    String? codigoInvitacion, // Código de invitación del transportista
  }) async {
    try {
      if (!_isBackendReady) {
        throw StateError(
          'Firebase no está configurado. Abre el panel Firebase en Dreamflow y completa la configuración.',
        );
      }

      // Validar código de invitación si es chofer
      String? transportistaId;
      if (tipoUsuario == 'Chofer' && codigoInvitacion != null && codigoInvitacion.isNotEmpty) {
        // Buscar transportista con ese código
        final transportistasQuery = await FirebaseFirestore.instance
            .collection('transportistas')
            .where('codigo_invitacion', isEqualTo: codigoInvitacion)
            .limit(1)
            .get();

        if (transportistasQuery.docs.isEmpty) {
          throw Exception('Código de invitación inválido');
        }

        transportistaId = transportistasQuery.docs.first.id;
      }

      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Set basic profile on FirebaseAuth user
      final user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(displayName);
      }

      final now = DateTime.now();
      final usuario = Usuario(
        uid: userCredential.user!.uid,
        email: email,
        displayName: displayName,
        // Forzamos rol de chofer independientemente de lo que venga del UI
        tipoUsuario: 'Chofer',
        empresa: empresa,
        phoneNumber: phoneNumber,
        transportistaId: transportistaId,
        codigoInvitacion: codigoInvitacion,
        createdAt: now,
        updatedAt: now,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(usuario.uid)
          .set(usuario.toJson());
      
      return usuario;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw FirebaseException(
          plugin: e.plugin,
          code: e.code,
          message:
              'Permisos de Firestore insuficientes para crear el perfil. Actualiza las reglas para permitir que cada usuario cree/lea su documento en /users/{uid}.',
        );
      }
      rethrow;
    }
  }

  Future<Usuario?> login({
    required String email,
    required String password,
  }) async {
    try {
      if (!_isBackendReady) {
        throw StateError(
          'Firebase no está configurado. Abre el panel Firebase en Dreamflow y completa la configuración.',
        );
      }

      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Ensure user profile doc exists for legacy accounts
      await _ensureUserDocExists(credential.user);
      
      // Guardar token FCM del dispositivo
      if (credential.user != null) {
        try {
          final notificationService = NotificationService();
          await notificationService.saveTokenToFirestore(credential.user!.uid);
        } catch (e) {
          print('⚠️ Error guardando token FCM: $e');
          // No fallar el login si no se puede guardar el token
        }
      }
      
      return await getCurrentUsuario();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    if (!_isBackendReady) return;
    
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Remover token FCM antes de hacer logout
        final notificationService = NotificationService();
        await notificationService.removeTokenFromFirestore(user.uid);
      } catch (e) {
        print('⚠️ Error removiendo token FCM: $e');
      }
    }
    
    await FirebaseAuth.instance.signOut();
  }

  Future<void> _ensureUserDocExists(User? user) async {
    if (user == null) return;
    
    // Primero verificar si es transportista, si lo es NO crear documento en /users
    final transportistaDoc = await FirebaseFirestore.instance
        .collection('transportistas')
        .doc(user.uid)
        .get();
    
    if (transportistaDoc.exists) {
      print('✅ [_ensureUserDocExists] Usuario es transportista, no se crea doc en /users');
      return; // Es transportista, no crear en /users
    }
    
    // No es transportista, verificar si ya existe en /users
    final users = FirebaseFirestore.instance.collection('users');
    final docRef = users.doc(user.uid);
    final snapshot = await docRef.get();
    if (snapshot.exists) return;

    print('📝 [_ensureUserDocExists] Creando documento de usuario (Cliente/Chofer)...');

    final now = DateTime.now();
    final usuario = Usuario(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? user.email ?? 'Usuario',
      // Por defecto, cualquier usuario nuevo es Chofer a menos que se cree manualmente en BD como Cliente
      tipoUsuario: 'Chofer',
      empresa: '',
      phoneNumber: user.phoneNumber ?? '',
      createdAt: now,
      updatedAt: now,
    );

    try {
      await docRef.set(usuario.toJson());
    } on FirebaseException catch (e) {
      // Surface a friendly hint in case of rules blocking the write
      if (e.code == 'permission-denied') {
        // Best-effort: ignore but available for UI to catch if needed
        throw FirebaseException(
          plugin: e.plugin,
          code: e.code,
          message:
              'No se pudo crear el perfil en Firestore por permisos. Revisa las reglas para /users/{uid}.',
        );
      }
      rethrow;
    }
  }

  /// Genera un código único de 6 caracteres alfanuméricos para invitación
  String _generarCodigoInvitacion() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
    );
  }

  /// Registra un nuevo Transportista con código de invitación único
  Future<Transportista?> registrarTransportista({
    required String email,
    required String password,
    required String razonSocial,
    required String rutEmpresa,
    required String telefono,
  }) async {
    try {
      if (!_isBackendReady) {
        throw StateError(
          'Firebase no está configurado. Abre el panel Firebase en Dreamflow y completa la configuración.',
        );
      }

      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Set basic profile on FirebaseAuth user
      final user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(razonSocial);
      }

      final now = DateTime.now();
      final codigoInvitacion = _generarCodigoInvitacion();

      final transportista = Transportista(
        uid: userCredential.user!.uid,
        email: email,
        razonSocial: razonSocial,
        rutEmpresa: rutEmpresa,
        telefono: telefono,
        codigoInvitacion: codigoInvitacion,
        createdAt: now,
        updatedAt: now,
      );

      await FirebaseFirestore.instance
          .collection('transportistas')
          .doc(transportista.uid)
          .set(transportista.toJson());
      
      return transportista;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw FirebaseException(
          plugin: e.plugin,
          code: e.code,
          message:
              'Permisos de Firestore insuficientes para crear el perfil. Actualiza las reglas para permitir que cada transportista cree su documento en /transportistas/{uid}.',
        );
      }
      rethrow;
    }
  }

  /// Obtiene el transportista actual autenticado
  Future<Transportista?> getCurrentTransportista() async {
    if (!_isBackendReady) {
      throw StateError(
        'Firebase no está configurado. Abre el panel Firebase en Dreamflow y completa la configuración.',
      );
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance.collection('transportistas').doc(user.uid).get();
    if (!doc.exists) return null;
    
    return Transportista.fromJson(doc.data()!);
  }

  /// Actualiza la tarifa mínima del transportista
  Future<void> actualizarTarifaMinima(String transportistaId, double? tarifaMinima) async {
    if (!_isBackendReady) {
      throw StateError('Firebase no está configurado.');
    }

    await FirebaseFirestore.instance
        .collection('transportistas')
        .doc(transportistaId)
        .update({
          'tarifa_minima': tarifaMinima,
          'updated_at': Timestamp.now(),
        });
  }

  /// Actualiza el puerto preferido del transportista
  Future<void> actualizarPuertoPreferido(String transportistaId, String? puertoPreferido) async {
    if (!_isBackendReady) {
      throw StateError('Firebase no está configurado.');
    }

    await FirebaseFirestore.instance
        .collection('transportistas')
        .doc(transportistaId)
        .update({
          'puerto_preferido': puertoPreferido,
          'updated_at': Timestamp.now(),
        });
  }
}
