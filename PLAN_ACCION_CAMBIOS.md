# PLAN DE ACCIÓN - CARGOCLICK v2.0

## 📋 ANÁLISIS DE CAMBIOS REQUERIDOS

### CAMBIOS ARQUITECTÓNICOS PRINCIPALES

**Cambio de Modelo de Negocio:**
- **ANTES:** Chofer registra cuenta independiente → solicita fletes → cliente aprueba
- **AHORA:** Transportista registra cuenta → gestiona flota (camiones + choferes) → acepta fletes → asigna chofer

**Nuevo Rol: TRANSPORTISTA**
- Dueño de la empresa de transporte
- Gestiona su flota de camiones y choferes
- Recibe notificaciones de fletes según filtros
- Acepta fletes y asigna recursos

**Chofer Redefinido:**
- Ya NO es independiente
- Debe estar vinculado a un Transportista (código de invitación)
- Solo ve "Mis Recorridos" (fletes que le asignaron)
- Ejecuta checkpoints

---

## 🎯 PRIORIZACIÓN DE TAREAS

### Criterios de Priorización:
1. **Impacto Funcional:** ¿Bloquea otras funcionalidades?
2. **Dificultad Técnica:** ¿Cuánto tiempo/complejidad?
3. **Dependencias:** ¿Otras tareas dependen de esta?
4. **Valor de Negocio:** ¿Mejora la experiencia core?

### Escala:
- 🔴 **Crítico:** Bloquea el sistema completo
- 🟠 **Alto:** Necesario para MVP v2
- 🟡 **Medio:** Mejora importante pero no bloqueante
- 🟢 **Bajo:** Nice to have, puede esperar

---

## 📊 MATRIZ DE PRIORIDADES

| ID | Tarea | Impacto | Dificultad | Prioridad | Orden |
|----|-------|---------|------------|-----------|-------|
| 1.a | Registro Transportista | 🔴 Crítico | Media | 🔴 P1 | 1 |
| 1.c | Sistema Código Invitación | 🔴 Crítico | Baja | 🔴 P1 | 2 |
| 1.b | Panel Gestión Flota | 🟠 Alto | Alta | 🟠 P2 | 3 |
| 2.e | Asignación Chofer/Camión | 🔴 Crítico | Media | 🔴 P1 | 4 |
| 2.a | Formulario Flete Completo | 🟠 Alto | Media | 🟠 P2 | 5 |
| 3.a | Vista "Mis Recorridos" Chofer | 🟠 Alto | Baja | 🟠 P2 | 6 |
| 2.b | Tarifas Mínimas y Filtros | 🟡 Medio | Alta | 🟡 P3 | 7 |
| 2.c | Vista Fletes Disponibles (Transportista) | 🟠 Alto | Media | 🟠 P2 | 8 |
| 4.a | Detalle de Costos | 🟡 Medio | Media | 🟡 P3 | 9 |
| 4.b | Sistema Feedback/Rating | 🟢 Bajo | Baja | 🟡 P3 | 10 |
| 2.d | Alertas WhatsApp/Email | 🟢 Bajo | Alta | 🟢 P4 | 11 |
| 2.f | Instrucciones WhatsApp Chofer | 🟢 Bajo | Alta | 🟢 P4 | 12 |

---

## 🚀 PLAN DE ACCIÓN PASO A PASO

### **FASE 1: FUNDAMENTOS DEL NUEVO MODELO** (Semana 1)

#### ✅ **PASO 1: Crear Modelo y Registro de Transportista**
**Prioridad:** 🔴 Crítico | **Estimado:** 4 horas

**Subtareas:**
1. Crear modelo `Transportista` en `lib/models/transportista.dart`
2. Crear vista de registro `lib/screens/registro_transportista_page.dart`
3. Actualizar `AuthService` para soportar registro de transportista
4. Generar código de invitación único al crear cuenta
5. Actualizar Firestore rules para collection `transportistas`

**Campos del Modelo:**
```dart
class Transportista {
  String uid;
  String email;
  String razon_social;          // Nombre de la empresa
  String rut_empresa;
  String telefono;
  String codigo_invitacion;     // Código único para invitar choferes
  String tarifa_minima;         // Opcional para Fase 2
  DateTime created_at;
  DateTime updated_at;
}
```

**Estructura Firestore:**
```
/transportistas/{uid}
  - email
  - razon_social
  - rut_empresa
  - telefono
  - codigo_invitacion (generado automáticamente)
  - created_at
  - updated_at
```

**Archivos a Crear/Modificar:**
- ✅ `lib/models/transportista.dart` (nuevo)
- ✅ `lib/screens/registro_transportista_page.dart` (nuevo)
- ✅ `lib/services/auth_service.dart` (modificar)
- ✅ `firestore.rules` (agregar reglas para transportistas)

