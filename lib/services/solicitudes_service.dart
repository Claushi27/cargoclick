import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cargoclick/services/notifications_service.dart';

class SolicitudesService {
  bool get _isBackendReady => Firebase.apps.isNotEmpty;
  final _noti = NotificationsService();

  Future<void> solicitarFlete({
    required String fleteId,
    required String choferId,
    required String clienteId,
    required Map<String, dynamic> fleteResumen,
    required Map<String, dynamic> choferResumen,
  }) async {
    if (!_isBackendReady) {
      throw StateError('Firebase no está configurado.');
    }
    final now = DateTime.now();
    final batch = FirebaseFirestore.instance.batch();
    final solDoc = FirebaseFirestore.instance
        .collection('solicitudes')
        .doc(fleteId)
        .collection('solicitantes')
        .doc(choferId);

    batch.set(solDoc, {
      'flete_id': fleteId,
      'chofer_id': choferId,
      'cliente_id': clienteId,
      'status': 'pending',
      'created_at': Timestamp.fromDate(now),
      'updated_at': Timestamp.fromDate(now),
      'flete_resumen': fleteResumen,
      'chofer_resumen': choferResumen,
    });

    await batch.commit();

    // Notificar al cliente
    await _noti.sendNotification(
      toUserId: clienteId,
      title: 'Nueva solicitud de flete',
      body: 'Un chofer solicitó el flete ${fleteResumen['numero_contenedor']}',
      data: {'flete_id': fleteId, 'chofer_id': choferId, 'type': 'solicitud_nueva'},
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getSolicitudesCliente(String clienteId) {
    if (!_isBackendReady) {
      return const Stream.empty();
    }
    // Consulta todas las subcolecciones solicitantes donde cliente_id == clienteId
    // Firestore no permite collectionGroup con filtro simple en subcampos, pero aquí usamos un collectionGroup
    return FirebaseFirestore.instance
        .collectionGroup('solicitantes')
        .where('cliente_id', isEqualTo: clienteId)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  Future<void> aprobarSolicitud({
    required String fleteId,
    required String choferId,
    required String clienteId,
  }) async {
    if (!_isBackendReady) {
      throw StateError('Firebase no está configurado.');
    }
    final now = DateTime.now();
    final db = FirebaseFirestore.instance;
    final solRef = db.collection('solicitudes').doc(fleteId).collection('solicitantes').doc(choferId);
    final fleteRef = db.collection('fletes').doc(fleteId);

    await db.runTransaction((tx) async {
      final solSnap = await tx.get(solRef);
      if (!solSnap.exists) {
        throw StateError('Solicitud no encontrada');
      }
      tx.update(solRef, {
        'status': 'approved',
        'updated_at': Timestamp.fromDate(now),
      });
      tx.update(fleteRef, {
        'estado': 'asignado',
        'transportista_asignado': choferId,
        'fecha_asignacion': Timestamp.fromDate(now),
        'updated_at': Timestamp.fromDate(now),
      });
    });

    // Notificar al chofer
    await _noti.sendNotification(
      toUserId: choferId,
      title: 'Solicitud aprobada',
      body: 'Tu solicitud fue aprobada. El flete fue asignado a tu cuenta.',
      data: {'flete_id': fleteId, 'type': 'solicitud_aprobada'},
    );
  }

  Future<void> rechazarSolicitud({
    required String fleteId,
    required String choferId,
  }) async {
    if (!_isBackendReady) {
      throw StateError('Firebase no está configurado.');
    }
    final now = DateTime.now();
    final solRef = FirebaseFirestore.instance
        .collection('solicitudes')
        .doc(fleteId)
        .collection('solicitantes')
        .doc(choferId);

    await solRef.update({
      'status': 'rejected',
      'updated_at': Timestamp.fromDate(now),
    });
  }
}
