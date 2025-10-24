# 🎯 FASE 2 - PLAN DE ACCIÓN DETALLADO

## 📋 OVERVIEW FASE 2

**Objetivo:** Mejorar el flujo de publicación y asignación de fletes con más detalles, validaciones y automatización.

**Tiempo estimado:** 12-15 horas

**Prioridad:** Alta

---

## ✅ PREREQUISITO (ANTES DE EMPEZAR FASE 2)

### Testing E2E de Fase 1
**Tiempo:** 1-2 horas

1. **Crear Cliente de Prueba**
   - Ir a Firebase Console → Authentication
   - Agregar usuario: `cliente@test.com` / password: `Test123!`
   - Ir a Firestore → Collection `users`
   - Crear documento manualmente:
     ```json
     {
       "uid": "[UID del usuario]",
       "email": "cliente@test.com",
       "display_name": "Cliente Test",
       "tipo_usuario": "Cliente",
       "empresa": "Empresa Test FFWW",
       "phone_number": "+56912345678",
       "created_at": [timestamp],
       "updated_at": [timestamp]
     }
     ```

2. **Testing Flujo Completo**
   - Login como cliente → Publicar flete
   - Login como transportista → Ver flete disponible
   - Asignar chofer y camión
   - Login como chofer → Ver flete asignado
   - Completar checkpoints 1-5
   - Login como cliente → Ver progreso en tiempo real
   - ✅ Verificar que todo funciona

3. **Deploy a Netlify**
   - `git push origin main`
   - Esperar deploy de Netlify
   - Testing en producción
   - Hard refresh (Ctrl+Shift+R)

---

## 🚀 TAREAS DE FASE 2

### 📝 Tarea 2.1: Mejorar Formulario de Publicación de Flete
**Tiempo estimado:** 4-5 horas  
**Prioridad:** Alta  
**Archivos afectados:**
- `lib/screens/publicar_flete_page.dart`
- `lib/models/flete.dart`
- `lib/services/flete_service.dart`

#### Campos a Agregar:

**Información del Contenedor (ya existe, mejorar):**
- ✅ Tipo de Contenedor (dropdown mejorado con iconos)
  - CTN Std 20'
  - CTN Std 40'
  - CTN HC 40'
  - CTN OT (Open Top)
  - CTN Reefer 20'
  - CTN Reefer 40'
- ✅ Número de Contenedor (validación formato: XXXX123456-7)
- ⬜ **NUEVO:** Peso Bruto Total (kg)
- ⬜ **NUEVO:** Peso Neto Carga (kg)
- ⬜ **NUEVO:** Tara del Contenedor (kg)
- ⬜ **NUEVO:** ¿Contenedor con carga peligrosa? (Sí/No)
- ⬜ **NUEVO:** Clase de carga peligrosa (si aplica)

**Origen y Fechas (mejorar):**
- ✅ Puerto/Terminal de Origen (dropdown)
  - Puerto Valparaíso (TPS, TCVAL, STI)
  - Puerto San Antonio (SAAM, STI)
  - Puerto Santiago (ITS Lampa, Agrosuper)
  - Otro (especificar)
- ⬜ **NUEVO:** Fecha de Retiro del Contenedor (date picker)
- ⬜ **NUEVO:** Hora de Retiro (time picker)
- ⬜ **NUEVO:** Ventana Horaria (dropdown: 08:00-12:00, 12:00-16:00, 16:00-20:00)
- ⬜ **NUEVO:** ¿Retiro con cita previa? (toggle)
- ⬜ **NUEVO:** Número de Cita (si aplica)

**Destino y Entrega (mejorar):**
- ✅ Destino (texto)
- ⬜ **NUEVO:** Dirección Exacta (texto con validación)
- ⬜ **NUEVO:** Comuna (dropdown)
- ⬜ **NUEVO:** Ciudad (texto)
- ⬜ **NUEVO:** Región (dropdown)
- ⬜ **NUEVO:** Coordenadas GPS (mapa interactivo - opcional)
- ⬜ **NUEVO:** Persona de Contacto en Destino (texto)
- ⬜ **NUEVO:** Teléfono de Contacto (validación formato +56)
- ⬜ **NUEVO:** Fecha de Entrega Requerida (date picker)
- ⬜ **NUEVO:** Hora de Entrega (time picker)
- ⬜ **NUEVO:** Instrucciones Especiales de Entrega (textarea)

