# 🚀 GUÍA DE DEPLOY Y TESTING - FASE 1

**Fecha:** 2025-01-24  
**Proyecto:** CargoClick v2.0  
**Firebase Project:** sellora-2xtskv

---

## ⚠️ IMPORTANTE: ANTES DE PROBAR

La aplicación **NO FUNCIONARÁ** hasta que despliegues las reglas de Firestore actualizadas. Los nuevos cambios requieren:
- Reglas para `/transportistas`
- Reglas para `/camiones`
- Reglas actualizadas para `/fletes` (nuevos campos)
- Índices nuevos para queries optimizadas

---

## 📋 CHECKLIST PRE-DEPLOY

### ✅ Paso 1: Verificar Firebase CLI

Abre PowerShell y ejecuta:

```powershell
firebase --version
```

**Si no está instalado:**
```powershell
npm install -g firebase-tools
```

**Luego inicia sesión:**
```powershell
firebase login
```

---

### ✅ Paso 2: Verificar Proyecto Firebase

```powershell
cd C:\Proyectos\Cargo_click_mockpup
firebase projects:list
```

Deberías ver tu proyecto `sellora-2xtskv`.

**Si no está seleccionado:**
```powershell
firebase use sellora-2xtskv
```

---

### ✅ Paso 3: Deploy de Firestore Rules e Índices (CRÍTICO)

Este es el paso MÁS IMPORTANTE. Sin esto, la app no funcionará.

```powershell
# Desplegar SOLO las reglas e índices de Firestore
firebase deploy --only firestore
```

**Esto desplegará:**
- `firestore.rules` (reglas actualizadas)
- `firestore.indexes.json` (3 índices nuevos)

**Tiempo estimado:** 1-2 minutos

---

### ✅ Paso 4: Verificar Reglas en Firebase Console

1. Ve a: https://console.firebase.google.com/project/sellora-2xtskv/firestore/rules
2. Verifica que las reglas incluyan:
   - `/transportistas/{transportistaId}` 
   - `/camiones/{camionId}`
   - `/fletes/{fleteId}` (con campos nuevos: transportista_id, chofer_asignado, camion_asignado)

---

### ✅ Paso 5: Verificar Índices

1. Ve a: https://console.firebase.google.com/project/sellora-2xtskv/firestore/indexes
2. Deberían crearse automáticamente 3 índices nuevos:
   - `camiones` → transportista_id + created_at
   - `camiones` → transportista_id + disponible + created_at
   - `users` → transportista_id + tipo_usuario

**Nota:** Los índices pueden tardar 5-10 minutos en estar activos.

---

## 🧪 TESTING EN NETLIFY

### Opción A: Ya tienes la app desplegada en Netlify

Si tu app ya está en Netlify, simplemente:

1. **Haz commit y push de los cambios:**

```powershell
cd C:\Proyectos\Cargo_click_mockpup

git add .
git commit -m "feat: Implementada Fase 1 - Sistema Transportista→Chofer"
git push origin main
```

2. **Netlify re-compilará automáticamente** (si tienes CI/CD configurado)

3. **Espera 5-10 minutos** a que compile Flutter web

4. **Accede a tu URL de Netlify** y prueba

---

### Opción B: Build local y deploy manual a Netlify

Si tienes Flutter instalado:

```powershell
# Build para web
flutter build web --release

# Los archivos estarán en: build/web/
```

Luego sube la carpeta `build/web/` manualmente a Netlify.

---

### Opción C: Probar en Firebase Hosting (Alternativa)

Si prefieres usar Firebase Hosting en lugar de Netlify:

```powershell
# Después de hacer el build
flutter build web --release

# Deploy a Firebase Hosting
firebase deploy --only hosting
```

Tu app estará en: `https://sellora-2xtskv.web.app` o `https://sellora-2xtskv.firebaseapp.com`

---

## 🧪 PLAN DE TESTING FUNCIONAL

Una vez que la app esté desplegada y los índices activos, prueba este flujo:

### Test 1: Registro de Transportista ✅

1. Abre la app
2. Click en "Regístrate como Transportista"
3. Completa el formulario:
   - Razón Social: "Transportes Test"
   - RUT: "12345678-9"
   - Email: tu-email@test.com
   - Contraseña: test123
   - Teléfono: +56912345678
4. Click "Registrar Empresa"
5. **Verificar:** Deberías ver el home y estar logueado

---

### Test 2: Ver Código de Invitación ✅

1. En el home del transportista, busca botón de perfil
2. Click en "Mi Perfil" o similar
3. **Verificar:** Deberías ver tu código de 6 caracteres (ej: "A3X7K2")
4. **Verificar:** Botón "Copiar Código" funciona

---

### Test 3: Agregar Camión ✅

1. Navega a "Gestión de Flota"
2. Tab "Camiones"
3. Click botón "+" o "Agregar Camión"
4. Completa:
   - Patente: "ABCD12"
   - Tipo: "CTN Std 20"
   - Seguro: "50000"
   - Fecha vencimiento: Fecha futura (>30 días)
5. Click "Guardar"
6. **Verificar:** 
   - Camión aparece en la lista
   - Semáforo verde (documentos OK)

