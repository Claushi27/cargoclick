import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class NotificationsService {
  bool get _isBackendReady => Firebase.apps.isNotEmpty;

  Future<void> sendNotification({
    required String toUserId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (!_isBackendReady) return;
    final now = DateTime.now();
    await FirebaseFirestore.instance.collection('notificaciones').add({
      'to_user_id': toUserId,
      'title': title,
      'body': body,
      'data': data ?? {},
      'created_at': Timestamp.fromDate(now),
      'read': false,
    });
  }
}