**Devolución de Contenedor Vacío:**
- ⬜ **NUEVO:** ¿Requiere devolución? (Sí/No)
- ⬜ **NUEVO:** Terminal de Devolución (dropdown - igual que origen)
- ⬜ **NUEVO:** Fecha Límite de Devolución (date picker)
- ⬜ **NUEVO:** Hora Límite de Devolución (time picker)
- ⬜ **NUEVO:** Número de Booking de Devolución (texto)

**Requisitos Especiales:**
- ⬜ **NUEVO:** ¿Requiere escolta? (toggle)
- ⬜ **NUEVO:** ¿Requiere rampa/montacargas? (toggle)
- ⬜ **NUEVO:** ¿Requiere personal de ayuda? (toggle + número de personas)
- ⬜ **NUEVO:** ¿Carga frágil? (toggle)
- ⬜ **NUEVO:** ¿Requiere temperatura controlada? (toggle + rango de temperatura)
- ⬜ **NUEVO:** Observaciones Adicionales (textarea)

**Servicios Adicionales:**
- ⬜ **NUEVO:** Seguro de Carga Extendido (toggle + valor asegurado)
- ⬜ **NUEVO:** Certificado de Entrega Digital (toggle)
- ⬜ **NUEVO:** Tracking GPS en Tiempo Real (toggle)
- ⬜ **NUEVO:** Notificaciones SMS/WhatsApp (toggle)

**Tarifa y Pago:**
- ✅ Tarifa Ofrecida (ya existe)
- ⬜ **NUEVO:** Tarifa Negociable (toggle)
- ⬜ **NUEVO:** Tarifa Mínima (si es negociable)
- ⬜ **NUEVO:** Tarifa Máxima (si es negociable)
- ⬜ **NUEVO:** Forma de Pago (dropdown: Transferencia, Efectivo, Cheque, Crédito 30 días)
- ⬜ **NUEVO:** ¿Incluye peajes? (Sí/No)
- ⬜ **NUEVO:** ¿Incluye combustible? (Sí/No)

#### Mejoras UI/UX:
- ⬜ Wizard de 4 pasos (Información Básica → Origen → Destino → Requisitos)
- ⬜ Validación paso a paso
- ⬜ Resumen final antes de publicar
- ⬜ Guardar como borrador
- ⬜ Duplicar flete anterior

#### Modelo Flete Actualizado:
```dart
class Flete {
  // ... campos existentes ...
  
  // Nuevos campos Fase 2
  final double? pesoBruto;
  final double? pesoNeto;
  final double? tara;
  final bool? cargaPeligrosa;
  final String? clasePeligrosa;
  
  final DateTime? fechaRetiro;
  final String? horaRetiro;
  final String? ventanaHoraria;
  final bool? requiereCita;
  final String? numeroCita;
  
  final String? direccionExacta;
  final String? comuna;
  final String? ciudad;
  final String? region;
  final String? coordenadasGPS;
  final String? personaContacto;
  final String? telefonoContacto;
  final DateTime? fechaEntrega;
  final String? horaEntrega;
  final String? instruccionesEntrega;
  
  final bool? requiereDevolucion;
  final String? terminalDevolucion;
  final DateTime? fechaLimiteDevolucion;
  final String? horaLimiteDevolucion;
  final String? numeroBookingDevolucion;
  
  final bool? requiereEscolta;
  final bool? requiereRampa;
  final bool? requierePersonal;
  final int? numeroPersonal;
  final bool? cargaFragil;
  final bool? requiereTemperatura;
  final String? rangoTemperatura;
  final String? observaciones;
  
  final bool? seguroExtendido;
  final double? valorAsegurado;
  final bool? certificadoDigital;
  final bool? trackingGPS;
  final bool? notificaciones;
  
  final bool? tarifaNegociable;
  final double? tarifaMinima;
  final double? tarifaMaxima;
  final String? formaPago;
  final bool? incluyePeajes;
  final bool? incluyeCombustible;
}
```

---

### 🎯 Tarea 2.2: Sistema de Tarifas Mínimas del Transportista
**Tiempo estimado:** 3-4 horas  
**Prioridad:** Media  
**Archivos afectados:**
- `lib/models/transportista.dart`
- `lib/screens/perfil_transportista_page.dart`
- `lib/screens/fletes_disponibles_transportista_page.dart`
- `lib/services/flete_service.dart`

#### Funcionalidades:

