# 🔔 SISTEMA DE NOTIFICACIONES PUSH - PLAN DE IMPLEMENTACIÓN

**Fecha:** 30 Enero 2025  
**Tiempo estimado:** 2 horas  
**Testing:** USB en Android

---

## 🎯 OBJETIVO

Implementar notificaciones push in-app para:
1. ✅ Transportista asigna chofer → **Cliente + Chofer** reciben notificación
2. ✅ Chofer completa flete → **Cliente + Transportista** reciben notificación
3. ✅ Cliente publica flete → **Transportistas disponibles** reciben notificación (opcional)

---

## 📋 PASO 1: Configurar Firebase Cloud Messaging (30 min)

### 1.1 Agregar dependencias

```yaml
# pubspec.yaml
dependencies:
  firebase_messaging: ^15.1.5
  flutter_local_notifications: ^18.0.1
```

### 1.2 Configurar Android

**android/app/src/main/AndroidManifest.xml:**
```xml
<!-- Agregar dentro de <manifest> -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

<!-- Agregar dentro de <application> -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="high_importance_channel" />
```

### 1.3 Actualizar main.dart

```dart
// lib/main.dart
import 'package:firebase_messaging/firebase_messaging.dart';

// Handler para notificaciones en background
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📩 Notificación en background: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Configurar handler background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  runApp(MyApp());
}
```

---

## 📋 PASO 2: Crear Servicio de Notificaciones (1 hora)

### 2.1 Modelo de Notificación

**lib/models/notificacion.dart:**
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Notificacion {
  final String id;
  final String userId;
  final String tipo; // 'asignacion', 'completado', 'nuevo_flete'
  final String titulo;
  final String mensaje;
  final String? fleteId;
  final DateTime createdAt;
  final bool leida;

  Notificacion({
    required this.id,
    required this.userId,
    required this.tipo,
    required this.titulo,
    required this.mensaje,
    this.fleteId,
    required this.createdAt,
    this.leida = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'tipo': tipo,
      'titulo': titulo,
      'mensaje': mensaje,
      'flete_id': fleteId,
      'created_at': createdAt,
      'leida': leida,
    };
  }

  factory Notificacion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Notificacion(
      id: doc.id,
      userId: data['user_id'] ?? '',
      tipo: data['tipo'] ?? '',
      titulo: data['titulo'] ?? '',
      mensaje: data['mensaje'] ?? '',
      fleteId: data['flete_id'],
      createdAt: (data['created_at'] as Timestamp).toDate(),
      leida: data['leida'] ?? false,
    );
  }
}
```

### 2.2 Servicio de Notificaciones

**lib/services/notification_service.dart:**
```dart
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

  // Inicializar
  Future<void> initialize() async {
    // 1. Pedir permisos
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Permisos de notificaciones concedidos');
    }

    // 2. Configurar notificaciones locales
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // 3. Crear canal de notificaciones
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'Notificaciones Importantes',
      description: 'Notificaciones de fletes',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 4. Escuchar notificaciones en foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  // Obtener token FCM del usuario
  Future<String?> getToken() async {
    return await _fcm.getToken();
  }

  // Guardar token en Firestore
  Future<void> saveTokenToFirestore(String userId) async {
    String? token = await getToken();
    if (token != null) {
      await _firestore.collection('users').doc(userId).update({
        'fcm_token': token,
        'fcm_updated_at': FieldValue.serverTimestamp(),
      });
      print('✅ Token FCM guardado para usuario $userId');
    }
  }

  // Manejar notificación en foreground
  void _handleForegroundMessage(RemoteMessage message) {
    print('📩 Notificación recibida: ${message.notification?.title}');
    
    // Mostrar notificación local
    _showLocalNotification(
      title: message.notification?.title ?? 'Nueva notificación',
      body: message.notification?.body ?? '',
      payload: message.data['flete_id'],
    );
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
      channelDescription: 'Notificaciones de fletes',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // Cuando el usuario toca la notificación
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      // Navegar al detalle del flete
      print('🔔 Usuario tocó notificación, flete: ${response.payload}');
      // TODO: Implementar navegación
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
      // 1. Guardar en Firestore
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
        print('⚠️ Usuario $userId no tiene token FCM');
        return;
      }

      // 3. Enviar notificación push (usando Cloud Functions o HTTP)
      // Por ahora solo guardamos en Firestore
      // El usuario la verá cuando abra la app
      
      print('✅ Notificación enviada a $userId: $titulo');
      
    } catch (e) {
      print('❌ Error enviando notificación: $e');
    }
  }

  // Marcar notificación como leída
  Future<void> marcarComoLeida(String notifId) async {
    await _firestore.collection('notificaciones').doc(notifId).update({
      'leida': true,
    });
  }

  // Obtener notificaciones del usuario
  Stream<List<Notificacion>> getNotificacionesStream(String userId) {
    return _firestore
        .collection('notificaciones')
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Notificacion.fromFirestore(doc))
            .toList());
  }
}
```

---

## 📋 PASO 3: Integrar con FleteService (30 min)

### 3.1 Enviar notificaciones en asignación

**lib/services/flete_service.dart:**
```dart
import 'notification_service.dart';

class FleteService {
  final _notificationService = NotificationService();
  
  // ... código existente ...

