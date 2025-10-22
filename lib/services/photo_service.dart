import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cargoclick/services/notifications_service.dart';

class PhotoService {
  bool get _isBackendReady => Firebase.apps.isNotEmpty;
  final _noti = NotificationsService();

  Future<String> uploadFletePhoto({
    required String fleteId,
    required String choferId,
    required Uint8List bytes,
    String? contentType,
    String? nota,
  }) async {
    if (!_isBackendReady) {
      throw StateError('Firebase no está configurado.');
    }
    final now = DateTime.now();
    final fileName = '${now.millisecondsSinceEpoch}_$choferId.jpg';
    final ref = FirebaseStorage.instance.ref('fletes/$fleteId/fotos/$fileName');
    final metadata = SettableMetadata(contentType: contentType ?? 'image/jpeg');
    final task = await ref.putData(bytes, metadata);
    final url = await task.ref.getDownloadURL();

    // Guarda metadatos en subcolección de Firestore
    await FirebaseFirestore.instance
        .collection('fletes')
        .doc(fleteId)
        .collection('fotos')
        .add({
      'url': url,
      'chofer_id': choferId,
      if (nota != null && nota.isNotEmpty) 'nota': nota,
      'created_at': Timestamp.fromDate(now),
    });
    // Actualiza updated_at del flete
    final fleteRef = FirebaseFirestore.instance.collection('fletes').doc(fleteId);
    await fleteRef.update({
      'updated_at': Timestamp.fromDate(now),
    });

    // Notificar al cliente propietario del flete
    final fleteSnap = await fleteRef.get();
    final clienteId = (fleteSnap.data() ?? const {})['cliente_id'] as String?;
    if (clienteId != null && clienteId.isNotEmpty) {
      await _noti.sendNotification(
        toUserId: clienteId,
        title: 'Nueva foto subida',
        body: 'El chofer subió una foto del flete $fleteId',
        data: {'flete_id': fleteId, 'type': 'foto_subida'},
      );
    }

    return url;
  }
}