---

#### ✅ **PASO 2: Implementar Sistema de Código de Invitación**
**Prioridad:** 🔴 Crítico | **Estimado:** 3 horas

**Subtareas:**
1. Crear función para generar código único (6 dígitos alfanuméricos)
2. Mostrar código en perfil del transportista
3. Modificar registro de chofer para incluir campo "código de invitación"
4. Validar código al registrar chofer
5. Crear vínculo `transportista_id` en documento de chofer

**Lógica del Código:**
```dart
String generarCodigoInvitacion() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  Random rnd = Random();
  return String.fromCharCodes(
    Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length)))
  );
}
```

**Campos Nuevos en Chofer:**
```dart
class Chofer {
  String uid;
  String transportista_id;      // NUEVO: ID del transportista
  String codigo_invitacion;     // NUEVO: Código usado para registro
  // ... resto de campos existentes
}
```

**Estructura Firestore Actualizada:**
```
/users/{uid} (chofer)
  - tipoUsuario: "Chofer"
  - transportista_id: "uid_del_transportista"
  - codigo_invitacion: "ABC123"
  - email, display_name, phone_number...
```

**Archivos a Crear/Modificar:**
- ✅ `lib/models/usuario.dart` (agregar campo transportista_id)
- ✅ `lib/screens/registro_page.dart` (agregar input código)
- ✅ `lib/services/auth_service.dart` (validación código)
- ✅ `lib/screens/perfil_transportista_page.dart` (nuevo - mostrar código)

---

#### ✅ **PASO 3: Panel de Gestión de Flota (Básico)**
**Prioridad:** 🟠 Alto | **Estimado:** 6 horas

**Subtareas:**
1. Crear modelo `Camion` en `lib/models/camion.dart`
2. Crear vista de gestión de flota `lib/screens/gestion_flota_page.dart`
3. CRUD de camiones (crear, editar, eliminar)
4. CRUD de choferes vinculados (listar choferes del transportista)
5. Sistema de "semáforo" para documentación (verde/amarillo/rojo)

**Modelo Camión:**
```dart
class Camion {
  String id;
  String transportista_id;
  String patente;
  String tipo;                  // "CTN Std 20", "CTN Std 40", "HC", "OT", "reefer"
  String seguro_carga;         // Monto del seguro
  DateTime doc_vencimiento;    // Fecha vencimiento documentos
  String estado_documentacion; // "ok", "proximo_vencer", "vencido"
  bool disponible;
  DateTime created_at;
  DateTime updated_at;
}
```

**Estructura Firestore:**
```
/camiones/{camioneId}
  - transportista_id
  - patente
  - tipo
  - seguro_carga
  - doc_vencimiento
  - estado_documentacion
  - disponible
  - created_at
  - updated_at
```

**Sistema Semáforo:**
- 🟢 Verde: Documentos vigentes (>30 días)
- 🟡 Amarillo: Próximo a vencer (7-30 días)
- 🔴 Rojo: Vencido (<7 días o vencido)

**Archivos a Crear/Modificar:**
- ✅ `lib/models/camion.dart` (nuevo)
- ✅ `lib/screens/gestion_flota_page.dart` (nuevo)
- ✅ `lib/services/flota_service.dart` (nuevo)
- ✅ `firestore.rules` (reglas para camiones)

---

#### ✅ **PASO 4: Sistema de Asignación (Transportista → Chofer/Camión)**
**Prioridad:** 🔴 Crítico | **Estimado:** 5 horas

**Subtareas:**
1. Modificar flujo de aceptación de flete (Transportista, no Chofer)
2. Crear vista de asignación `lib/screens/asignar_flete_page.dart`
3. Listar choferes y camiones disponibles del transportista
4. Actualizar flete con `chofer_asignado` y `camion_asignado`
5. Notificar al chofer (básico: in-app, WhatsApp en Fase 4)

**Flujo Nuevo:**
```
1. Transportista ve "Fletes Disponibles"
2. Click "Aceptar Flete"
3. Modal/Vista: Asignar Chofer y Camión
4. Seleccionar de dropdown (solo choferes/camiones del transportista)
5. Confirmar asignación
6. Flete aparece en "Mis Recorridos" del chofer
```

**Campos Nuevos en Flete:**
```dart
class Flete {
  // ... campos existentes
  String transportista_id;      // NUEVO: ID del transportista que aceptó
  String chofer_asignado;       // ID del chofer asignado
  String camion_asignado;       // ID del camión asignado
  DateTime fecha_asignacion;
  // ...
}
```

**Archivos a Crear/Modificar:**
- ✅ `lib/models/flete.dart` (agregar campos)
- ✅ `lib/screens/asignar_flete_page.dart` (nuevo)
- ✅ `lib/services/flete_service.dart` (actualizar)
- ✅ `lib/screens/fletes_disponibles_transportista_page.dart` (nuevo)

