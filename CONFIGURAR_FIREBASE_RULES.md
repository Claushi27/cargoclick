# CONFIGURAR REGLAS DE FIREBASE (CRÍTICO)

Las reglas de seguridad de Firebase son **esenciales** para que la app funcione correctamente.

## 🔴 ERROR COMÚN: "Permission Denied"

Si ves este error al intentar aceptar fletes o subir fotos:
```
cloud_firestore permission denied: missing or insufficient permissions
```

Significa que las reglas de Firestore no están configuradas.

---

## ✅ SOLUCIÓN RÁPIDA

### Opción 1: Usando Firebase CLI (Recomendado)

1. **Instalar Firebase CLI** (si no lo tienes):
   ```bash
   npm install -g firebase-tools
   ```

2. **Login a Firebase:**
   ```bash
   firebase login
   ```

3. **Desplegar reglas desde el proyecto:**
   ```bash
   cd C:\Proyectos\Cargo_click_mockpup
   firebase deploy --only firestore:rules
   firebase deploy --only storage
   ```

   Esto aplicará las reglas de `firestore.rules` y `storage.rules` automáticamente.

---

### Opción 2: Manualmente desde Firebase Console

#### A) Reglas de Firestore

1. Ve a: https://console.firebase.google.com
2. Selecciona proyecto: `sellora-2xtskv`
3. **Firestore Database** → **Rules** (pestaña)
4. **Borra todo** y pega el contenido del archivo `firestore.rules`
5. Click **"Publish"**

#### B) Reglas de Storage

1. En Firebase Console
2. **Storage** → **Rules** (pestaña)
3. **Borra todo** y pega el contenido del archivo `storage.rules`
4. Click **"Publish"**

---

## 📋 VERIFICAR QUE FUNCIONA

Después de aplicar las reglas:

1. **Refresca la app web** (Ctrl+F5)
2. **Login como chofer**
3. Ve a tab **"Disponibles"**
4. Click **"Aceptar"** en un flete
5. ✅ **Debería funcionar sin errores**

---

## 🔍 LO QUE PERMITEN LAS REGLAS

### Firestore Rules:

- ✅ **Usuarios autenticados** pueden leer todos los fletes
- ✅ **Admin/Cliente** puede crear fletes
- ✅ **Chofer** puede crear solicitudes
- ✅ **Chofer asignado** puede actualizar fletes y subir checkpoints
- ✅ **Admin** puede actualizar cualquier flete que creó

### Storage Rules:

- ✅ **Usuarios autenticados** pueden leer fotos
- ✅ **Usuarios autenticados** pueden subir fotos a checkpoints
- ❌ **No autenticados** no pueden hacer nada

---

## ⚠️ IMPORTANTE

**NUNCA uses reglas abiertas en producción:**

```javascript
// ❌ MAL - No hagas esto:
allow read, write: if true;

// ✅ BIEN - Siempre verifica autenticación:
allow read, write: if request.auth != null;
```

---

## 🐛 Troubleshooting

**Error: "Deployment requires BLAZE plan"**
- Las reglas NO requieren plan Blaze
- Solo el deploy a través de CLI es gratis
- Puedes copiarlas manualmente si prefieres

**Error: "Invalid token"**
- Ejecuta `firebase logout` y luego `firebase login` nuevamente

**Las reglas no se aplican**
- Espera 1 minuto después de publicar
- Refresca completamente la app (Ctrl+Shift+R)
- Verifica en Firebase Console que se publicaron correctamente

---

## 📝 Comandos Útiles

```bash
# Ver proyecto actual
firebase use

# Cambiar de proyecto
firebase use sellora-2xtskv

# Solo desplegar reglas (sin hosting)
firebase deploy --only firestore:rules,storage

# Ver reglas actuales
firebase firestore:indexes
```

---

**Última actualización:** 2025-10-23
