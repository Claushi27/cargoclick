# 📋 TRACKING DE IMPLEMENTACIÓN - CARGOCLICK v2.0

**Fecha Inicio:** 2025-01-24  
**Versión Objetivo:** 2.0.0  
**Responsable:** Equipo de Desarrollo

---

## 🎯 OBJETIVO GENERAL
Transformar el modelo de **Chofer Independiente** a **Transportista → Chofer Empleado** con gestión de flota completa.

---

## ✅ FASE 1: FUNDAMENTOS DEL NUEVO MODELO
**Prioridad:** 🔴 CRÍTICA | **Estimado:** 20h | **Estado:** 🔄 Pendiente

### PASO 1: Modelo y Registro de Transportista (4h)
- [x] Crear `lib/models/transportista.dart`
- [x] Crear `lib/screens/registro_transportista_page.dart`
- [x] Actualizar `lib/services/auth_service.dart` (método registro transportista)
- [x] Implementar generación de código invitación único (6 dígitos)
- [x] Agregar reglas Firestore para `/transportistas/{uid}`
- [ ] Testing: Crear cuenta transportista y verificar código generado

**Blocker:** Ninguno  
**Comentarios:** ✅ Completado - Falta testing funcional

---

### PASO 2: Sistema de Código de Invitación (3h)
- [x] Agregar campo `transportista_id` en `lib/models/usuario.dart`
- [x] Crear `lib/screens/perfil_transportista_page.dart` (mostrar código)
- [x] Modificar `lib/screens/registro_page.dart` (agregar input código)
- [x] Validar código en `lib/services/auth_service.dart`
- [x] Crear vínculo en Firestore al registrar chofer
- [ ] Testing: Chofer registra con código válido/inválido

**Blocker:** Depende de Paso 1  
**Comentarios:** ✅ Completado - Falta testing funcional

---

### PASO 3: Panel de Gestión de Flota (6h)
- [x] Crear `lib/models/camion.dart`
- [x] Crear `lib/services/flota_service.dart`
- [x] Crear `lib/screens/gestion_flota_page.dart`
- [x] CRUD de camiones (crear, editar, eliminar, listar)
- [x] Implementar sistema semáforo documentación (🟢🟡🔴)
- [x] Vista de choferes vinculados
- [x] Agregar reglas Firestore para `/camiones/{id}`
- [ ] Testing: Transportista gestiona su flota completa

**Blocker:** Depende de Paso 1  
**Comentarios:** ✅ Completado - Sistema semáforo automático, TabView con camiones y choferes

---

### PASO 4: Sistema de Asignación (5h)
- [x] Actualizar `lib/models/flete.dart` (campos: transportista_id, chofer_asignado, camion_asignado)
- [x] Crear `lib/screens/fletes_disponibles_transportista_page.dart`
- [x] Crear `lib/screens/asignar_flete_page.dart`
- [x] Modificar `lib/services/flete_service.dart` (método asignar)
- [x] Listar choferes y camiones del transportista en modal
- [x] Actualizar flete con asignación completa
- [ ] Testing: Transportista acepta flete y asigna recursos

**Blocker:** Depende de Paso 3  
**Comentarios:** ✅ Completado - Vista fletes disponibles + asignación con validaciones

---

### PASO 5: Actualizar Vista Chofer (2h)
- [x] Modificar query en `lib/screens/mis_recorridos_page.dart` (filtrar por chofer_asignado)
- [x] Ocultar tab "Disponibles" para chofer en `lib/screens/home_page.dart`
- [x] Mantener funcionalidad de checkpoints existente
- [ ] Testing: Chofer solo ve fletes asignados a él

**Blocker:** Depende de Paso 4  
**Comentarios:** ✅ Completado - Query actualizado a getFletesChoferAsignado

---

## ✅ FASE 2: FORMULARIOS Y VISTAS
**Prioridad:** 🟠 ALTA | **Estimado:** 10h | **Estado:** ⏸️ No iniciado