---

#### ✅ **PASO 5: Actualizar Vista "Mis Recorridos" del Chofer**
**Prioridad:** 🟠 Alto | **Estimado:** 2 horas

**Subtareas:**
1. Modificar query: filtrar fletes donde `chofer_asignado == chofer.uid`
2. Ya NO mostrar "Fletes Disponibles" al chofer
3. Mantener funcionalidad de checkpoints existente

**Query Firestore:**
```dart
// ANTES:
.where('transportista_asignado', isEqualTo: choferUid)

// AHORA:
.where('chofer_asignado', isEqualTo: choferUid)
```

**Archivos a Modificar:**
- ✅ `lib/screens/home_page.dart` (eliminar tab "Disponibles" para chofer)
- ✅ `lib/screens/mis_recorridos_page.dart` (actualizar query)

---

### **FASE 2: MEJORAS EN FORMULARIOS Y VISTAS** (Semana 2)

#### ✅ **PASO 6: Completar Formulario de Publicación de Flete**
**Prioridad:** 🟠 Alto | **Estimado:** 4 horas

**Subtareas:**
1. Agregar campos faltantes al formulario
2. Implementar selector de tipo de contenedor (dropdown)
3. Agregar cálculo de peso (Carga Neta + Tara)
4. Selector de fecha/hora de carga (DateTimePicker)
5. Input de dirección destino + integración mapa (Google Maps opcional)
6. Campos: devolución CTN vacío, requisitos especiales, servicios adicionales

**Campos Nuevos en Flete:**
```dart
class Flete {
  // ... campos existentes
  String tipo_contenedor;       // "CTN Std 20/40", "HC", "OT", "reefer"
  double peso_carga_neta;       // kg
  double peso_tara;             // kg
  double peso_total;            // Calculado
  String puerto_origen;
  DateTime fecha_hora_carga;
  String direccion_destino;     // Dirección completa
  double destino_lat;           // Coordenadas para mapa
  double destino_lng;
  String devolucion_ctn_vacio;  // Dirección/instrucciones
  String requisitos_especiales; // Texto libre
  String servicios_adicionales; // Texto libre
  // ...
}
```

**Archivos a Modificar:**
- ✅ `lib/models/flete.dart` (agregar campos)
- ✅ `lib/screens/publicar_flete_page.dart` (agregar inputs)
- ✅ `pubspec.yaml` (agregar google_maps_flutter si necesario)

---

#### ✅ **PASO 7: Vista Fletes Disponibles para Transportista**
**Prioridad:** 🟠 Alto | **Estimado:** 3 horas

**Subtareas:**
1. Crear vista con lista de fletes `estado == "disponible"`
2. Card con info resumida (origen, destino, tipo CTN, tarifa, peso)
3. Botón "Aceptar Flete" → abre vista de asignación (Paso 4)
4. Filtros básicos (por tipo de contenedor, rango de tarifa)

**Query Firestore:**
```dart
.collection('fletes')
.where('estado', isEqualTo: 'disponible')
.orderBy('fecha_publicacion', descending: true)
```

**Archivos a Crear:**
- ✅ `lib/screens/fletes_disponibles_transportista_page.dart` (nuevo)
- ✅ `lib/widgets/flete_card_transportista.dart` (nuevo)

---

### **FASE 3: FUNCIONALIDADES AVANZADAS** (Semana 3)

#### ✅ **PASO 8: Sistema de Tarifas Mínimas y Filtros Automáticos**
**Prioridad:** 🟡 Medio | **Estimado:** 6 horas

**Subtareas:**
1. Agregar configuración de tarifas mínimas en perfil transportista
2. Filtros por: tipo de camión, origen, seguro mínimo, tarifa mínima
3. Query con filtros dinámicos
4. Notificación in-app cuando hay flete que cumple filtros

**Campos Nuevos en Transportista:**
```dart
class Transportista {
  // ... campos existentes
  double tarifa_minima;
  List<String> tipos_ctn_aceptados; // ["CTN Std 20", "HC", ...]
  List<String> puertos_origen;      // ["Valparaíso", "San Antonio", ...]
  double seguro_minimo_requerido;
  // ...
}
```

**Archivos a Crear/Modificar:**
- ✅ `lib/screens/configurar_filtros_page.dart` (nuevo)
- ✅ `lib/services/notificaciones_service.dart` (crear/modificar)

---

#### ✅ **PASO 9: Detalle de Costos y Facturación**
**Prioridad:** 🟡 Medio | **Estimado:** 4 horas

**Subtareas:**
1. Crear modelo `DetalleCosto`
2. Calcular costos al completar flete (tarifa base, extras, total)
3. Vista de resumen de costos para cliente y transportista
4. Exportar a PDF (opcional, usar package `pdf`)

