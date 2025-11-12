import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transportista.dart';
import '../models/usuario.dart';
import '../models/camion.dart';

class ValidationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Validar Transportista
  Future<void> validarTransportista(String transportistaId, String clienteId) async {
    try {
      await _firestore.collection('transportistas').doc(transportistaId).update({
        'is_validado_cliente': true,
        'cliente_validador_id': clienteId,
        'fecha_validacion': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al validar transportista: $e');
    }
  }

  /// Validar Chofer
  Future<void> validarChofer(String choferId, String clienteId) async {
    try {
      await _firestore.collection('users').doc(choferId).update({
        'is_validado_cliente': true,
        'cliente_validador_id': clienteId,
        'fecha_validacion': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al validar chofer: $e');
    }
  }

  /// Validar Camión
  Future<void> validarCamion(String camionId, String clienteId) async {
    try {
      await _firestore.collection('camiones').doc(camionId).update({
        'is_validado_cliente': true,
        'cliente_validador_id': clienteId,
        'fecha_validacion': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al validar camión: $e');
    }
  }

  /// Revocar validación de Transportista
  Future<void> revocarValidacionTransportista(String transportistaId) async {
    try {
      await _firestore.collection('transportistas').doc(transportistaId).update({
        'is_validado_cliente': false,
        'cliente_validador_id': FieldValue.delete(),
        'fecha_validacion': FieldValue.delete(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al revocar validación: $e');
    }
  }

  /// Revocar validación de Chofer
  Future<void> revocarValidacionChofer(String choferId) async {
    try {
      await _firestore.collection('users').doc(choferId).update({
        'is_validado_cliente': false,
        'cliente_validador_id': FieldValue.delete(),
        'fecha_validacion': FieldValue.delete(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al revocar validación: $e');
    }
  }

  /// Revocar validación de Camión
  Future<void> revocarValidacionCamion(String camionId) async {
    try {
      await _firestore.collection('camiones').doc(camionId).update({
        'is_validado_cliente': false,
        'cliente_validador_id': FieldValue.delete(),
        'fecha_validacion': FieldValue.delete(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al revocar validación: $e');
    }
  }

  /// Stream de Transportistas Pendientes de Validación
  Stream<List<Transportista>> getTransportistasPendientes() {
    return _firestore
        .collection('transportistas')
        .where('is_validado_cliente', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Transportista.fromJson(doc.data()))
            .toList());
  }

  /// Stream de Transportistas Validados
  Stream<List<Transportista>> getTransportistasValidados() {
    return _firestore
        .collection('transportistas')
        .where('is_validado_cliente', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Transportista.fromJson(doc.data()))
            .toList());
  }

  /// Stream de Choferes Pendientes de Validación
  Stream<List<Usuario>> getChoferesPendientes() {
    return _firestore
        .collection('users')
        .where('tipo_usuario', isEqualTo: 'Chofer')
        .where('is_validado_cliente', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Usuario.fromJson(doc.data()))
            .toList());
  }

  /// Stream de Choferes Validados
  Stream<List<Usuario>> getChoferesValidados() {
    return _firestore
        .collection('users')
        .where('tipo_usuario', isEqualTo: 'Chofer')
        .where('is_validado_cliente', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Usuario.fromJson(doc.data()))
            .toList());
  }

  /// Stream de Camiones Pendientes de Validación
  Stream<List<Camion>> getCamionesPendientes() {
    return _firestore
        .collection('camiones')
        .where('is_validado_cliente', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Camion.fromJson(doc.data(), doc.id))
            .toList());
  }

  /// Stream de Camiones Validados
  Stream<List<Camion>> getCamionesValidados() {
    return _firestore
        .collection('camiones')
        .where('is_validado_cliente', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Camion.fromJson(doc.data(), doc.id))
            .toList());
  }

  /// Obtener un Transportista por ID
  Future<Transportista?> getTransportista(String id) async {
    try {
      final doc = await _firestore.collection('transportistas').doc(id).get();
      if (doc.exists) {
        return Transportista.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener transportista: $e');
    }
  }

  /// Obtener un Chofer por ID
  Future<Usuario?> getChofer(String id) async {
    try {
      final doc = await _firestore.collection('users').doc(id).get();
      if (doc.exists) {
        return Usuario.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener chofer: $e');
    }
  }

  /// Obtener un Camión por ID
  Future<Camion?> getCamion(String id) async {
    try {
      final doc = await _firestore.collection('camiones').doc(id).get();
      if (doc.exists) {
        return Camion.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener camión: $e');
    }
  }
}
