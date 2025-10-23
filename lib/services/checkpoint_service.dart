import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cargoclick/models/checkpoint.dart';
import 'package:cargoclick/services/notifications_service.dart';

class CheckpointService {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _notificationsService = NotificationsService();

  // Definición de los 5 checkpoints obligatorios
  static const checkpointTypes = [
    {
      'id': 'retiro_unidad',
      'titulo': '1. Retiro de Unidad',
      'descripcion': 'Foto del contenedor y sello de seguridad',
      'icon': 'local_shipping',
      'requiereFotos': 2,
    },
    {
      'id': 'ubicacion_gps',
      'titulo': '2. Ubicación GPS',
      'descripcion': 'Pantallazo del GPS en tiempo real',
      'icon': 'location_on',
      'requiereFotos': 1,
    },
    {
      'id': 'llegada_cliente',
      'titulo': '3. Llegada al Cliente',
      'descripcion': 'Foto del lugar y GPS con hora de llegada',
      'icon': 'place',
      'requiereFotos': 2,
    },
    {
      'id': 'salida_cliente',
      'titulo': '4. Salida del Cliente',
      'descripcion': 'Guía de despacho firmada con hora',
      'icon': 'exit_to_app',
      'requiereFotos': 1,
    },
    {
      'id': 'entrega_unidad_vacia',
      'titulo': '5. Entrega Unidad Vacía',
      'descripcion': 'Foto del Interchange',
      'icon': 'check_circle',
      'requiereFotos': 1,
    },
  ];

  /// Obtiene el estado de un checkpoint específico
  Stream<Checkpoint?> getCheckpoint(String fleteId, String tipo) {
    return _db
        .collection('fletes')
        .doc(fleteId)
        .collection('checkpoints')
        .doc(tipo)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return Checkpoint.fromJson(doc.data()!, docId: doc.id);
    });
  }

  /// Obtiene todos los checkpoints de un flete
  Stream<List<Checkpoint>> getCheckpoints(String fleteId) {
    return _db
        .collection('fletes')
        .doc(fleteId)
        .collection('checkpoints')
        .orderBy('created_at')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Checkpoint.fromJson(doc.data(), docId: doc.id))
            .toList());
  }

  /// Sube un checkpoint con sus fotos
  Future<void> subirCheckpoint({
    required String fleteId,
    required String choferId,
    required String tipo,
    required List<Uint8List> fotos,
    String? notas,
    Map<String, double>? ubicacion,
    String? gpsLink,
  }) async {
    final now = DateTime.now();

    // 1. Subir fotos a Storage
    final fotoUrls = <FotoCheckpoint>[];
    for (var i = 0; i < fotos.length; i++) {
      final timestamp = now.millisecondsSinceEpoch;
      final fileName = '${tipo}_${timestamp}_$i.jpg';
      final ref = _storage.ref('fletes/$fleteId/checkpoints/$tipo/$fileName');

      await ref.putData(
        fotos[i],
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final url = await ref.getDownloadURL();

      fotoUrls.add(FotoCheckpoint(
        url: url,
        storagePath: ref.fullPath,
        nombre: fileName,
        createdAt: now,
      ));
    }

    // 2. Guardar checkpoint en Firestore
    final checkpointData = {
      'tipo': tipo,
      'chofer_id': choferId,
      'timestamp': Timestamp.fromDate(now),
      'ubicacion': ubicacion,
      'fotos': fotoUrls.map((f) => f.toJson()).toList(),
      'notas': notas,
      'completado': true,
      'created_at': Timestamp.fromDate(now),
    };
    
    // Agregar GPS link si existe
    if (gpsLink != null && gpsLink.isNotEmpty) {
      checkpointData['gps_link'] = gpsLink;
    }

    await _db
        .collection('fletes')
        .doc(fleteId)
        .collection('checkpoints')
        .doc(tipo)
        .set(checkpointData);

    // 3. Verificar si se completaron todos los checkpoints
    final checkpointsSnapshot = await _db
        .collection('fletes')
        .doc(fleteId)
        .collection('checkpoints')
        .get();

    final completados = checkpointsSnapshot.docs.length;
    final total = checkpointTypes.length;

    // Si es el último checkpoint, marcar flete como completado
    if (completados == total) {
      await _db.collection('fletes').doc(fleteId).update({
        'estado': 'completado',
        'fecha_completado': Timestamp.fromDate(now),
        'updated_at': Timestamp.fromDate(now),
      });
    }

    // 4. Notificar al admin
    final fleteDoc = await _db.collection('fletes').doc(fleteId).get();
    final fleteData = fleteDoc.data();
    if (fleteData != null) {
      final clienteId = fleteData['cliente_id'] as String;
      final checkpointInfo =
          checkpointTypes.firstWhere((c) => c['id'] == tipo);

      await _notificationsService.sendNotification(
        toUserId: clienteId,
        title: completados == total
            ? '¡Flete completado!'
            : 'Checkpoint completado',
        body: completados == total
            ? 'Todos los checkpoints han sido completados'
            : 'Checkpoint: ${checkpointInfo['titulo']}',
        data: {
          'flete_id': fleteId,
          'checkpoint': tipo,
          'completado': completados.toString(),
          'total': total.toString(),
        },
      );
    }
  }

  /// Verifica si un checkpoint está completado
  Future<bool> isCheckpointCompletado(String fleteId, String tipo) async {
    final doc = await _db
        .collection('fletes')
        .doc(fleteId)
        .collection('checkpoints')
        .doc(tipo)
        .get();
    return doc.exists && (doc.data()?['completado'] == true);
  }

  /// Obtiene el progreso de checkpoints (completados / total)
  Future<Map<String, int>> getProgreso(String fleteId) async {
    final snapshot = await _db
        .collection('fletes')
        .doc(fleteId)
        .collection('checkpoints')
        .where('completado', isEqualTo: true)
        .get();

    return {
      'completados': snapshot.docs.length,
      'total': checkpointTypes.length,
    };
  }
}
