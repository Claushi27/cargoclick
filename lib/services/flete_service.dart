import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cargoclick/models/flete.dart';
import 'package:cargoclick/services/notifications_service.dart';

class FleteService {
  bool get _isBackendReady => Firebase.apps.isNotEmpty;
  final _noti = NotificationsService();

  Stream<List<Flete>> getFletesCliente(String clienteId) {
    if (!_isBackendReady) {
      return Stream<List<Flete>>.error(
        'Firebase no está configurado. Abre el panel Firebase en Dreamflow y completa la configuración.',
      );
    }
    return FirebaseFirestore.instance
        .collection('fletes')
        .where('cliente_id', isEqualTo: clienteId)
        .orderBy('fecha_publicacion', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Flete.fromJson(doc.data(), docId: doc.id))
            .toList());
  }

  Stream<List<Flete>> getFletesDisponibles() {
    if (!_isBackendReady) {
      return Stream<List<Flete>>.error(
        'Firebase no está configurado. Abre el panel Firebase en Dreamflow y completa la configuración.',
      );
    }
    return FirebaseFirestore.instance
        .collection('fletes')
        .where('estado', isEqualTo: 'disponible')
        .orderBy('fecha_publicacion', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Flete.fromJson(doc.data(), docId: doc.id))
            .toList());
  }

  Future<void> publicarFlete(Flete flete) async {
    if (!_isBackendReady) {
      throw StateError(
        'Firebase no está configurado. Abre el panel Firebase en Dreamflow y completa la configuración.',
      );
    }
    final now = DateTime.now();
    final fleteData = flete.copyWith(
      createdAt: now,
      updatedAt: now,
    );

    await FirebaseFirestore.instance.collection('fletes').add(fleteData.toJson());
  }

  Future<void> aceptarFlete(String fleteId, String transportistaId) async {
    if (!_isBackendReady) {
      throw StateError(
        'Firebase no está configurado. Abre el panel Firebase en Dreamflow y completa la configuración.',
      );
    }
    // Obtener datos mínimos para crear la solicitud y notificar al cliente
    final db = FirebaseFirestore.instance;
    final fleteDoc = await db.collection('fletes').doc(fleteId).get();
    if (!fleteDoc.exists) throw StateError('Flete no encontrado');
    final data = fleteDoc.data()!;
    final clienteId = data['cliente_id'] as String;

    // Chofer resumen se completa en el caller (UI) usualmente con nombre/email; si no, guardamos solo el id.
    final choferResumen = {
      'uid': transportistaId,
    };
    final fleteResumen = {
      'numero_contenedor': data['numero_contenedor'],
      'origen': data['origen'],
      'destino': data['destino'],
    };

    // Crea la solicitud en /solicitudes/{fleteId}/solicitantes/{choferId}
    final now = DateTime.now();
    await db
        .collection('solicitudes')
        .doc(fleteId)
        .collection('solicitantes')
        .doc(transportistaId)
        .set({
      'flete_id': fleteId,
      'chofer_id': transportistaId,
      'cliente_id': clienteId,
      'status': 'pending',
      'created_at': Timestamp.fromDate(now),
      'updated_at': Timestamp.fromDate(now),
      'flete_resumen': fleteResumen,
      'chofer_resumen': choferResumen,
    });

    // ✅ Actualizar estado del flete a "solicitado"
    await db.collection('fletes').doc(fleteId).update({
      'estado': 'solicitado',
      'updated_at': Timestamp.fromDate(now),
    });

    // Notificación al cliente
    await _noti.sendNotification(
      toUserId: clienteId,
      title: 'Chofer aceptó un flete',
      body: 'Se creó una solicitud para el flete ${fleteResumen['numero_contenedor']}',
      data: {'flete_id': fleteId, 'chofer_id': transportistaId, 'type': 'solicitud_nueva'},
    );
  }

  Stream<List<Flete>> getFletesAsignadosChofer(String choferId) {
    if (!_isBackendReady) {
      return const Stream.empty();
    }
    // Query simplificada para evitar necesitar índice compuesto
    // Solo filtramos por chofer, ordenamos en memoria
    return FirebaseFirestore.instance
        .collection('fletes')
        .where('transportista_asignado', isEqualTo: choferId)
        .snapshots()
        .map((snapshot) {
          final fletes = snapshot.docs
              .map((doc) => Flete.fromJson(doc.data(), docId: doc.id))
              .toList();
          
          // Filtrar por estados activos y ordenar por fecha en memoria
          fletes.retainWhere((f) => 
            f.estado == 'asignado' || 
            f.estado == 'en_proceso' || 
            f.estado == 'completado'
          );
          
          fletes.sort((a, b) {
            final dateA = a.fechaAsignacion ?? a.createdAt;
            final dateB = b.fechaAsignacion ?? b.createdAt;
            return dateB.compareTo(dateA); // Descendente
          });
          
          return fletes;
        });
  }
}