**Configuración de Tarifas (Perfil Transportista):**
- ⬜ Tarifa mínima por tipo de contenedor
  - CTN Std 20': $XXX
  - CTN Std 40': $XXX
  - CTN HC 40': $XXX
  - etc.
- ⬜ Tarifa por kilómetro adicional
- ⬜ Recargo por servicios especiales:
  - Escolta: +$XXX
  - Carga peligrosa: +$XXX o +XX%
  - Rampa/montacargas: +$XXX
  - Personal adicional: +$XXX por persona
  - Temperatura controlada: +$XXX

**Configuración de Filtros:**
- ⬜ Tipos de contenedor que acepta (multiselect)
- ⬜ Zonas de operación (comunas/regiones)
- ⬜ Distancia máxima desde origen (km)
- ⬜ Peso máximo que puede transportar
- ⬜ ¿Acepta carga peligrosa? (Sí/No)
- ⬜ ¿Acepta temperatura controlada? (Sí/No)
- ⬜ Horarios disponibles (rango horario)

**Filtrado Automático:**
- ⬜ Vista de Fletes Disponibles solo muestra:
  - Fletes con tarifa >= tarifa mínima del transportista
  - Fletes del tipo de contenedor que acepta
  - Fletes en zonas de operación configuradas
  - Fletes que cumplen requisitos especiales
- ⬜ Indicador visual de compatibilidad (%)
- ⬜ Cálculo de rentabilidad estimada

**Modelo Transportista Actualizado:**
```dart
class Transportista {
  // ... campos existentes ...
  
  // Configuración de tarifas
  final Map<String, double>? tarifasMinimas; // {"CTN_STD_20": 150000, ...}
  final double? tarifaPorKm;
  final Map<String, double>? recargosServicios; // {"escolta": 50000, ...}
  
  // Configuración de filtros
  final List<String>? tiposContenedorAceptados;
  final List<String>? zonasOperacion; // comunas/regiones
  final double? distanciaMaxima; // km
  final double? pesoMaximo; // kg
  final bool? aceptaCargaPeligrosa;
  final bool? aceptaTemperaturaControlada;
  final String? horariosDisponibles; // JSON string
}
```

---

### 📧 Tarea 2.3: Sistema de Notificaciones y Alertas
**Tiempo estimado:** 4-5 horas  
**Prioridad:** Media  
**Archivos afectados:**
- `lib/services/notification_service.dart` (nuevo)
- `lib/services/flete_service.dart`
- Firebase Functions (nuevo - opcional)

#### Notificaciones a Implementar:

**Al Transportista aceptar un flete:**
- ⬜ Email al Cliente con:
  - Datos del transportista
  - Datos del camión asignado
  - Datos del chofer
  - Documentación (semáforo)
  - Botón "Aceptar/Rechazar"
- ⬜ WhatsApp al Cliente (usando API de WhatsApp Business - opcional)

**Al Cliente aceptar el transportista:**
- ⬜ Email al Transportista confirmando
- ⬜ Notificación push al Chofer con instrucciones

**Al Chofer llegar a Checkpoint:**
- ⬜ Notificación push al Cliente
- ⬜ Email al Cliente con foto y timestamp

**24h antes de la fecha de entrega:**
- ⬜ Recordatorio al Chofer
- ⬜ Recordatorio al Cliente

**En caso de retraso (estimación GPS):**
- ⬜ Alerta automática al Cliente
- ⬜ Solicitud de nuevo ETA al Chofer

#### Implementación:

**Opción A: Cloud Functions (Recomendado)**
```javascript
// Firebase Functions
exports.onFleteAsignado = functions.firestore
  .document('fletes/{fleteId}')
  .onUpdate(async (change, context) => {
    if (change.after.data().estado === 'asignado') {
      // Enviar emails/notificaciones
    }
  });
```

**Opción B: Lógica en FleteService (Más simple)**
```dart
Future<void> notificarAsignacion(Flete flete) async {
  // Enviar email usando Firebase Extensions
  // Enviar notificación push usando FCM
}
```

**Servicios necesarios:**
- ⬜ Firebase Cloud Messaging (push notifications)
- ⬜ SendGrid o Firebase Email Extension
- ⬜ Twilio o WhatsApp Business API (opcional)

---

### 📊 Tarea 2.4: Dashboard de Cliente Mejorado
**Tiempo estimado:** 2-3 horas  
**Prioridad:** Baja  
**Archivos afectados:**
- `lib/screens/home_page.dart` (vista cliente)
- `lib/screens/fletes_cliente_detalle_page.dart`

