# 🔔 CONFIGURACIÓN MANUAL REQUERIDA - NOTIFICACIONES PUSH

**Fecha:** 30 Enero 2025  
**Estado:** ⏳ PENDIENTE DE CONFIGURACIÓN

---

## ✅ LO QUE YA ESTÁ HECHO (Código implementado)

- ✅ Dependencias agregadas (`firebase_messaging`, `flutter_local_notifications`, `geolocator`)
- ✅ Modelo `Notificacion` creado
- ✅ Servicio `NotificationService` implementado
- ✅ `main.dart` actualizado con handler de notificaciones
- ✅ `AndroidManifest.xml` configurado con permisos
- ✅ Integración con `FleteService` (envía notif al asignar)
- ✅ Integración con `CheckpointService` (envía notif al completar)
- ✅ Integración con `AuthService` (guarda token al login)
- ✅ Firestore rules actualizadas

---

## 🔧 PASOS QUE TÚ DEBES HACER

### PASO 1: Desplegar Firestore Rules (1 min)

```bash
firebase deploy --only firestore:rules
```

**Verificación:**
- Ir a Firebase Console → Firestore Database → Rules
- Debe aparecer la sección de `notificaciones` con:
  ```javascript
  match /notificaciones/{notifId} {
    allow read: if isAuthenticated() 
      && resource.data.user_id == request.auth.uid;
    allow create: if isAuthenticated();
    allow update: if isAuthenticated() 
      && resource.data.user_id == request.auth.uid;
    allow delete: if isAuthenticated() 
      && resource.data.user_id == request.auth.uid;
  }
  ```

---

### PASO 2: Instalar Dependencias de Flutter (2 min)

```bash
flutter pub get
```

**Verificación:**
- No deben aparecer errores
- Las dependencias `firebase_messaging`, `flutter_local_notifications` y `geolocator` deben descargarse

---

### PASO 3: Compilar y Testear en USB (5 min)

#### 3.1 Conectar tu celular Android

1. Activar **Opciones de Desarrollador** en tu celular:
   - Ajustes → Acerca del teléfono
   - Tocar 7 veces en "Número de compilación"
   
2. Activar **Depuración USB**:
   - Ajustes → Opciones de desarrollador
   - Activar "Depuración USB"
   
3. Conectar celular por USB al PC
   
4. En el celular, autorizar el PC (aparece pop-up)

#### 3.2 Verificar dispositivo conectado

```bash
flutter devices
```

**Debe aparecer algo como:**
```
Galaxy A54 5G (mobile) • abc123xyz • android-arm64 • Android 14 (API 34)
```

#### 3.3 Ejecutar en modo debug

```bash
flutter run --debug
```

O en modo release (más rápido):

```bash
flutter run --release
```

**Verificación:**
- App se instala en tu celular
- Se abre automáticamente
- Aparece pop-up pidiendo permisos de notificaciones → **Aceptar**
- En la consola debe aparecer: `✅ Permisos de notificaciones concedidos`

---

### PASO 4: Testing del Flujo de Notificaciones (10-15 min)

#### Opción A: Con 2 dispositivos (IDEAL)

**TEST 1: Publicación → Notificación a Transportistas**

**Dispositivo 1: Emulador (Cliente)**
```
1. Login como cliente
2. Publicar flete
3. ✅ Flete publicado exitosamente
```

**Dispositivo 2: Tu celular (Transportista)**
```
1. Login como transportista
2. ✅ VERIFICAR: Recibes notificación "🚛 Nuevo Flete Disponible"
3. Click en la notificación o ir a "Fletes Disponibles"
4. Asignar chofer y camión
```

**TEST 2: Asignación → Notificación a Cliente y Chofer**

**Dispositivo 1: Emulador (Cliente)**
```
1. ✅ VERIFICAR: Recibes notificación "✅ Flete Asignado"
```

**Dispositivo 2: Tu celular (Chofer)**
```
1. Login como chofer (si es diferente al transportista)
2. ✅ VERIFICAR: Recibes notificación "🚛 Nuevo Recorrido"
3. Ir a "Mis Recorridos"
4. Completar 5/5 checkpoints
```

**TEST 3: Completado → Notificación a Cliente y Transportista**

**Dispositivo 1: Emulador (Cliente)**
```
1. ✅ VERIFICAR: Recibes notificación "🎉 Flete Completado"
```

**Dispositivo 2: Transportista**
```
1. Login como transportista
2. ✅ VERIFICAR: Recibes notificación "✅ Flete Completado"
```