**Modelo DetalleCosto:**
```dart
class DetalleCosto {
  String flete_id;
  double tarifa_base;
  double servicios_adicionales;
  double total;
  DateTime fecha_generacion;
}
```

**Archivos a Crear:**
- ✅ `lib/models/detalle_costo.dart` (nuevo)
- ✅ `lib/screens/detalle_costos_page.dart` (nuevo)
- ✅ `lib/services/facturacion_service.dart` (nuevo)

---

#### ✅ **PASO 10: Sistema de Feedback y Rating**
**Prioridad:** 🟡 Medio | **Estimado:** 3 horas

**Subtareas:**
1. Crear modelo `Rating`
2. Vista de calificación (1-5 estrellas + comentario)
3. Guardar rating en Firestore
4. Mostrar promedio de rating en perfil de transportista

**Modelo Rating:**
```dart
class Rating {
  String id;
  String flete_id;
  String cliente_id;
  String transportista_id;
  int puntaje;              // 1-5
  String comentario;
  DateTime created_at;
}
```

**Archivos a Crear:**
- ✅ `lib/models/rating.dart` (nuevo)
- ✅ `lib/screens/calificar_flete_page.dart` (nuevo)
- ✅ `lib/services/rating_service.dart` (nuevo)

---

### **FASE 4: AUTOMATIZACIONES Y NOTIFICACIONES** (Semana 4)

#### ✅ **PASO 11: Alertas WhatsApp/Email (Cliente ← Transportista)**
**Prioridad:** 🟢 Bajo | **Estimado:** 8 horas

**Subtareas:**
1. Configurar Firebase Cloud Functions
2. Integración con Twilio (WhatsApp) o SendGrid (Email)
3. Trigger: al aceptar flete, enviar alerta al cliente
4. Template: datos transportista, camión, chofer, documentación

**Requiere:**
- Firebase Cloud Functions (Node.js)
- Twilio API o SendGrid API
- Variables de entorno para API keys

**Archivos a Crear:**
- ✅ `functions/src/enviarAlertaCliente.js` (nuevo)
- ✅ `functions/src/templates/alertaAceptacion.js` (nuevo)

---

#### ✅ **PASO 12: Instrucciones WhatsApp al Chofer**
**Prioridad:** 🟢 Bajo | **Estimado:** 4 horas

**Subtareas:**
1. Trigger: al asignar chofer, enviar WhatsApp con instrucciones
2. Template: fecha, hora, origen, destino, tipo CTN, N° CTN, peso

**Archivos a Crear:**
- ✅ `functions/src/enviarInstruccionesChofer.js` (nuevo)

---

## 📁 ESTRUCTURA DE ARCHIVOS ACTUALIZADA

### Nuevos Archivos a Crear:

```
lib/
├── models/
│   ├── transportista.dart           ← NUEVO
│   ├── camion.dart                   ← NUEVO
│   ├── detalle_costo.dart           ← NUEVO
│   └── rating.dart                   ← NUEVO
│
├── services/
│   ├── flota_service.dart           ← NUEVO
│   ├── facturacion_service.dart     ← NUEVO
│   └── rating_service.dart          ← NUEVO
│
├── screens/
│   ├── registro_transportista_page.dart      ← NUEVO
│   ├── perfil_transportista_page.dart        ← NUEVO
│   ├── gestion_flota_page.dart               ← NUEVO
│   ├── fletes_disponibles_transportista_page.dart  ← NUEVO
│   ├── asignar_flete_page.dart               ← NUEVO
│   ├── configurar_filtros_page.dart          ← NUEVO
│   ├── detalle_costos_page.dart              ← NUEVO
│   └── calificar_flete_page.dart             ← NUEVO
│
└── widgets/
    └── flete_card_transportista.dart         ← NUEVO

functions/
└── src/
    ├── enviarAlertaCliente.js                ← NUEVO
    ├── enviarInstruccionesChofer.js          ← NUEVO
    └── templates/
        ├── alertaAceptacion.js               ← NUEVO
        └── instruccionesChofer.js            ← NUEVO
```

### Archivos a Modificar:

```
lib/
├── models/
│   ├── usuario.dart                  ← Agregar campo transportista_id
│   └── flete.dart                    ← Agregar campos (transportista_id, chofer_asignado, camion_asignado, etc.)
│
├── services/
│   ├── auth_service.dart             ← Agregar registro transportista, validación código
│   └── flete_service.dart            ← Actualizar asignación de fletes
│
├── screens/
│   ├── registro_page.dart            ← Agregar input código invitación
│   ├── home_page.dart                ← Ocultar tab "Disponibles" para chofer
│   ├── mis_recorridos_page.dart      ← Actualizar query (chofer_asignado)
│   └── publicar_flete_page.dart      ← Completar formulario
│
firestore.rules                        ← Agregar reglas para transportistas, camiones
firestore.indexes.json                 ← Agregar índices para nuevas queries
```