#### Mejoras:

**Vista de Lista de Fletes:**
- ⬜ Filtros por estado (todos, disponibles, asignados, en tránsito, completados)
- ⬜ Búsqueda por número de contenedor
- ⬜ Ordenar por fecha, tarifa, estado
- ⬜ Vista de calendario de fletes programados
- ⬜ Estadísticas rápidas (total fletes, en curso, completados hoy)

**Vista Detalle de Flete:**
- ⬜ Timeline visual de checkpoints
- ⬜ Mapa con ruta en tiempo real (si tiene GPS)
- ⬜ ETA estimado
- ⬜ Galería de fotos expandible
- ⬜ Historial de cambios/eventos
- ⬜ Chat con chofer (opcional)
- ⬜ Botón "Reportar Problema"
- ⬜ Botón "Calificar Servicio" (al finalizar)

**Botón "Desistir" mejorado:**
- ⬜ Solo disponible en estados iniciales
- ⬜ Confirmar con razón de cancelación
- ⬜ Notificar al transportista

---

## 📋 CHECKLIST DE TAREAS FASE 2

### Prioridad Alta (hacer primero)
- [ ] 2.1.1 - Agregar campos nuevos al modelo Flete
- [ ] 2.1.2 - Crear wizard de 4 pasos para publicación
- [ ] 2.1.3 - Implementar validaciones
- [ ] 2.1.4 - Actualizar FirestoreService
- [ ] 2.1.5 - Testing de publicación completa
- [ ] 2.2.1 - Agregar campos de tarifa al modelo Transportista
- [ ] 2.2.2 - Vista de configuración de tarifas
- [ ] 2.2.3 - Implementar filtros automáticos
- [ ] 2.2.4 - Testing de filtrado

### Prioridad Media (después de alta)
- [ ] 2.3.1 - Configurar Firebase Cloud Messaging
- [ ] 2.3.2 - Implementar notificaciones push básicas
- [ ] 2.3.3 - Configurar SendGrid o Email Extension
- [ ] 2.3.4 - Implementar envío de emails
- [ ] 2.3.5 - Testing de notificaciones

### Prioridad Baja (si hay tiempo)
- [ ] 2.4.1 - Mejorar vista lista de fletes del cliente
- [ ] 2.4.2 - Mejorar vista detalle con timeline
- [ ] 2.4.3 - Implementar botón desistir mejorado
- [ ] 2.4.4 - Testing de dashboard

---

## 🎯 RESULTADO ESPERADO FASE 2

Al finalizar Fase 2, deberías tener:

✅ Formulario de publicación completo con todos los campos necesarios  
✅ Sistema de tarifas y filtros automáticos funcionando  
✅ Notificaciones básicas (al menos email)  
✅ Dashboard de cliente mejorado  
✅ Testing E2E completo de todo el flujo  
✅ Documentación actualizada  
✅ Deploy en producción (Netlify)  

---

## 📝 ORDEN SUGERIDO DE IMPLEMENTACIÓN

### DÍA 1 (3-4 horas)
1. Testing E2E de Fase 1 (1h)
2. Deploy a Netlify (30min)
3. Comenzar Tarea 2.1: Actualizar modelo Flete (2h)

### DÍA 2 (4-5 horas)
4. Continuar Tarea 2.1: Wizard paso 1 y 2 (4h)

### DÍA 3 (4-5 horas)
5. Continuar Tarea 2.1: Wizard paso 3 y 4 (3h)
6. Testing y ajustes (2h)

### DÍA 4 (3-4 horas)
7. Tarea 2.2: Sistema de tarifas (3h)
8. Testing de filtros (1h)

### DÍA 5 (2-3 horas) - Opcional
9. Tarea 2.3: Notificaciones básicas (2h)
10. Deploy final y documentación (1h)

---

## 🚨 IMPORTANTE

Después de cada subtarea:
1. ✅ Hacer commit con mensaje descriptivo
2. ✅ Testing básico en Flutter local
3. ✅ Actualizar documentación si es necesario
4. ✅ Deploy a Netlify cada 2-3 commits importantes

---

## 📊 MÉTRICAS ESPERADAS

**Tiempo Total Fase 2:** 12-15 horas  
**Archivos a crear:** ~3-4 nuevos  
**Archivos a modificar:** ~8-10  
**Líneas de código:** ~2,000 nuevas  
**Testing:** ~2-3 horas  

---

¿Listo para Fase 2? 🚀