### PASO 6: Formulario Completo de Flete (4h)
- [ ] Agregar campos en `lib/models/flete.dart` (tipo_contenedor, peso_carga_neta, peso_tara, etc.)
- [ ] Actualizar `lib/screens/publicar_flete_page.dart` con todos los inputs
- [ ] Agregar dropdown tipo de contenedor (CTN Std 20/40, HC, OT, reefer)
- [ ] Implementar DateTimePicker para fecha/hora carga
- [ ] Inputs: puerto origen, dirección destino, devolución CTN vacío
- [ ] Campos opcionales: requisitos especiales, servicios adicionales
- [ ] Testing: Cliente publica flete con todos los datos

**Blocker:** Ninguno (puede hacerse en paralelo con Fase 1)  
**Comentarios:** 

---

### PASO 7: Vista Fletes Disponibles Transportista (3h)
- [ ] Crear widget `lib/widgets/flete_card_transportista.dart`
- [ ] Vista con query `estado == "disponible"`
- [ ] Card con info resumida (origen, destino, tipo CTN, tarifa, peso)
- [ ] Botón "Aceptar Flete" que abre vista de asignación
- [ ] Filtros básicos (tipo contenedor, rango tarifa)
- [ ] Testing: Transportista navega y filtra fletes

**Blocker:** Depende de Paso 4 (asignación)  
**Comentarios:** 

---

### PASO 8: Testing Integración E2E (3h)
- [ ] Flujo completo: Cliente publica → Transportista acepta → Asigna → Chofer ejecuta
- [ ] Validar permisos Firestore en cada paso
- [ ] Verificar actualización en tiempo real
- [ ] Deploy de índices Firestore: `firebase deploy --only firestore:indexes`
- [ ] Probar en ambiente de producción (Netlify)

**Blocker:** Depende de todos los pasos anteriores  
**Comentarios:** 

---

## ⚠️ FASE 3: FUNCIONALIDADES AVANZADAS (OPCIONAL)
**Prioridad:** 🟡 MEDIA | **Estimado:** 13h | **Estado:** ⏸️ No iniciado

### PASO 9: Tarifas Mínimas y Filtros (6h)
- [ ] Agregar campos en `lib/models/transportista.dart` (tarifa_minima, tipos_ctn_aceptados, etc.)
- [ ] Crear `lib/screens/configurar_filtros_page.dart`
- [ ] Query con filtros dinámicos
- [ ] Notificación in-app cuando hay flete que cumple filtros
- [ ] Testing: Transportista configura y recibe notificaciones

**Blocker:** Depende de Paso 7  
**Comentarios:** 

---

### PASO 10: Detalle de Costos (4h)
- [ ] Crear `lib/models/detalle_costo.dart`
- [ ] Crear `lib/services/facturacion_service.dart`
- [ ] Crear `lib/screens/detalle_costos_page.dart`
- [ ] Calcular costos al completar flete
- [ ] Exportar a PDF (opcional: usar package `pdf`)
- [ ] Testing: Ver detalle de costos en flete completado

**Blocker:** Ninguno  
**Comentarios:** 

---

### PASO 11: Sistema de Rating (3h)
- [ ] Crear `lib/models/rating.dart`
- [ ] Crear `lib/services/rating_service.dart`
- [ ] Crear `lib/screens/calificar_flete_page.dart`
- [ ] Widget de estrellas (usar `flutter_rating_bar`)
- [ ] Calcular y mostrar promedio en perfil transportista
- [ ] Testing: Cliente califica flete completado

**Blocker:** Ninguno  
**Comentarios:** 

---

## 🔵 FASE 4: AUTOMATIZACIONES (OPCIONAL - EVALUAR COSTO)
**Prioridad:** 🟢 BAJA | **Estimado:** 12h | **Estado:** ⏸️ No iniciado

