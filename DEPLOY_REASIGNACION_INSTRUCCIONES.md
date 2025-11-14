# 🚀 DESPLIEGUE DE CLOUD FUNCTIONS - Reasignación

## ✅ NUEVA FUNCIÓN A DESPLEGAR

Solo hay **1 nueva Cloud Function** para el sistema de reasignación:

### `sendEmailOnCambioAsignacion`

**Trigger:** Se crea un documento en la colección `cambios_asignacion`  
**Acción:** Envía email al cliente notificando el cambio  
**Template:** `templateCambioAsignacion` (ya creado)

---

## 📋 COMANDOS PARA DESPLEGAR

### Opción 1: Desplegar SOLO la nueva función

```bash
cd C:\Proyectos\Cargo_click_mockpup
firebase deploy --only functions:sendEmailOnCambioAsignacion
```

**Ventaja:** Rápido (solo 1-2 minutos)  
**Desventaja:** Las otras funciones no se actualizan

---

### Opción 2: Desplegar TODAS las funciones (Recomendado)

```bash
cd C:\Proyectos\Cargo_click_mockpup
firebase deploy --only functions
```

**Ventaja:** Actualiza todo (incluye las mejoras anteriores)  
**Desventaja:** Más lento (3-5 minutos)

---

## 📊 FUNCIONES QUE SE DESPLEGARÁN

Si usas la Opción 2, se desplegarán:

1. ✅ `sendPushNotification` (ya existía)
2. ✅ `updateFCMToken` (ya existía)
3. ✅ `sendEmailOnAssignment` (ya existía - email al asignar)
4. ✅ `sendEmailOnValidation` (ya existía - email al validar)
5. ✅ `sendEmailOnCompletion` (ya existía - email al completar)
6. ✨ `sendEmailOnCambioAsignacion` **← NUEVA**

---

## ⚙️ VERIFICAR ANTES DE DESPLEGAR

1. **Email configurado:**
   - ✅ `functions/emailConfig.js` tiene las credenciales correctas
   - ✅ App Password de Gmail configurado
   - ✅ `useTestEmails: true` para testing

2. **Dependencias instaladas:**
   ```bash
   cd functions
   npm install
   ```

3. **No hay errores de sintaxis:**
   El linter ya está desactivado, así que no debería haber problemas.

---

## 🧪 TESTING DESPUÉS DEL DEPLOY

### Test Completo de Reasignación:

1. **Login como Transportista**
2. **Ve a "Mis Fletes Asignados"**
3. **Toca un flete asignado** (abre el bottom sheet)
4. **Click en "Cambiar Chofer/Camión"** (botón naranja)
5. **Selecciona nuevo chofer y camión**
6. **Escribe razón:** "Prueba de reasignación"
7. **Confirma**

**Verificar:**
- ✅ Dialog se muestra correctamente
- ✅ Dropdowns tienen opciones
- ✅ Validación funciona
- ✅ Mensaje de éxito aparece
- ✅ Bottom sheet se cierra

8. **Revisa email:** `cabreraclaudiov@gmail.com`
   - ✅ Email llegó (puede tardar 10-30 segundos)
   - ✅ Subject: "🔄 Cambio de Chofer/Camión - Tiene 24h para Revisar"
   - ✅ Muestra antes/después correctamente

9. **Login como Cliente**
10. **Ve al mismo flete**
11. **Scroll down hasta "Historial de Cambios"**

**Verificar:**
- ✅ Card de historial aparece
- ✅ Muestra el cambio reciente
- ✅ Badge "Activo" en verde
- ✅ Tiempo restante aparece (ej: "24h restantes")
- ✅ Botón "Rechazar Cambio" disponible

12. **Click en "Rechazar Cambio"**
13. **Escribe motivo:** "Solo para prueba"
14. **Confirma**

**Verificar:**
- ✅ Dialog de confirmación aparece
- ✅ Validación del motivo funciona
- ✅ Loading aparece
- ✅ Mensaje de éxito
- ✅ Badge cambia a "Rechazado" en rojo
- ✅ Flete vuelve al chofer/camión anterior

---

## 🔍 VER LOGS (Si algo falla)

```bash
# Logs generales
firebase functions:log

# Logs específicos de la nueva función
firebase functions:log --only sendEmailOnCambioAsignacion

# Últimos 50 logs
firebase functions:log --limit 50
```

---

## ❌ TROUBLESHOOTING

### Si el email no llega:

1. **Revisa la carpeta SPAM** de cabreraclaudiov@gmail.com
2. **Verifica logs:**
   ```bash
   firebase functions:log --only sendEmailOnCambioAsignacion
   ```
3. **Busca errores en los logs:**
   - ❓ "Email enviado" → Bueno, revisar SPAM
   - ❌ "Error enviando email" → Problema con credenciales
   - ❌ "User not found" → Problema con datos de Firestore

### Si el dialog no aparece:

1. **Verifica que el flete esté asignado o en_proceso**
2. **Revisa la consola de Flutter** por errores
3. **Verifica que haya choferes/camiones disponibles**

### Si el rechazo no funciona:

1. **Verifica que estén dentro de las 24 horas**
2. **Revisa logs de Firestore** en Firebase Console
3. **Verifica permisos** en Firestore Rules

---

## 📝 CHECKLIST POST-DEPLOY

- [ ] Functions desplegadas sin errores
- [ ] Email de prueba llegó correctamente
- [ ] Dialog de reasignación funciona
- [ ] Historial de cambios se muestra
- [ ] Botón de rechazo funciona
- [ ] Flete se revierte al rechazar
- [ ] Notificaciones push funcionan
- [ ] Logs sin errores críticos

---

## 🎯 COMANDO RECOMENDADO

```bash
# Desde la raíz del proyecto:
firebase deploy --only functions
```

**Tiempo:** 3-5 minutos  
**Costo:** Gratis (plan Spark/Blaze)

---

¿Listo para desplegar? Ejecuta el comando y avísame cuando termine para hacer las pruebas! 🚀