---

## 🔄 ACTUALIZACIÓN DE FLUJOS

### **FLUJO 1: Registro y Vinculación**

```
┌─────────────────────────────────────────────────────────┐
│  TRANSPORTISTA CREA CUENTA                               │
│  1. Registro con email/contraseña                        │
│  2. Sistema genera código invitación único (ej: "A3X7K2") │
│  3. Documento en /transportistas/{uid}                   │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│  TRANSPORTISTA GESTIONA FLOTA                            │
│  1. Agrega camiones (patente, tipo, seguro, docs)        │
│  2. Ve su código de invitación en perfil                 │
│  3. Comparte código con sus choferes                     │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│  CHOFER CREA CUENTA                                      │
│  1. Registro con email/contraseña                        │
│  2. Ingresa código de invitación del transportista      │
│  3. Sistema valida código y vincula chofer               │
│  4. Documento en /users/{uid} con transportista_id       │
└─────────────────────────────────────────────────────────┘
```

### **FLUJO 2: Publicación y Asignación de Flete**

```
┌─────────────────────────────────────────────────────────┐
│  CLIENTE PUBLICA FLETE                                   │
│  1. Completa formulario (origen, destino, CTN, peso...)  │
│  2. Sistema guarda en /fletes con estado: "disponible"  │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│  TRANSPORTISTA VE FLETES DISPONIBLES                     │
│  1. Lista filtrada según sus preferencias (opcional)     │
│  2. Ve detalles del flete                                │
│  3. Decide aceptar o no                                  │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼ (Click "Aceptar Flete")
┌─────────────────────────────────────────────────────────┐
│  TRANSPORTISTA ASIGNA RECURSOS                           │
│  1. Selecciona chofer de su flota                        │
│  2. Selecciona camión de su flota                        │
│  3. Sistema valida documentación (semáforo)              │
│  4. Confirma asignación                                  │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│  SISTEMA ACTUALIZA FLETE                                 │
│  1. estado: "asignado"                                   │
│  2. transportista_id: uid del transportista              │
│  3. chofer_asignado: uid del chofer                      │
│  4. camion_asignado: id del camión                       │
│  5. fecha_asignacion: timestamp                          │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│  CHOFER VE FLETE EN "MIS RECORRIDOS"                     │
│  1. Notificación in-app (o WhatsApp en Fase 4)           │
│  2. Ve detalles del flete asignado                       │
│  3. Ejecuta 5 checkpoints con fotos                      │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│  CLIENTE MONITOREA EN TIEMPO REAL                        │
│  1. Ve progreso (X/5 checkpoints)                        │
│  2. Ve fotos subidas por chofer                          │
│  3. Accede a ubicación GPS en tiempo real                │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼ (Al completar 5/5 checkpoints)
┌─────────────────────────────────────────────────────────┐
│  CIERRE DE OPERACIÓN                                     │
│  1. Sistema marca flete como "completado"                │
│  2. Genera detalle de costos (Fase 3)                    │
│  3. Cliente puede calificar (Fase 3)                     │
└─────────────────────────────────────────────────────────┘
```

---

## 🗂️ ACTUALIZACIÓN DE BASE DE DATOS

### **Collection: transportistas** (NUEVA)
```javascript
/transportistas/{uid}
{
  uid: string,
  email: string,
  razon_social: string,          // Nombre empresa
  rut_empresa: string,
  telefono: string,
  codigo_invitacion: string,     // Generado automáticamente
  tarifa_minima: number,         // Opcional (Fase 3)
  tipos_ctn_aceptados: [string], // Opcional (Fase 3)
  puertos_origen: [string],      // Opcional (Fase 3)
  created_at: Timestamp,
  updated_at: Timestamp
}
```

### **Collection: camiones** (NUEVA)
```javascript
/camiones/{camionId}
{
  id: string (auto),
  transportista_id: string,
  patente: string,
  tipo: string,                  // "CTN Std 20", "CTN Std 40", "HC", "OT", "reefer"
  seguro_carga: string,          // Monto del seguro
  doc_vencimiento: Timestamp,
  estado_documentacion: string,  // "ok", "proximo_vencer", "vencido"
  disponible: boolean,
  created_at: Timestamp,
  updated_at: Timestamp
}
```

### **Collection: users (ACTUALIZADA)**
```javascript
/users/{uid} (chofer)
{
  uid: string,
  email: string,
  display_name: string,
  role: "driver",
  transportista_id: string,      // ← NUEVO: ID del transportista
  codigo_invitacion: string,     // ← NUEVO: Código usado
  empresa: string,
  phone_number: string,
  created_at: Timestamp,
  updated_at: Timestamp
}
```

