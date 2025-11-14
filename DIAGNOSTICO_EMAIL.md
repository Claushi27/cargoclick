# 🔍 DIAGNÓSTICO: Email no llegó al asignar flete

## ✅ Lo que SÍ pasó:
- Asignaste un flete desde Chrome (Flutter Web)
- Notificación push no llegó (NORMAL en Web)

## ❌ Lo que NO pasó:
- Email no llegó a cabreraclaudiov@gmail.com

---

## 🔍 PASOS PARA DIAGNOSTICAR:

### 1. Verificar que las Cloud Functions se desplegaron

Ejecuta este comando:
```bash
firebase functions:list
```

**Deberías ver:**
- ✅ sendPushNotification
- ✅ updateFCMToken
- ✅ sendEmailOnAssignment ← IMPORTANTE
- ✅ sendEmailOnValidation
- ✅ sendEmailOnCompletion

---

### 2. Ver logs de Cloud Functions

Ejecuta:
```bash
firebase functions:log --limit 50
```

**Busca:**
- ❓ ¿Aparece "📧 Enviando email de asignación"?
- ❓ ¿Hay algún error relacionado con email?
- ❓ ¿Aparece "✅ Email enviado"?

---

### 3. Verificar el flete en Firestore

1. Ve a Firebase Console: https://console.firebase.google.com/project/sellora-2xtskv
2. Ve a Firestore Database
3. Busca el flete que acabas de asignar
4. Verifica que:
   - ✅ `estado` cambió a `"asignado"`
   - ✅ `chofer_asignado` tiene un ID
   - ✅ `camion_asignado` tiene un ID
   - ✅ `cliente_id` tiene un ID válido

---

### 4. Verificar bandeja de entrada

En **cabreraclaudiov@gmail.com**:
- ❓ ¿Revisaste la carpeta SPAM/Correo no deseado?
- ❓ ¿Revisaste Todas las bandejas?
- ❓ ¿Aparece ALGO de cla270308@gmail.com?

---

## 🐛 POSIBLES CAUSAS

### Causa 1: Functions no desplegadas correctamente
**Solución:**
```bash
firebase deploy --only functions
```

### Causa 2: Error en el trigger
La Cloud Function se activa cuando el campo `estado` cambia a `"asignado"`.

**Verifica en el código que al asignar, SÍ se cambia el estado:**
Archivo: `lib/services/flete_service.dart`

### Causa 3: Error en credenciales de email
**Verifica:**
- App Password correcto en `functions/emailConfig.js`
- 2-Step Verification activada en cla270308@gmail.com

### Causa 4: Error en el código
**Ver logs completos:**
```bash
firebase functions:log --only sendEmailOnAssignment
```

---

## 🚀 PRUEBA RÁPIDA

### Test Manual desde Firebase Console:

1. Ve a Firestore
2. Abre un flete con estado `"disponible"` o `"solicitado"`
3. Edita manualmente el campo `estado` a `"asignado"`
4. Espera 10 segundos
5. Revisa cabreraclaudiov@gmail.com

**Si llega el email:** El problema es el código de Flutter  
**Si NO llega:** El problema es la Cloud Function

---

## 📋 CHECKLIST DE VERIFICACIÓN

Ejecuta estos comandos y copia la salida:

```bash
# 1. Ver funciones desplegadas
firebase functions:list

# 2. Ver logs recientes
firebase functions:log --limit 20

# 3. Ver logs específicos de email
firebase functions:log --only sendEmailOnAssignment
```

---

## 💡 NOTA IMPORTANTE

**Sobre las notificaciones en Web:**
Las notificaciones push en Flutter Web tienen limitaciones. Es NORMAL que no funcionen igual que en Android. Para testing de emails, es mejor usar Android o simplemente verificar que el email llegue.

**Lo importante ahora es verificar por qué no llegó el email.**

---

Ejecuta los comandos de arriba y pégame la salida para diagnosticar el problema.