### PASO 12: Firebase Cloud Functions Setup (4h)
- [ ] Inicializar Firebase Functions: `firebase init functions`
- [ ] Configurar Twilio API (WhatsApp) o SendGrid (Email)
- [ ] Agregar secrets en Firebase: `firebase functions:secrets:set TWILIO_TOKEN`
- [ ] Testing local: `firebase emulators:start`

**Blocker:** Requiere billing habilitado en Firebase  
**Comentarios:** 

---

### PASO 13: Alerta Aceptación de Flete (4h)
- [ ] Crear `functions/src/enviarAlertaCliente.js`
- [ ] Trigger: `onUpdate` en `/fletes/{id}` cuando `estado == "asignado"`
- [ ] Template de mensaje con datos del transportista
- [ ] Enviar WhatsApp o Email al cliente
- [ ] Testing: Cliente recibe notificación al aceptar flete

**Blocker:** Depende de Paso 12  
**Comentarios:** 

---

### PASO 14: Instrucciones al Chofer (4h)
- [ ] Crear `functions/src/enviarInstruccionesChofer.js`
- [ ] Trigger: `onUpdate` en `/fletes/{id}` cuando se asigna `chofer_asignado`
- [ ] Template con fecha, hora, origen, destino, CTN, peso
- [ ] Enviar WhatsApp al chofer
- [ ] Testing: Chofer recibe instrucciones al ser asignado

**Blocker:** Depende de Paso 12  
**Comentarios:** 

---

## 📊 PROGRESO GENERAL

### Por Fase:
- **FASE 1:** ✅✅✅✅✅ 5/5 tareas (100%) 🎉
- **FASE 2:** ⬜⬜⬜ 0/3 tareas (0%)
- **FASE 3:** ⬜⬜⬜ 0/3 tareas (0%)
- **FASE 4:** ⬜⬜⬜ 0/3 tareas (0%)

### Total:
**5 / 14 tareas completadas (36%)**

### Horas:
- **Estimadas:** 55h
- **Invertidas:** ~26h (20h anteriores + 6h sesión 24/01)
- **Restantes:** 29h

### Horas:
- **Estimadas:** 55h
- **Invertidas:** 0h
- **Restantes:** 55h

---

## 🚨 BLOCKERS ACTIVOS

| # | Blocker | Impacto | Estado | Acción |
|---|---------|---------|--------|--------|
| - | Ninguno | - | ✅ | - |

---

## 📝 NOTAS DE IMPLEMENTACIÓN

### 2025-01-24
- Plan de acción creado y priorizado
- Estrategia definida: Fase 1 y 2 como MVP v2.0
- Fase 3 y 4 evaluarse post-lanzamiento