#### Opción B: Solo tu celular (Menos ideal)

```
1. Login como cliente
2. Publicar flete
3. Logout
4. Login como transportista
5. Asignar flete
6. ❌ NO verás la notificación (porque eres tú mismo)
7. Logout
8. Login como cliente
9. ✅ Verás la notificación en la lista (pero no push)
```

#### Test de Completado:

```
1. Login como chofer (tu celular)
2. Ir a "Mis Recorridos"
3. Completar 5/5 checkpoints
4. ✅ Cliente y transportista deben recibir notificación
```

---

## 📊 VERIFICACIÓN EN FIREBASE CONSOLE

### 1. Verificar Tokens FCM guardados

**Ir a:** Firebase Console → Firestore Database

**Buscar collection:** `users` o `transportistas`

**Verificar campos:**
- `fcm_token`: debe tener un string largo (ej: `eX7Kp...`)
- `fcm_updated_at`: debe tener timestamp reciente

### 2. Verificar Notificaciones creadas

**Collection:** `notificaciones`

**Debe haber documentos con:**
```javascript
{
  user_id: "abc123...",
  tipo: "asignacion" o "completado",
  titulo: "✅ Flete Asignado",
  mensaje: "Tu flete CTN123 ha sido asignado...",
  flete_id: "xyz789...",
  created_at: Timestamp,
  leida: false
}
```

---

## 🐛 TROUBLESHOOTING

### Error: "Permisos denegados"
**Solución:**
1. Desinstalar app del celular
2. Volver a correr `flutter run`
3. Aceptar permisos cuando se pidan

### Error: "No se pudo guardar token FCM"
**Posibles causas:**
1. Firebase no está inicializado → Verificar `google-services.json`
2. Firestore rules bloquean → Desplegar rules con `firebase deploy --only firestore:rules`
3. Usuario no existe → Hacer login primero

### No aparecen notificaciones
**Verificar:**
1. Permisos aceptados en el celular (Ajustes → Apps → CargoClick → Permisos)
2. Token FCM guardado en Firestore (ver sección anterior)
3. Notificación creada en collection `notificaciones`
4. Logs en consola: buscar `✅ Notificación enviada`

### Notificaciones solo aparecen al abrir la app
**Es normal por ahora:**
- Las notificaciones se guardan en Firestore
- Se muestran cuando el usuario abre la app
- Para PUSH REAL (que aparezcan aunque la app esté cerrada) necesitas Cloud Functions (siguiente paso)

---

## 🚀 PRÓXIMOS PASOS

### Implementado (Listo):
- ✅ Notificaciones in-app (guardan en Firestore)
- ✅ Se muestran al usuario cuando abre la app
- ✅ Triggers automáticos (asignación, completado)

### Pendiente (Opcional - necesita Cloud Functions):
- ⏳ Push notifications REALES (aparecen aunque app esté cerrada)
- ⏳ Correos electrónicos (al asignar, enviar email al cliente)
- ⏳ WhatsApp (requiere Twilio API)

**Para push REALES se necesita:**
```javascript
// Cloud Function en Firebase
exports.sendPushNotification = functions.firestore
  .document('notificaciones/{notifId}')
  .onCreate(async (snap, context) => {
    const notif = snap.data();
    const userDoc = await admin.firestore()
      .collection('users')
      .doc(notif.user_id)
      .get();
    
    const token = userDoc.data().fcm_token;
    
    await admin.messaging().send({
      token: token,
      notification: {
        title: notif.titulo,
        body: notif.mensaje,
      },
      data: {
        flete_id: notif.flete_id,
      },
    });
  });
```

---

## ✅ CHECKLIST FINAL

- [ ] `firebase deploy --only firestore:rules`
- [ ] `flutter pub get`
- [ ] Conectar celular por USB
- [ ] `flutter run --debug`
- [ ] Aceptar permisos de notificaciones
- [ ] Login como usuario
- [ ] Verificar token FCM en Firestore
- [ ] Testing de asignación (2 dispositivos ideal)
- [ ] Testing de completado
- [ ] Verificar notificaciones en Firestore

---

## 📞 AYUDA

Si algo no funciona:
1. Revisar logs de consola (buscar ❌ o ⚠️)
2. Verificar Firestore rules desplegadas
3. Verificar permisos en el celular
4. Verificar que Firebase esté inicializado

**¿Listo para empezar?** 🚀

---

**Última actualización:** 30 Enero 2025  
**Tiempo estimado total:** 20-30 minutos