### **Collection: fletes (ACTUALIZADA)**
```javascript
/fletes/{fleteId}
{
  id: string,
  cliente_id: string,
  
  // ← NUEVOS CAMPOS:
  tipo_contenedor: string,       // "CTN Std 20/40", "HC", "OT", "reefer"
  numero_contenedor: string,
  peso_carga_neta: number,
  peso_tara: number,
  peso_total: number,            // Calculado
  puerto_origen: string,
  fecha_hora_carga: Timestamp,
  direccion_destino: string,
  destino_lat: number,
  destino_lng: number,
  devolucion_ctn_vacio: string,
  requisitos_especiales: string,
  servicios_adicionales: string,
  
  transportista_id: string,      // ← NUEVO: ID del transportista
  chofer_asignado: string,       // ← NUEVO: ID del chofer
  camion_asignado: string,       // ← NUEVO: ID del camión
  fecha_asignacion: Timestamp,
  
  // Campos existentes:
  origen: string,
  destino: string,
  tarifa: number,
  estado: string,
  fecha_publicacion: Timestamp,
  created_at: Timestamp,
  updated_at: Timestamp
}
```

### **Collection: ratings** (NUEVA - Fase 3)
```javascript
/ratings/{ratingId}
{
  id: string (auto),
  flete_id: string,
  cliente_id: string,
  transportista_id: string,
  puntaje: number,               // 1-5
  comentario: string,
  created_at: Timestamp
}
```

### **Collection: detalle_costos** (NUEVA - Fase 3)
```javascript
/detalle_costos/{fleteId}
{
  flete_id: string,
  tarifa_base: number,
  servicios_adicionales: number,
  total: number,
  fecha_generacion: Timestamp
}
```

---

## 🔒 ACTUALIZACIÓN DE FIRESTORE RULES

### Reglas para Transportistas:
```javascript
match /transportistas/{transportistaId} {
  allow read: if isAuthenticated();
  
  allow create: if isAuthenticated() 
    && request.auth.uid == transportistaId;
  
  allow update, delete: if isAuthenticated() 
    && request.auth.uid == transportistaId;
}
```

### Reglas para Camiones:
```javascript
match /camiones/{camionId} {
  allow read: if isAuthenticated();
  
  allow create, update, delete: if isAuthenticated() 
    && request.resource.data.transportista_id == request.auth.uid;
}
```

### Reglas Actualizadas para Fletes:
```javascript
match /fletes/{fleteId} {
  allow read: if isAuthenticated();
  
  allow create: if isAuthenticated() 
    && request.resource.data.cliente_id == request.auth.uid;
  
  allow update: if isAuthenticated() && (
    // Cliente puede actualizar su flete
    request.auth.uid == resource.data.cliente_id
    // Transportista puede actualizar flete asignado
    || request.auth.uid == resource.data.transportista_id
    // Chofer puede actualizar su flete asignado
    || request.auth.uid == resource.data.chofer_asignado
  );
  
  allow delete: if isAuthenticated() 
    && request.auth.uid == resource.data.cliente_id;
}
```

---

## 📊 ÍNDICES FIRESTORE ACTUALIZADOS

### Índices Nuevos Requeridos:

```json
{
  "indexes": [
    {
      "collectionGroup": "fletes",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "estado", "order": "ASCENDING"},
        {"fieldPath": "fecha_publicacion", "order": "DESCENDING"}
      ]
    },
    {
      "collectionGroup": "fletes",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "chofer_asignado", "order": "ASCENDING"},
        {"fieldPath": "fecha_asignacion", "order": "DESCENDING"}
      ]
    },
    {
      "collectionGroup": "camiones",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "transportista_id", "order": "ASCENDING"},
        {"fieldPath": "disponible", "order": "ASCENDING"}
      ]
    },
    {
      "collectionGroup": "users",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "transportista_id", "order": "ASCENDING"},
        {"fieldPath": "role", "order": "ASCENDING"}
      ]
    }
  ]
}
```

---

## ⚙️ CONFIGURACIÓN DE DEPENDENCIAS

### Nuevas Dependencias Requeridas:

```yaml
# pubspec.yaml

dependencies:
  # Existentes...
  
  # NUEVAS (Fase 2):
  google_maps_flutter: ^2.5.0        # Mapa en formulario flete
  intl: ^0.18.0                       # Formato de fechas/números
  
  # NUEVAS (Fase 3):
  pdf: ^3.10.0                        # Exportar PDF (detalle costos)
  flutter_rating_bar: ^4.0.1          # Widget de estrellas rating
  
  # NUEVAS (Fase 4 - Firebase Functions):
  # Instalar en functions/:
  # npm install twilio
  # npm install @sendgrid/mail
```

---

## 📝 CHECKLIST DE IMPLEMENTACIÓN

