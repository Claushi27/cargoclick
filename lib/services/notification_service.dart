import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notificacion.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Callbacks para navegación
  Function(String)? onNotificationTapped;

  // Inicializar
  Future<void> initialize() async {
    try {
      // 1. Pedir permisos
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Permisos de notificaciones concedidos');
      } else {
        print('⚠️ Permisos de notificaciones denegados');
      }

      // 2. Configurar notificaciones locales
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initSettings =
          InitializationSettings(android: androidSettings);

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );

      // 3. Crear canal de notificaciones
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'Notificaciones Importantes',
        description: 'Notificaciones de fletes y operaciones',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // 4. Escuchar notificaciones en foreground
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // 5. Manejar notificación que abrió la app
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      print('✅ NotificationService inicializado');
    } catch (e) {
      print('❌ Error inicializando NotificationService: $e');
    }
  }

  // Obtener token FCM del usuario
  Future<String?> getToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      print('❌ Error obteniendo token FCM: $e');
      return null;
    }
  }

  // Guardar token en Firestore
  Future<void> saveTokenToFirestore(String userId) async {
    try {
      String? token = await getToken();
      if (token != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcm_token': token,
          'fcm_updated_at': FieldValue.serverTimestamp(),
        });
        print('✅ Token FCM guardado para usuario $userId');
      }
    } catch (e) {
      print('❌ Error guardando token: $e');
    }
  }

  // Manejar notificación en foreground
  void _handleForegroundMessage(RemoteMessage message) {
    print('📩 Notificación recibida en foreground: ${message.notification?.title}');

    // Mostrar notificación local
    _showLocalNotification(
      title: message.notification?.title ?? 'Nueva notificación',
      body: message.notification?.body ?? '',
      payload: message.data['flete_id'],
    );
  }

  // Manejar notificación que abrió la app
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('🔔 App abierta desde notificación');
    final fleteId = message.data['flete_id'];
    if (fleteId != null && onNotificationTapped != null) {
      onNotificationTapped!(fleteId);
    }
  }

  // Mostrar notificación local
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'high_importance_channel',
      'Notificaciones Importantes',
      channelDescription: 'Notificaciones de fletes y operaciones',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // Cuando el usuario toca la notificación
  void _onNotificationResponse(NotificationResponse response) {
    if (response.payload != null) {
      print('🔔 Usuario tocó notificación, flete: ${response.payload}');
      if (onNotificationTapped != null) {
        onNotificationTapped!(response.payload!);
      }
    }
  }

  // ENVIAR NOTIFICACIÓN A USUARIO ESPECÍFICO
  Future<void> enviarNotificacion({
    required String userId,
    required String tipo,
    required String titulo,
    required String mensaje,
    String? fleteId,
  }) async {
    try {
      // 1. Guardar en Firestore (para historial)
      final notif = Notificacion(
        id: '',
        userId: userId,
        tipo: tipo,
        titulo: titulo,
        mensaje: mensaje,
        fleteId: fleteId,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('notificaciones').add(notif.toMap());

      // 2. Obtener token FCM del usuario
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final token = userDoc.data()?['fcm_token'] as String?;

      if (token == null) {
        print('⚠️ Usuario $userId no tiene token FCM registrado');
        return;
      }

      // 3. Por ahora solo guardamos en Firestore
      // El usuario verá la notificación cuando actualice la app
      // Para push real necesitaríamos Cloud Functions

      print('✅ Notificación creada para $userId: $titulo');
    } catch (e) {
      print('❌ Error enviando notificación: $e');
    }
  }

  // Marcar notificación como leída
  Future<void> marcarComoLeida(String notifId) async {
    try {
      await _firestore.collection('notificaciones').doc(notifId).update({
        'leida': true,
      });
    } catch (e) {
      print('❌ Error marcando notificación como leída: $e');
    }
  }

  // Marcar todas como leídas
  Future<void> marcarTodasComoLeidas(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notificaciones')
          .where('user_id', isEqualTo: userId)
          .where('leida', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'leida': true});
      }
      await batch.commit();

      print('✅ Todas las notificaciones marcadas como leídas');
    } catch (e) {
      print('❌ Error marcando todas como leídas: $e');
    }
  }

  // Obtener notificaciones del usuario
  Stream<List<Notificacion>> getNotificacionesStream(String userId) {
    return _firestore
        .collection('notificaciones')
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Notificacion.fromFirestore(doc)).toList());
  }

  // Contar notificaciones no leídas
  Stream<int> getNotificacionesNoLeidasCount(String userId) {
    return _firestore
        .collection('notificaciones')
        .where('user_id', isEqualTo: userId)
        .where('leida', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
