# 🚀 DESPLIEGUE SISTEMA DE EMAILS - PASO A PASO

## ✅ CONFIGURACIÓN COMPLETADA

```
Desde:  cla270308@gmail.com
Para:   cabreraclaudiov@gmail.com (todos los emails de prueba)
App Password: ✅ Configurado
```

---

## 📋 COMANDOS PARA EJECUTAR

### Paso 1: Instalar Dependencias

Abre una terminal en la carpeta del proyecto y ejecuta:

```bash
cd functions
npm install
```

**Esto instalará:**
- nodemailer (para enviar emails)
- Todas las dependencias necesarias

**Tiempo estimado:** 1-2 minutos

---

### Paso 2: Desplegar Cloud Functions

```bash
firebase deploy --only functions
```

**Esto desplegará:**
- sendPushNotification (ya existente)
- updateFCMToken (ya existente)
- sendEmailOnAssignment ← NUEVO 📧
- sendEmailOnValidation ← NUEVO 📧
- sendEmailOnCompletion ← NUEVO 📧

**Tiempo estimado:** 3-5 minutos

---

## 🧪 CÓMO PROBAR

### Test 1: Email de Asignación

1. **En la app:**
   - Login como Transportista
   - Ve a "Fletes Disponibles"
   - Asigna un chofer y camión a un flete

2. **Resultado esperado:**
   - Email enviado a: cabreraclaudiov@gmail.com
   - Asunto: "✅ Flete Asignado - Datos de Transporte"
   - Contenido: Datos del chofer, camión y flete

3. **Verifica:**
   - Revisa el email en cabreraclaudiov@gmail.com
   - Si no llega, revisa la carpeta SPAM

---

### Test 2: Email de Validación

1. **En la app:**
   - Login como Cliente
   - Ve a un flete asignado
   - Aprueba el camión/chofer

2. **Resultado esperado:**
   - Email enviado a: cabreraclaudiov@gmail.com
   - Asunto: "✅ Camión/Chofer Aprobado"
   - Contenido: Datos del camión validado

---

### Test 3: Email de Flete Completado

1. **En la app:**
   - Login como Chofer
   - Completa todos los checkpoints (5/5)

2. **Resultado esperado:**
   - 2 emails enviados a: cabreraclaudiov@gmail.com
   - Uno para cliente (con facturación)
   - Uno para transportista (confirmación)
   - Asunto: "🎉 Flete Completado"

---

## 🔍 VER LOGS (Si algo falla)

```bash
firebase functions:log
```

O específico para cada función:

```bash
firebase functions:log --only sendEmailOnAssignment
firebase functions:log --only sendEmailOnValidation
firebase functions:log --only sendEmailOnCompletion
```

---

## ⚠️ TROUBLESHOOTING

### Si no llegan los emails:

1. **Revisa SPAM** en cabreraclaudiov@gmail.com
2. **Verifica logs:**
   ```bash
   firebase functions:log
   ```
3. **Verifica que el App Password esté correcto** en `functions/emailConfig.js`
4. **Verifica que 2-Step Verification esté activada** en cla270308@gmail.com

### Si hay errores al desplegar:

1. **Asegúrate de estar en la carpeta correcta:**
   ```bash
   cd C:\Proyectos\Cargo_click_mockpup\functions
   ```
2. **Reinstala dependencias:**
   ```bash
   rm -rf node_modules
   npm install
   ```
3. **Intenta de nuevo:**
   ```bash
   cd ..
   firebase deploy --only functions
   ```

---

## 📊 RESUMEN DE LA CONFIGURACIÓN

### Emails Automáticos:

| Evento | Trigger | Email va a |
|--------|---------|------------|
| Flete Asignado | Estado → `asignado` | cabreraclaudiov@gmail.com |
| Camión Aprobado | `is_validado_cliente` → true | cabreraclaudiov@gmail.com |
| Flete Completado | Estado → `completado` | cabreraclaudiov@gmail.com (x2) |

### Modo Actual:
- ✅ **Testing activado** (`useTestEmails: true`)
- ✅ Todos los emails van a `cabreraclaudiov@gmail.com`
- ✅ Los usuarios reales NO reciben emails todavía
- ✅ Puedes probar sin afectar a nadie

### Para pasar a Producción:

En `functions/emailConfig.js` cambiar:
```javascript
useTestEmails: false,  // ← Cambiar a false
```

Luego redesplegar:
```bash
firebase deploy --only functions
```

---

## ✅ CHECKLIST

- [x] App Password generado
- [x] `emailConfig.js` configurado
- [x] Emails configurados (desde/para)
- [ ] Dependencias instaladas (`npm install`)
- [ ] Functions desplegadas (`firebase deploy`)
- [ ] Test email asignación ✅
- [ ] Test email validación ✅
- [ ] Test email completado ✅

---

## 🎯 PRÓXIMOS PASOS

1. **Ejecuta los comandos** de arriba
2. **Prueba cada tipo de email** en la app
3. **Revisa cabreraclaudiov@gmail.com** para ver los emails
4. **Verifica que todo funcione** correctamente
5. **Cuando estés listo**, cambia a producción

---

**Última actualización:** 14 Noviembre 2025  
**Estado:** ✅ Configurado y Listo para Desplegar

🚀 **¡Ejecuta los comandos y prueba!** 🚀