### **FASE 1: Fundamentos** (Semana 1)
- [ ] **1.1** Crear modelo `Transportista`
- [ ] **1.2** Vista de registro transportista
- [ ] **1.3** Función generar código invitación
- [ ] **1.4** Actualizar `AuthService` (registro transportista)
- [ ] **1.5** Modificar registro chofer (agregar input código)
- [ ] **1.6** Validación de código en registro chofer
- [ ] **1.7** Crear modelo `Camion`
- [ ] **1.8** Vista gestión de flota (CRUD camiones)
- [ ] **1.9** Sistema semáforo documentación
- [ ] **1.10** Vista asignación chofer/camión
- [ ] **1.11** Actualizar modelo `Flete` (campos transportista, chofer, camión)
- [ ] **1.12** Modificar query "Mis Recorridos" (filtrar por chofer_asignado)
- [ ] **1.13** Actualizar Firestore rules (transportistas, camiones)
- [ ] **1.14** Deploy de índices Firestore

### **FASE 2: Formularios y Vistas** (Semana 2)
- [ ] **2.1** Completar formulario publicación flete (todos los campos)
- [ ] **2.2** Agregar DateTimePicker (fecha/hora carga)
- [ ] **2.3** Integración Google Maps (opcional)
- [ ] **2.4** Vista "Fletes Disponibles" para transportista
- [ ] **2.5** Card con info resumida de flete
- [ ] **2.6** Botón "Aceptar Flete" con flujo completo
- [ ] **2.7** Testing de flujo completo (publicar → aceptar → asignar → ejecutar)

### **FASE 3: Funcionalidades Avanzadas** (Semana 3)
- [ ] **3.1** Configuración de tarifas mínimas (perfil transportista)
- [ ] **3.2** Filtros automáticos (tipo CTN, origen, tarifa)
- [ ] **3.3** Modelo `DetalleCosto`
- [ ] **3.4** Vista detalle de costos
- [ ] **3.5** Exportar PDF (opcional)
- [ ] **3.6** Modelo `Rating`
- [ ] **3.7** Vista calificar flete
- [ ] **3.8** Mostrar promedio rating en perfil transportista

### **FASE 4: Automatizaciones** (Semana 4)
- [ ] **4.1** Configurar Firebase Cloud Functions
- [ ] **4.2** Integración Twilio (WhatsApp)
- [ ] **4.3** Función enviar alerta al cliente (aceptación flete)
- [ ] **4.4** Función enviar instrucciones al chofer (asignación)
- [ ] **4.5** Templates de mensajes
- [ ] **4.6** Testing de notificaciones

---

## 🎯 DEFINICIÓN DE "DONE" POR FASE

### **FASE 1 COMPLETADA:**
✅ Transportista puede registrarse
✅ Transportista tiene código de invitación visible
✅ Chofer puede registrarse con código de invitación
✅ Transportista puede agregar/editar/eliminar camiones
✅ Transportista puede ver lista de choferes vinculados
✅ Sistema semáforo de documentación funciona
✅ Transportista puede aceptar flete y asignar chofer/camión
✅ Chofer solo ve fletes asignados a él en "Mis Recorridos"

### **FASE 2 COMPLETADA:**
✅ Formulario de flete tiene todos los campos solicitados
✅ Cliente puede publicar flete con info completa
✅ Transportista ve lista de fletes disponibles
✅ Transportista puede filtrar fletes (básico)
✅ Flujo completo funciona: publicar → ver → aceptar → asignar → ejecutar

### **FASE 3 COMPLETADA:**
✅ Transportista puede configurar tarifas mínimas y filtros
✅ Sistema filtra fletes automáticamente según preferencias
✅ Se genera detalle de costos al completar flete
✅ Cliente puede descargar PDF con detalle de costos
✅ Cliente puede calificar flete (1-5 estrellas + comentario)
✅ Promedio de rating visible en perfil de transportista

### **FASE 4 COMPLETADA:**
✅ Cliente recibe WhatsApp/Email al ser aceptado su flete
✅ Chofer recibe WhatsApp con instrucciones al ser asignado
✅ Templates de mensajes personalizados funcionando
✅ Sistema de notificaciones estable y probado

---

## 🚨 RIESGOS Y MITIGACIONES

### **Riesgo 1: Choferes existentes sin transportista**
**Impacto:** Alto - Choferes actuales no podrán usar la app
**Mitigación:**
1. Script de migración: asignar transportista temporal a choferes existentes
2. Crear transportista "Sin Asignar" como placeholder
3. Enviar email a choferes para que contacten su transportista

### **Riesgo 2: Fletes en curso sin camión asignado**
**Impacto:** Medio - Fletes actuales pueden romper queries
**Mitigación:**
1. Query con fallback: `chofer_asignado ?? transportista_asignado`
2. Script de migración: copiar `transportista_asignado` → `chofer_asignado`