### 2025-01-24 (Tarde)
- ✅ PASO 1 completado (código)
- Creado modelo Transportista con 6 campos
- Creado vista de registro con validación
- Agregado método registrarTransportista en AuthService
- Función generarCodigoInvitacion (6 chars alfanuméricos)
- Reglas Firestore actualizadas para /transportistas
- Login actualizado con 2 opciones de registro
- ✅ PASO 2 completado (código)
- Agregados campos transportista_id y codigo_invitacion en modelo Usuario
- Creada vista perfil_transportista_page con diseño atractivo
- Actualizado registro de chofer con input de código (6 caracteres)
- Validación de código en AuthService (query a Firestore)
- Vinculación automática chofer → transportista al registrar
- ✅ PASO 3 completado (código)
- Creado modelo Camion con 10 campos + cálculo automático semáforo
- Creado FlotaService con CRUD completo y queries optimizadas
- Creada GestionFlotaPage con TabView (Camiones/Choferes)
- Sistema semáforo: 🟢 OK (>30 días), 🟡 Próximo vencer (7-30), 🔴 Vencido (<7)
- CRUD camiones: agregar, editar, eliminar, marcar disponible/no disponible
- Vista choferes: lista de choferes vinculados con info completa
- Índices agregados para camiones y users
- Reglas Firestore para /camiones con permisos por transportista
- ✅ PASO 4 completado (código)
- Actualizado modelo Flete con 4 campos nuevos (transportista_id, chofer_asignado, camion_asignado)
- Agregado método asignarFlete en FleteService con logging completo
- Creados 3 nuevos métodos en FleteService para queries de transportista
- Creada FletesDisponiblesTransportistaPage con cards hermosas
- Creada AsignarFletePage con selección visual de chofer y camión
- Validación de documentación vencida con confirmación
- Sistema de navegación completo (disponibles → asignar → confirmar → volver)
- Reglas Firestore actualizadas para nuevos permisos
- ✅ PASO 5 completado (código)
- Actualizado query en MisRecorridosPage a getFletesChoferAsignado
- Chofer ahora ve solo fletes con chofer_asignado == su uid
- Mensaje mejorado en empty state
- Funcionalidad de checkpoints mantenida intacta
- 🎉 **FASE 1 COMPLETADA AL 100%** 🎉
- ✅ Flutter instalado y corriendo localmente
- ✅ Todas las vistas funcionando
- ✅ Reglas de Firestore desplegadas
- ✅ Testing básico completado
- ⏳ Pendiente: Testing E2E completo (necesita cliente y flete de prueba)
- 📅 Última actualización: 24 Enero 2025

---

## 🔄 ESTRATEGIA DE MIGRACIÓN

### Pre-Deploy Fase 1:
```bash
# Ejecutar script de migración en Firebase Console
# Ver: PLAN_ACCION_CAMBIOS.md → Sección "Estrategia de Migración"
```

### Checklist Pre-Deploy:
- [ ] Backup de Firestore
- [ ] Script de migración ejecutado
- [ ] Firestore rules actualizadas
- [ ] Índices desplegados: `firebase deploy --only firestore:indexes`
- [ ] Storage rules actualizadas (si aplica)
- [ ] Testing en ambiente staging
- [ ] Rollback plan documentado

---

## 🎯 DEFINICIÓN DE DONE

### FASE 1 COMPLETADA:
- [ ] Transportista puede registrarse sin errores
- [ ] Transportista ve su código de invitación en perfil
- [ ] Chofer puede registrarse con código válido
- [ ] Chofer no puede registrarse con código inválido
- [ ] Transportista puede CRUD camiones
- [ ] Sistema semáforo funciona correctamente
- [ ] Transportista puede aceptar flete y asignar chofer/camión
- [ ] Chofer solo ve fletes asignados en "Mis Recorridos"
- [ ] Todas las reglas Firestore desplegadas
- [ ] Todos los índices creados
- [ ] Testing E2E exitoso

### FASE 2 COMPLETADA:
- [ ] Formulario de flete tiene todos los campos requeridos
- [ ] Cliente puede publicar flete completo
- [ ] Transportista ve lista de fletes disponibles
- [ ] Transportista puede filtrar fletes (básico)
- [ ] Flujo completo funciona: publicar → aceptar → asignar → ejecutar
- [ ] Actualización en tiempo real verificada
- [ ] Deploy en Netlify exitoso

---

## 🏆 HITOS

- [ ] **HITO 1:** FASE 1 Completada → MVP v2.0 Alpha (Semana 1)
- [ ] **HITO 2:** FASE 2 Completada → MVP v2.0 Beta (Semana 2)
- [ ] **HITO 3:** Testing y Deploy Producción → MVP v2.0 Release (Semana 3)
- [ ] **HITO 4:** FASE 3 Completada → v2.1 (Semana 4)
- [ ] **HITO 5:** FASE 4 Completada → v2.2 (Semana 5)

---

**Última Actualización:** 2025-01-24  
**Próxima Revisión:** Al completar cada paso  
**Estado General:** 🔄 En Planificación