---

### Test 4: Registro de Chofer con Código ✅

1. Cierra sesión
2. Click "Regístrate como Chofer"
3. Completa:
   - Nombre: "Juan Pérez"
   - Email: chofer@test.com
   - Contraseña: test123
   - Empresa: "Transportes Test"
   - Teléfono: +56987654321
   - **Código de Invitación:** [El código que copiaste antes]
4. Click "Registrarse"
5. **Verificar:** Registro exitoso sin errores

---

### Test 5: Verificar Chofer Vinculado ✅

1. Cierra sesión del chofer
2. Inicia sesión como transportista
3. Ve a "Gestión de Flota"
4. Tab "Choferes"
5. **Verificar:** El chofer "Juan Pérez" aparece en la lista

---

### Test 6: Publicar Flete (Como Cliente) ✅

**Nota:** Necesitas una cuenta de Cliente (puedes crearla manualmente en Firebase Console)

1. En Firestore Console, crea un documento en `/users`:
   ```
   uid: "cliente_test_id"
   email: "cliente@test.com"
   display_name: "Cliente Test"
   tipo_usuario: "Cliente"
   empresa: "Empresa Test"
   phone_number: "+56911111111"
   created_at: [timestamp]
   updated_at: [timestamp]
   ```

2. En Firebase Auth, crea el usuario con ese email

3. Inicia sesión como cliente

4. Publica un flete:
   - Tipo: "20 ft"
   - Número: "CTN123456"
   - Peso: 15000
   - Origen: "Puerto Valparaíso"
   - Destino: "Santiago Centro"
   - Tarifa: 250000

5. **Verificar:** Flete creado con estado "disponible"

---

### Test 7: Aceptar y Asignar Flete ✅

1. Cierra sesión del cliente
2. Inicia sesión como transportista
3. Busca opción "Fletes Disponibles" en el menú
4. **Verificar:** Ves el flete publicado por el cliente
5. Click "Aceptar y Asignar"
6. Selecciona el chofer "Juan Pérez"
7. Selecciona el camión "ABCD12"
8. Click "Confirmar Asignación"
9. **Verificar:** 
   - Mensaje de éxito
   - Vuelve a la lista
   - El flete desaparece de disponibles

---

### Test 8: Verificar Flete Asignado (Chofer) ✅

1. Cierra sesión del transportista
2. Inicia sesión como chofer (chofer@test.com)
3. Ve a "Mis Recorridos"
4. **Verificar:**
   - El flete asignado aparece en la lista
   - Puedes ver los detalles completos
   - Puedes acceder a completar checkpoints (funcionalidad existente)

---

## 🐛 DEBUGGING

### Si la app no carga:

1. Abre DevTools del navegador (F12)
2. Ve a Console
3. Busca errores de Firebase
4. Errores comunes:
   - **"Missing or insufficient permissions"** → Rules no desplegadas
   - **"Index not found"** → Índices aún creándose (espera 10 min)
   - **"Invalid collection"** → Typo en nombre de collection

---

### Si el registro de transportista falla:

1. Ve a Firestore Console
2. Verifica que se creó el documento en `/transportistas/{uid}`
3. Si no existe, revisa las rules
4. Verifica que el código de invitación se generó

---

### Si el chofer no puede registrarse con código:

1. Verifica que el código existe en Firestore
2. Query manual:
   ```
   Collection: transportistas
   Where: codigo_invitacion == "TU_CODIGO"
   ```
3. Si no aparece, hay un problema con el registro de transportista

---

### Si la asignación de flete falla:

1. Verifica que tienes:
   - Al menos 1 chofer vinculado
   - Al menos 1 camión disponible
   - Al menos 1 flete con estado "disponible"
2. Revisa console del navegador para ver el error exacto
3. Verifica que las rules permiten update del flete

---

## 🔄 ROLLBACK (Si algo sale mal)

Si después del deploy algo no funciona:

```powershell
# Ver historial de deploys
firebase firestore:rules:list

# Hacer rollback al deploy anterior
firebase firestore:rules:release <release-id>
```

**O manualmente:**
1. Ve a Firebase Console → Firestore → Rules
2. Click en "Restore" en una versión anterior

---

## 📞 CHECKLIST FINAL ANTES DE TESTING

- [ ] Firebase CLI instalado y logueado
- [ ] Proyecto `sellora-2xtskv` seleccionado
- [ ] Rules desplegadas: `firebase deploy --only firestore`
- [ ] Índices creándose (esperar 10 min)
- [ ] App desplegada en Netlify o Firebase Hosting
- [ ] DevTools del navegador abierto para debugging

---

## 🎯 SIGUIENTE PASO

Después de testing exitoso:
1. Documentar cualquier bug encontrado
2. Decidir si continuar con Fase 2 o pulir Fase 1
3. Actualizar README con nuevo flujo

---

**¿Listo para empezar?** Ejecuta estos comandos uno por uno:

```powershell
cd C:\Proyectos\Cargo_click_mockpup
firebase login
firebase use sellora-2xtskv
firebase deploy --only firestore
```

Luego espera 10 minutos y accede a tu URL de Netlify.