### **Riesgo 3: Integración WhatsApp/Email costosa**
**Impacto:** Bajo - Puede exceder presupuesto
**Mitigación:**
1. Implementar primero notificaciones in-app (gratuito)
2. Fase 4 opcional, evaluar costo/beneficio antes de implementar
3. Alternativa: usar Firebase Cloud Messaging (push notifications)

### **Riesgo 4: Google Maps puede requerir billing**
**Impacto:** Medio - Formulario sin mapa
**Mitigación:**
1. Input de dirección texto como alternativa
2. Guardar lat/lng manualmente si es necesario
3. Evaluar si vale la pena habilitar billing de Google Maps

---

## 📈 MÉTRICAS DE ÉXITO

### **KPIs por Fase:**

**Fase 1:**
- ✅ 100% de transportistas pueden registrarse sin errores
- ✅ 100% de choferes pueden vincularse con código
- ✅ 0 fletes asignados sin chofer/camión

**Fase 2:**
- ✅ Formulario de flete completo usado en >80% de publicaciones
- ✅ Tiempo promedio de asignación <2 minutos

**Fase 3:**
- ✅ >50% de transportistas configuran filtros
- ✅ >70% de clientes califican fletes completados

**Fase 4:**
- ✅ >90% de notificaciones enviadas exitosamente
- ✅ <5% de errores en envío de WhatsApp/Email

---

## 🔄 ESTRATEGIA DE MIGRACIÓN DE DATOS

### **Script de Migración (Ejecutar antes de Fase 1):**

```javascript
// Firebase Console → Firestore → Ejecutar en Cloud Functions

const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();

async function migrarChoferes() {
  // 1. Crear transportista placeholder
  const placeholderRef = await db.collection('transportistas').add({
    email: 'placeholder@cargoclick.com',
    razon_social: 'Transportista Sin Asignar',
    rut_empresa: '00000000-0',
    telefono: '0000000000',
    codigo_invitacion: 'XXXXXX',
    created_at: admin.firestore.FieldValue.serverTimestamp(),
    updated_at: admin.firestore.FieldValue.serverTimestamp()
  });
  
  // 2. Actualizar choferes existentes
  const choferes = await db.collection('users')
    .where('role', '==', 'driver')
    .get();
  
  const batch = db.batch();
  choferes.forEach(doc => {
    batch.update(doc.ref, {
      transportista_id: placeholderRef.id,
      codigo_invitacion: 'LEGACY'
    });
  });
  await batch.commit();
  
  console.log(`✅ Migrados ${choferes.size} choferes`);
}

async function migrarFletes() {
  const fletes = await db.collection('fletes')
    .where('estado', 'in', ['asignado', 'en_proceso'])
    .get();
  
  const batch = db.batch();
  fletes.forEach(doc => {
    const data = doc.data();
    batch.update(doc.ref, {
      chofer_asignado: data.transportista_asignado || null,
      transportista_id: null,  // Se asignará cuando transportista acepte nuevamente
      camion_asignado: null
    });
  });
  await batch.commit();
  
  console.log(`✅ Migrados ${fletes.size} fletes`);
}

// Ejecutar:
migrarChoferes().then(() => migrarFletes());
```

---

## 🎉 RESUMEN EJECUTIVO

### **Cambio Principal:**
Transformar el modelo de **Chofer Independiente** a **Transportista → Chofer Empleado**.

### **Impacto:**
- **Usuarios:** Nuevo flujo de registro con código de invitación
- **Fletes:** Asignación en dos pasos (transportista acepta → asigna chofer/camión)
- **Base de Datos:** 2 collections nuevas (transportistas, camiones), campos nuevos en users y fletes

### **Esfuerzo Estimado:**
- **Fase 1 (Crítico):** 20 horas → 1 semana
- **Fase 2 (Alto):** 10 horas → 1 semana
- **Fase 3 (Medio):** 13 horas → 1 semana
- **Fase 4 (Bajo/Opcional):** 12 horas → 1 semana

**TOTAL: ~55 horas (4 semanas)**

### **Prioridad de Implementación:**
1. ✅ **Fase 1** - Sin esto, el sistema no funciona con el nuevo modelo
2. ✅ **Fase 2** - Mejora UX y completa funcionalidad core
3. ⚠️ **Fase 3** - Nice to have, puede esperar post-MVP
4. ⚠️ **Fase 4** - Opcional, evaluar necesidad real vs costo

### **Recomendación:**
**Implementar Fases 1 y 2 como MVP v2.0**, evaluar uso real antes de invertir en Fases 3 y 4.

---

**Última actualización:** 2025-01-24
**Versión del plan:** 1.0
**Estado:** ✅ Listo para implementación