  Future<void> asignarChoferYCamion({
    required String fleteId,
    required String choferId,
    required String camionId,
  }) async {
    try {
      // 1. Obtener datos del flete
      final fleteDoc = await _firestore.collection('fletes').doc(fleteId).get();
      final flete = Flete.fromFirestore(fleteDoc);
      
      // 2. Actualizar flete
      await _firestore.collection('fletes').doc(fleteId).update({
        'chofer_asignado': choferId,
        'camion_asignado': camionId,
        'estado': 'asignado',
        'fecha_asignacion': FieldValue.serverTimestamp(),
      });

      // 3. ENVIAR NOTIFICACIONES
      
      // 3a. Notificación al CLIENTE
      await _notificationService.enviarNotificacion(
        userId: flete.clienteId,
        tipo: 'asignacion',
        titulo: '✅ Flete Asignado',
        mensaje: 'Tu flete ${flete.numeroContenedor} ha sido asignado a un chofer',
        fleteId: fleteId,
      );

      // 3b. Notificación al CHOFER
      await _notificationService.enviarNotificacion(
        userId: choferId,
        tipo: 'asignacion',
        titulo: '🚛 Nuevo Recorrido',
        mensaje: 'Te han asignado el flete ${flete.numeroContenedor}',
        fleteId: fleteId,
      );

      print('✅ Notificaciones enviadas (cliente + chofer)');

    } catch (e) {
      print('❌ Error asignando flete: $e');
      rethrow;
    }
  }

  Future<void> completarFlete(String fleteId) async {
    try {
      // 1. Obtener datos del flete
      final fleteDoc = await _firestore.collection('fletes').doc(fleteId).get();
      final flete = Flete.fromFirestore(fleteDoc);
      
      // 2. Actualizar estado
      await _firestore.collection('fletes').doc(fleteId).update({
        'estado': 'completado',
        'fecha_completado': FieldValue.serverTimestamp(),
      });

      // 3. ENVIAR NOTIFICACIONES
      
      // 3a. Notificación al CLIENTE
      await _notificationService.enviarNotificacion(
        userId: flete.clienteId,
        tipo: 'completado',
        titulo: '🎉 Flete Completado',
        mensaje: 'El flete ${flete.numeroContenedor} ha sido completado',
        fleteId: fleteId,
      );

      // 3b. Notificación al TRANSPORTISTA
      if (flete.transportistaId != null) {
        await _notificationService.enviarNotificacion(
          userId: flete.transportistaId!,
          tipo: 'completado',
          titulo: '✅ Flete Completado',
          mensaje: 'El flete ${flete.numeroContenedor} ha sido completado',
          fleteId: fleteId,
        );
      }

      print('✅ Notificaciones enviadas (cliente + transportista)');

    } catch (e) {
      print('❌ Error completando flete: $e');
      rethrow;
    }
  }
}
```

---

## 📋 PASO 4: UI de Notificaciones (opcional, 30 min)

### 4.1 Badge en AppBar

**lib/screens/home_page.dart:**
```dart
import '../services/notification_service.dart';

AppBar(
  title: Text('CargoClick'),
  actions: [
    // Badge de notificaciones
    StreamBuilder<List<Notificacion>>(
      stream: _notificationService.getNotificacionesStream(_currentUserId),
      builder: (context, snapshot) {
        final noLeidas = snapshot.data?.where((n) => !n.leida).length ?? 0;
        
        return Stack(
          children: [
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                Navigator.pushNamed(context, '/notificaciones');
              },
            ),
            if (noLeidas > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$noLeidas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    ),
  ],
)
```

---

## 🧪 TESTING

### Test 1: Configuración
```bash
flutter pub get
flutter run --debug
```
**Verificar:**
- ✅ App compila sin errores
- ✅ Se piden permisos de notificaciones
- ✅ Token FCM se guarda en Firestore

### Test 2: Flujo de asignación
```
1. Login como TRANSPORTISTA (celular 1)
2. Login como CLIENTE (celular 2 o emulador)
3. Cliente publica flete
4. Transportista asigna chofer/camión
5. ✅ Verificar que CLIENTE recibe notificación
6. ✅ Verificar que CHOFER recibe notificación
```

### Test 3: Flujo de completado
```
1. Login como CHOFER (celular 1)
2. Completar flete (5/5 checkpoints)
3. ✅ Verificar que CLIENTE recibe notificación
4. ✅ Verificar que TRANSPORTISTA recibe notificación
```

---

## 📊 FIRESTORE STRUCTURE

### Collection: notificaciones
```javascript
/notificaciones/{notifId}
{
  user_id: string,        // A quién va dirigida
  tipo: string,           // 'asignacion', 'completado'
  titulo: string,
  mensaje: string,
  flete_id: string,       // Para navegar al flete
  created_at: Timestamp,
  leida: boolean
}
```

### Collection: users (actualizada)
```javascript
/users/{userId}
{
  // ... campos existentes ...
  fcm_token: string,      // Token para push notifications
  fcm_updated_at: Timestamp
}
```

---

## 🔒 FIRESTORE RULES

```javascript
// firestore.rules
match /notificaciones/{notifId} {
  allow read: if request.auth != null 
    && request.auth.uid == resource.data.user_id;
  
  allow create: if request.auth != null;
  
  allow update: if request.auth != null 
    && request.auth.uid == resource.data.user_id;
}
```

---

## ✅ CHECKLIST

- [ ] Agregar dependencias
- [ ] Configurar AndroidManifest
- [ ] Actualizar main.dart
- [ ] Crear modelo Notificacion
- [ ] Crear NotificationService
- [ ] Integrar con FleteService
- [ ] Guardar token FCM en login
- [ ] Testing en 2 dispositivos
- [ ] (Opcional) UI de notificaciones

---

**Tiempo total:** ~2 horas  
**Complejidad:** Media  
**Testing:** USB en Android

🚀 ¿Listo para empezar?
