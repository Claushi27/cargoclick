# 🔧 SOLUCIÓN: Vista incorrecta en Firebase Hosting

## Problema
Transportista ve vista de Chofer en Firebase Hosting (pero funciona local)

## Causa Raíz
Build de Flutter cachea datos de Firestore en tiempo de compilación

## Solución Definitiva

### 1. Limpiar TODO el caché

```powershell
# Borrar carpetas de caché manualmente
Remove-Item -Recurse -Force build
Remove-Item -Recurse -Force .dart_tool
Remove-Item -Recurse -Force C:\Users\<TU_USUARIO>\AppData\Local\Pub\Cache\hosted

# Flutter clean
flutter clean
```

### 2. Rebuild COMPLETO

```powershell
# Obtener dependencias frescas
flutter pub get

# Build con flag de no-cache
flutter build web --release --no-tree-shake-icons
```

### 3. Deploy limpio

```powershell
# Deploy forzando reemplazo
firebase deploy --only hosting --force
```

### 4. IMPORTANTE: Verificar en Firestore Console

Ve a Firebase Console → Firestore Database y verifica:

1. **Collection `transportistas`** - Debe tener el documento del transportista con su UID
2. **Collection `users`** - NO debe tener documento con el UID del transportista
3. Si existe documento en `users` con UID del transportista → **BORRARLO**

### 5. Limpiar caché del navegador

```
Chrome: Ctrl + Shift + Delete → Últimas 24 horas → Borrar todo
Firefox: Ctrl + Shift + Delete → Últimas 24 horas → Borrar todo
```

O abrir en **ventana de incógnito**: `Ctrl + Shift + N`

---

## Script Automático Mejorado

Ejecuta esto en PowerShell:

```powershell
# Limpieza profunda
Write-Host "Limpiando cache..." -ForegroundColor Yellow
flutter clean
Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force .dart_tool -ErrorAction SilentlyContinue

# Rebuild
Write-Host "Obteniendo dependencias..." -ForegroundColor Yellow
flutter pub get

Write-Host "Building web..." -ForegroundColor Yellow
flutter build web --release --no-tree-shake-icons

# Deploy
Write-Host "Desplegando..." -ForegroundColor Yellow
firebase deploy --only hosting --force

Write-Host "COMPLETADO!" -ForegroundColor Green
Write-Host "URL: https://sellora-2xtskv.web.app" -ForegroundColor Cyan
Write-Host "IMPORTANTE: Abrir en VENTANA DE INCOGNITO" -ForegroundColor Red
```

---

## Verificación Post-Deploy

### 1. Abrir DevTools (F12) en el navegador

### 2. Ver Console logs

Buscar estos mensajes:

```
✅ [loadUsuario] TRANSPORTISTA encontrado: [Nombre Empresa]
✅ Renderizando vista TRANSPORTISTA
```

Si ves:
```
✅ [loadUsuario] USUARIO encontrado: Chofer
```

→ **El problema está en Firestore, NO en el código**

### 3. Verificar Network

En DevTools → Network → filtrar por "firestore"

- Debe haber petición a `/transportistas/{uid}`
- Debe retornar 200 con datos del transportista

---

## Si SIGUE fallando

### Opción 1: Verificar datos en Firestore

```javascript
// En Firebase Console → Firestore → Ejecutar query
collection: transportistas
filter: uid == [UID_DEL_USUARIO]
```

Debe retornar 1 documento

### Opción 2: Borrar y recrear cuenta

1. Firebase Console → Authentication → Eliminar usuario
2. Firestore → Borrar documentos relacionados
3. Registrar nuevamente como Transportista

### Opción 3: Ver logs en tiempo real

En `home_page.dart` ya agregué logs completos. Verifica:

```
🔄 [loadUsuario] Iniciando carga de usuario...
🔍 [loadUsuario] UID actual: [UID]
🔍 [loadUsuario] Email actual: [EMAIL]
```

Luego debe seguir:
```
✅ [loadUsuario] TRANSPORTISTA encontrado: [Empresa]
```

Si salta directo a "USUARIO encontrado" → problema en query de Firestore

---

## Cambios Realizados

1. ✅ Orden de detección: PRIMERO transportista, LUEGO usuario
2. ✅ Validación nula: Verificar `_transportista != null`
3. ✅ Logs agresivos: Ver cada paso de la detección
4. ✅ Cache busting: Meta tags + versión en script
5. ✅ Headers HTTP: No-cache en firebase.json

---

## Última Opción: Verificar Rules

Si TODO falla, puede ser las reglas de Firestore:

```javascript
// firestore.rules
match /transportistas/{transportistaId} {
  allow read: if true; // ← DEBE ser público para el código de invitación
  allow write: if request.auth.uid == transportistaId;
}
```

Deploy reglas:
```powershell
firebase deploy --only firestore:rules
```
