# CARGOCLICK - CONTEXTO COMPLETO DEL PROYECTO

## DESCRIPCIÓN
Marketplace para transporte de carga marítimo que conecta Clientes/Admin (quienes publican fletes) con Choferes (quienes los aceptan y ejecutan). Sistema de seguimiento en tiempo real con checkpoints fotográficos y geolocalización.

## ROLES DE USUARIO

### CLIENTE/ADMIN
- **Gestión de fletes:**
  - Publica fletes nuevos con origen, destino, tarifa, peso
  - Ve lista de todos sus fletes publicados
  - Monitorea progreso en tiempo real (barra de progreso de checkpoints)
  
- **Gestión de solicitudes:**
  - Recibe solicitudes de choferes para sus fletes
  - Aprueba o rechaza solicitudes
  - Asigna flete al chofer aprobado
  
- **Monitoreo en tiempo real:**
  - Ve checkpoints completados con fotos
  - Accede a links GPS en tiempo real compartidos por choferes
  - Puede expandir cada checkpoint para ver detalles, fotos y notas
  - Actualización automática sin recargar página (StreamBuilder)

### CHOFER
- **Registro:** Único rol que puede registrarse en la app
- **Solicitud de fletes:**
  - Ve fletes disponibles y solicitados
  - Solicita fletes (cambia estado a "solicitado")
  - Espera aprobación del cliente
  
- **Ejecución de fletes:**
  - Ve "Mis Recorridos" (fletes asignados)
  - Completa 5 checkpoints obligatorios con fotos
  - Puede agregar links GPS en tiempo real (Google Maps, etc.)
  - Agrega notas opcionales en cada checkpoint
  - Sube entre 1-2 fotos por checkpoint según requerimientos

**IMPORTANTE:** 
- No hay registro de clientes, solo choferes pueden registrarse
- Clientes se crean manualmente en Firestore
- Cada flete requiere 5 checkpoints obligatorios para completarse

---

## FLUJOS CRÍTICOS

### 1. REGISTRO (Solo Choferes)
```
1. Usuario llena formulario registro
2. Firebase Auth crea cuenta
3. Documento en users/ con tipoUsuario: "Chofer"
4. Redirect a vista choferes (Tab Disponibles)
```

### 2. PUBLICAR FLETE (Solo Cliente)
```
1. Cliente llena formulario con todos los datos del flete
2. Crear documento en fletes/ con estado: "disponible"
3. Flete aparece en lista principal del cliente
4. Flete visible para todos los choferes en "Disponibles"
```

### 3. SOLICITAR FLETE (Chofer)
```
1. Chofer ve lista "Fletes Disponibles"
2. Click "Aceptar" en un flete
3. Crear documento en /solicitudes/{fleteId}/solicitantes/{choferId}
4. Actualizar flete.estado = "solicitado"
5. Notificación al cliente (opcional)
6. Flete sigue visible con badge "Pendiente de aprobación"
```

### 4. APROBAR SOLICITUD (Cliente)
```
1. Cliente ve "Solicitudes de Choferes" (botón en AppBar)
2. Click "Aprobar" en una solicitud
3. Actualizar solicitud.status = "approved"
4. Actualizar flete.estado = "asignado"
5. Actualizar flete.transportista_asignado = choferId
6. Notificación al chofer (opcional)
7. Flete aparece en "Mis Recorridos" del chofer
```

### 5. COMPLETAR CHECKPOINTS (Chofer)
```
1. Chofer en "Mis Recorridos" → Click en flete asignado
2. Vista detalle muestra 5 checkpoints pendientes
3. Click "Subir" en un checkpoint
4. Seleccionar fuente: Cámara o Galería
5. Seleccionar fotos requeridas (1-2 según checkpoint)
6. Si es "Ubicación GPS": puede agregar link GPS en tiempo real
7. Agregar nota opcional
8. Subir → Fotos a Storage: /fletes/{fleteId}/checkpoints/{tipo}/{archivo}
9. Guardar checkpoint en Firestore: /fletes/{fleteId}/checkpoints/{tipo}
10. Estado del flete cambia a "en_proceso"
11. Al completar 5/5 checkpoints → flete.estado = "completado"
12. Cliente ve actualización en tiempo real
```

### 6. MONITOREAR FLETE (Cliente)
```
1. Cliente en Home → Click en un flete
2. Vista detalle muestra:
   - Info del flete (origen, destino, peso, tarifa)
   - Barra de progreso (ej: 3/5 checkpoints)
   - Lista de 5 checkpoints con estados
3. Expandir checkpoint completado para ver:
   - Fotos en grid 3x3
   - Notas del chofer
   - Link GPS (si existe) con botón "Ver ubicación en tiempo real"
4. Actualización automática con StreamBuilder
```

---

## ESTADOS DEL FLETE (Ciclo de Vida)

```
disponible → solicitado → asignado → en_proceso → completado
```

| Estado | Descripción | Trigger | Quién lo ve |
|--------|-------------|---------|-------------|
| **disponible** | Flete publicado, esperando solicitudes | Cliente crea flete | Cliente, Todos los choferes |
| **solicitado** | Chofer envió solicitud, esperando aprobación | Chofer acepta flete | Cliente, Chofer solicitante |
| **asignado** | Cliente aprobó solicitud, chofer puede empezar | Cliente aprueba solicitud | Cliente, Chofer asignado |
| **en_proceso** | Chofer subió al menos 1 checkpoint | Chofer sube primer checkpoint | Cliente, Chofer asignado |
| **completado** | Chofer completó 5/5 checkpoints | Sistema detecta 5 checkpoints | Cliente, Chofer asignado |

**TRANSICIONES:**
```
Cliente → Publicar → disponible
Chofer → Aceptar → solicitado
Cliente → Aprobar → asignado
Chofer → Subir checkpoint 1 → en_proceso
Sistema → 5 checkpoints completados → completado
```

---

## ESTRUCTURA DE DATOS

### Collection: users
```javascript
{
  uid: string,
  email: string,
  display_name: string,
  role: "admin" | "driver",  // Solo "driver" puede registrarse
  empresa: string,
  phone_number: string,
  created_at: Timestamp,
  updated_at: Timestamp
}
```

### Collection: fletes
```javascript
{
  id: string (auto),
  cliente_id: string (uid del admin que lo creó),
  tipo_contenedor: string,
  numero_contenedor: string,
  peso: number,
  origen: string,
  destino: string,
  tarifa: number,
  status: "disponible" | "solicitado" | "en_proceso" | "completado",
  fecha_publicacion: Timestamp,
  chofer_asignado: string | null,
  transportista_id: string | null,
  fecha_asignacion: Timestamp | null,
  fotos: [
    {
      url: string,
      timestamp: Timestamp,
      chofer_id: string
    }
  ],
  created_at: Timestamp,
  updated_at: Timestamp
}
```

### Collection: solicitudes (estructura anidada)
```javascript
// Documento padre (vacío, solo contenedor)
/solicitudes/{fleteId}

// Subcollection: solicitantes
/solicitudes/{fleteId}/solicitantes/{choferId}
{
  flete_id: string,
  chofer_id: string,
  cliente_id: string,
  status: "pending" | "approved" | "rejected",
  created_at: Timestamp,
  updated_at: Timestamp,
  flete_resumen: {
    numero_contenedor: string,
    origen: string,
    destino: string
  },
  chofer_resumen: {
    uid: string,
    nombre: string (opcional)
  }
}
```

### Collection: checkpoints (subcollection de fletes)
```javascript
/fletes/{fleteId}/checkpoints/{tipo}
{
  tipo: "retiro_unidad" | "ubicacion_gps" | "llegada_cliente" | "salida_cliente" | "entrega_unidad_vacia",
  chofer_id: string,
  timestamp: Timestamp,
  ubicacion: { lat: number, lng: number } | null,
  gps_link: string | null, // Link GPS en tiempo real (Google Maps, etc)
  fotos: [
    {
      url: string,
      storage_path: string,
      nombre: string,
      created_at: Timestamp
    }
  ],
  notas: string | null,
  completado: boolean,
  created_at: Timestamp
}
```

**5 Checkpoints Obligatorios:**
1. **retiro_unidad** - Retiro de Unidad (2 fotos: contenedor y sello)
2. **ubicacion_gps** - Ubicación GPS (1 foto + link GPS opcional)
3. **llegada_cliente** - Llegada al Cliente (2 fotos: lugar y GPS con hora)
4. **salida_cliente** - Salida del Cliente (1 foto: guía firmada)
5. **entrega_unidad_vacia** - Entrega Unidad Vacía (1 foto: Interchange)

---

## FIRESTORE SECURITY RULES

**Archivo:** `firestore.rules`

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(uid) {
      return isAuthenticated() && request.auth.uid == uid;
    }

    // Users: cada usuario gestiona su propio documento
    match /users/{uid} {
      allow create: if isAuthenticated() && request.auth.uid == uid;
      allow read, update, delete: if isOwner(uid);
    }

    // Fletes: lectura pública autenticada, escritura controlada
    match /fletes/{fleteId} {
      allow read: if isAuthenticated();
      
      allow create: if isAuthenticated() 
        && request.resource.data.cliente_id == request.auth.uid;
      
      allow update: if isAuthenticated() && (
        request.auth.uid == resource.data.cliente_id
        || (resource.data.transportista_asignado != null 
            && request.auth.uid == resource.data.transportista_asignado)
        || (resource.data.estado == 'disponible' 
            && request.resource.data.estado == 'solicitado')
      );
      
      allow delete: if isAuthenticated() 
        && request.auth.uid == resource.data.cliente_id;

      // Subcollection: checkpoints
      match /checkpoints/{checkpointId} {
        allow read: if isAuthenticated();
        
        allow create, update: if isAuthenticated() && (
          (exists(/databases/$(database)/documents/fletes/$(fleteId))
           && get(/databases/$(database)/documents/fletes/$(fleteId)).data.transportista_asignado == request.auth.uid)
          || (exists(/databases/$(database)/documents/fletes/$(fleteId))
              && get(/databases/$(database)/documents/fletes/$(fleteId)).data.cliente_id == request.auth.uid)
        );
        
        allow delete: if isAuthenticated()
          && exists(/databases/$(database)/documents/fletes/$(fleteId))
          && get(/databases/$(database)/documents/fletes/$(fleteId)).data.cliente_id == request.auth.uid;
      }
      
      // Subcollection: fotos (legacy)
      match /fotos/{fotoId} {
        allow read: if isAuthenticated();
        
        allow create, update: if isAuthenticated() && (
          (exists(/databases/$(database)/documents/fletes/$(fleteId))
           && get(/databases/$(database)/documents/fletes/$(fleteId)).data.transportista_asignado == request.auth.uid)
          || (exists(/databases/$(database)/documents/fletes/$(fleteId))
              && get(/databases/$(database)/documents/fletes/$(fleteId)).data.cliente_id == request.auth.uid)
        );
        
        allow delete: if isAuthenticated()
          && exists(/databases/$(database)/documents/fletes/$(fleteId))
          && get(/databases/$(database)/documents/fletes/$(fleteId)).data.cliente_id == request.auth.uid;
      }
    }

    // Solicitudes: estructura anidada
    match /solicitudes/{fleteId} {
      allow read: if isAuthenticated();
      allow write: if false; // Documento padre es solo contenedor

      // Subcollection: solicitantes
      match /solicitantes/{choferId} {
        allow read: if isAuthenticated();
        
        allow create: if isAuthenticated() 
          && request.auth.uid == choferId
          && request.resource.data.chofer_id == request.auth.uid;
        
        allow update: if isAuthenticated() && (
          request.auth.uid == choferId
          || request.auth.uid == resource.data.cliente_id
        );
        
        allow delete: if isAuthenticated() && (
          request.auth.uid == choferId
          || request.auth.uid == resource.data.cliente_id
        );
      }
    }
    
    // Permitir collectionGroup queries
    match /{path=**}/solicitantes/{choferId} {
      allow read: if isAuthenticated();
    }
    
    match /{path=**}/fotos/{fotoId} {
      allow read: if isAuthenticated();
    }

    // Catch-all
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

---

## STORAGE SECURITY RULES

**Archivo:** `storage.rules`

```javascript
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    
    function isAuthenticated() {
      return request.auth != null;
    }

    // Todas las fotos de fletes - PÚBLICO para lectura (necesario para web)
    match /fletes/{fleteId}/{allPaths=**} {
      allow read: if true;  // Público - permite cargar imágenes en web sin CORS
      allow write: if isAuthenticated();  // Solo autenticados pueden subir
    }

    // Fotos de perfil de usuarios
    match /users/{userId}/profile/{fileName} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated() && request.auth.uid == userId;
    }

    // Denegar todo lo demás
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

**IMPORTANTE - Configuración CORS:**

Las reglas de Storage NO controlan CORS. Para que las imágenes se vean en web, necesitas configurar CORS en Google Cloud Storage:

```bash
# En Cloud Shell de Google Cloud Console:
echo '[{"origin":["*"],"method":["GET","HEAD","PUT","POST","DELETE"],"responseHeader":["Content-Type"],"maxAgeSeconds":3600}]' > cors.json && gsutil cors set cors.json gs://sellora-2xtskv.firebasestorage.app
```

Sin CORS configurado, las imágenes NO se cargarán en la aplicación web desplegada.

---

## ÍNDICES FIRESTORE REQUERIDOS

**Archivo:** `firestore.indexes.json`

### Índices Compuestos (en archivo JSON):

1. **fletes** - Para vista cliente:
   - `cliente_id` (ASC) + `fecha_publicacion` (DESC)

2. **fletes** - Para fletes disponibles:
   - `estado` (ASC) + `fecha_publicacion` (DESC)

3. **solicitantes** - Para vista chofer:
   - `chofer_id` (ASC) + `status` (ASC) + `created_at` (DESC)

4. **solicitantes** - Para vista cliente:
   - `cliente_id` (ASC) + `status` (ASC) + `updated_at` (DESC)

### Índices de Campo Único (en Firebase Console):

5. **fotos** - Para galería (creado automáticamente por Firebase):
   - `created_at` (DESC) con scope `COLLECTION_GROUP`

**Crear índices:**
```bash
firebase deploy --only firestore:indexes
```

**Contenido de firestore.indexes.json:**
```json
{
  "indexes": [
    {
      "collectionGroup": "fletes",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "cliente_id", "order": "ASCENDING"},
        {"fieldPath": "fecha_publicacion", "order": "DESCENDING"}
      ]
    },
    {
      "collectionGroup": "fletes",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "estado", "order": "ASCENDING"},
        {"fieldPath": "fecha_publicacion", "order": "DESCENDING"}
      ]
    },
    {
      "collectionGroup": "solicitantes",
      "queryScope": "COLLECTION_GROUP",
      "fields": [
        {"fieldPath": "chofer_id", "order": "ASCENDING"},
        {"fieldPath": "status", "order": "ASCENDING"},
        {"fieldPath": "created_at", "order": "DESCENDING"}
      ]
    },
    {
      "collectionGroup": "solicitantes",
      "queryScope": "COLLECTION_GROUP",
      "fields": [
        {"fieldPath": "cliente_id", "order": "ASCENDING"},
        {"fieldPath": "status", "order": "ASCENDING"},
        {"fieldPath": "updated_at", "order": "DESCENDING"}
      ]
    }
  ],
  "fieldOverrides": [
    {
      "collectionGroup": "fotos",
      "fieldPath": "created_at",
      "indexes": [
        {
          "order": "DESCENDING",
          "queryScope": "COLLECTION_GROUP"
        }
      ]
    }
  ]
}
```

---

## VISTAS DE LA APP

### CLIENTE/ADMIN

**Home (Lista de Fletes):**
- Ruta: `/` (home)
- Muestra lista de fletes publicados por el cliente
- Cards clickeables que abren vista de detalle
- Botón flotante `+` para publicar nuevo flete
- AppBar con: Solicitudes, Logout

**Publicar Flete:**
- Ruta: `/publicar-flete`
- Formulario completo con validación
- Campos: origen, destino, tipo contenedor, número, peso, tarifa
- Al publicar → estado inicial "disponible"

**Solicitudes de Choferes:**
- Ruta: `/solicitudes`
- Lista de solicitudes pendientes
- Muestra info del flete y chofer solicitante
- Botones: Aprobar (verde) / Rechazar (gris)
- Query con collectionGroup en `solicitantes`

**Detalle de Flete (Monitoreo):**
- Ruta: `/flete-detalle`
- Info completa del flete
- Barra de progreso: "X/5 checkpoints completados"
- Lista de 5 checkpoints expandibles
- Por cada checkpoint completado muestra:
  - Fotos en grid 3x3 (clickeables para ampliar)
  - Notas del chofer
  - Link GPS (botón azul "Ver ubicación en tiempo real")
  - Fecha/hora de completado
- Actualización en tiempo real con StreamBuilder

### CHOFER

**Fletes (TabView):**
- Ruta: `/` (home)
- Tab 1 "Disponibles": Fletes con estado `disponible` o `solicitado`
- Tab 2 "Mis Recorridos": Fletes asignados al chofer
- Botón "Aceptar" solo en fletes disponibles
- Badge "Pendiente de aprobación" en fletes solicitados

**Mis Recorridos:**
- Lista de fletes asignados (estados: asignado, en_proceso, completado)
- Cards clickeables que abren vista de detalle
- Muestra estado con colores: azul (asignado/en proceso), verde (completado)

**Detalle de Flete (Ejecución):**
- Ruta: `/flete-detalle`
- Misma vista que cliente pero con botones "Subir"
- Lista de 5 checkpoints con botón "Subir" en pendientes
- Al hacer clic en "Subir":
  1. Modal: Cámara o Galería
  2. Selección de fotos según requerimiento (1-2 fotos)
  3. Preview de fotos seleccionadas
  4. Input de link GPS (solo checkpoint "Ubicación GPS")
  5. Input de notas (opcional)
  6. Botón "Subir" final
- Checkpoints completados muestran checkmark verde

---

## PROBLEMAS RESUELTOS Y LECCIONES APRENDIDAS

### ✅ CORS en Firebase Storage
**Problema:** Imágenes no se cargan en web con error `Access-Control-Allow-Origin`
**Causa:** CORS no configurado en Google Cloud Storage bucket
**Solución:** 
```bash
# En Cloud Shell de Google Cloud Console:
echo '[{"origin":["*"],"method":["GET","HEAD","PUT","POST","DELETE"],"responseHeader":["Content-Type"],"maxAgeSeconds":3600}]' > cors.json && gsutil cors set cors.json gs://sellora-2xtskv.firebasestorage.app
```
**Lección:** Las reglas de Storage NO controlan CORS. Son dos configuraciones separadas.

### ✅ Índices de Firestore
**Problema:** Queries con múltiples filtros fallan pidiendo índices
**Solución:** 
- Índices compuestos → `firestore.indexes.json` + deploy
- Índices de campo único → Firebase Console o `fieldOverrides` en JSON
**Lección:** 
- `collectionGroup` queries necesitan índices con scope `COLLECTION_GROUP`
- Índices de un solo campo se pueden declarar en `fieldOverrides` o se crean automáticamente
- `whereIn` + `orderBy` necesita índice compuesto

### ✅ Estructura de Solicitudes
**Problema:** Query de solicitudes por cliente muy lento
**Solución:** Estructura anidada `/solicitudes/{fleteId}/solicitantes/{choferId}` con `cliente_id` en cada documento
**Lección:** Desnormalizar datos (guardar `cliente_id` en cada solicitud) mejora performance de queries

### ✅ Reglas de Firestore para Subcollections
**Problema:** Permisos denegados al crear checkpoints
**Solución:** Usar `exists()` y `get()` para verificar documento padre
```javascript
allow create: if isAuthenticated() && (
  exists(/databases/$(database)/documents/fletes/$(fleteId))
  && get(/databases/$(database)/documents/fletes/$(fleteId)).data.transportista_asignado == request.auth.uid
)
```
**Lección:** Las subcollections necesitan reglas explícitas y pueden acceder al documento padre

### ✅ Manejo de Errores en Operaciones Asíncronas
**Problema:** Error al actualizar flete mostraba mensaje de error aunque checkpoint se guardó
**Solución:** Envolver operaciones no-críticas en try-catch sin relanzar error
```dart
try {
  await _db.collection('fletes').doc(fleteId).update({...});
} catch (e) {
  print('⚠️ Error: $e');
  // No lanzar - el checkpoint ya está guardado
}
```
**Lección:** Separar operaciones críticas de opcionales para mejor UX

### ✅ Conversión de Timestamps
**Problema:** Fechas vienen como String o Timestamp desde Firestore
**Solución:** Función helper `parseDate()` que maneja ambos tipos
```dart
DateTime parseDate(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.parse(value);
  return DateTime.now();
}
```
**Lección:** Siempre manejar múltiples tipos al parsear datos de Firestore

---

## TECNOLOGÍAS Y DEPENDENCIAS

### Framework:
- **Flutter** - Framework multiplataforma
- **Dart** - Lenguaje de programación

### Backend (Firebase):
- **Firebase Auth** - Autenticación de usuarios
- **Cloud Firestore** - Base de datos NoSQL en tiempo real
- **Firebase Storage** - Almacenamiento de imágenes
- **Firebase Hosting** - Hosting web (opcional)

### Paquetes Flutter (pubspec.yaml):
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^4.2.0
  firebase_auth: '>=5.3.3'
  cloud_firestore: '>=5.5.0'
  firebase_storage: ^13.0.0
  image_picker: '>=1.1.2'      # Selección de fotos
  url_launcher: ^6.2.0         # Abrir links GPS
  google_fonts: ^6.1.0
  cupertino_icons: ^1.0.8
  shared_preferences: ^2.0.0
```

### Deploy:
- **GitHub Actions** - CI/CD automático
- **Netlify** - Hosting de aplicación web
- **Google Cloud Console** - Configuración de CORS

### Estructura del Proyecto:
```
lib/
├── models/              # Modelos de datos
│   ├── usuario.dart
│   ├── flete.dart
│   └── checkpoint.dart
├── services/            # Lógica de negocio
│   ├── auth_service.dart
│   ├── flete_service.dart
│   ├── checkpoint_service.dart
│   ├── solicitudes_service.dart
│   └── notifications_service.dart
├── screens/             # Vistas de la app
│   ├── login_page.dart
│   ├── registro_page.dart
│   ├── home_page.dart
│   ├── publicar_flete_page.dart
│   ├── solicitudes_page.dart
│   ├── mis_recorridos_page.dart
│   ├── flete_detail_page.dart
│   └── fletes_cliente_detalle_page.dart
├── widgets/             # Componentes reutilizables
│   └── flete_card.dart
├── theme.dart           # Tema de la app
└── main.dart            # Punto de entrada
```

---

## CONFIGURACIÓN CRÍTICA PARA NUEVA SESIÓN

### 1. Firebase Storage CORS (OBLIGATORIO para web)
**Sin esto, las imágenes NO se cargarán en la aplicación web.**

```bash
# Ejecutar en Cloud Shell de Google Cloud Console:
echo '[{"origin":["*"],"method":["GET","HEAD","PUT","POST","DELETE"],"responseHeader":["Content-Type"],"maxAgeSeconds":3600}]' > cors.json && gsutil cors set cors.json gs://sellora-2xtskv.firebasestorage.app
```

### 2. Índices de Firestore (OBLIGATORIO)
**Ejecutar después de cualquier cambio en queries:**
```bash
firebase deploy --only firestore:indexes
```

### 3. Reglas de Firestore y Storage
**Siempre verificar que estén desplegadas:**
```bash
firebase deploy --only firestore:rules,storage
```

### 4. Estructura de Datos Importante

**Solicitudes (estructura anidada):**
```
/solicitudes/{fleteId}/solicitantes/{choferId}
```
NO usar `/solicitudes/{solicitudId}` - debe ser anidado.

**Checkpoints:**
```
/fletes/{fleteId}/checkpoints/{tipo}
```
Tipos: retiro_unidad, ubicacion_gps, llegada_cliente, salida_cliente, entrega_unidad_vacia

**Storage:**
```
/fletes/{fleteId}/checkpoints/{tipo}/{archivo}.jpg
```

### 5. Estados de Flete (en orden)
```
disponible → solicitado → asignado → en_proceso → completado
```

### 6. Queries Críticos que Necesitan Índices

**Cliente ve sus fletes:**
```dart
.collection('fletes')
.where('cliente_id', isEqualTo: clienteId)
.orderBy('fecha_publicacion', descending: true)
```
Índice: `cliente_id` + `fecha_publicacion`

**Cliente ve solicitudes:**
```dart
.collectionGroup('solicitantes')
.where('cliente_id', isEqualTo: clienteId)
.where('status', isEqualTo: 'pending')
.orderBy('updated_at', descending: true)
```
Índice: `cliente_id` + `status` + `updated_at` (COLLECTION_GROUP)

**Chofer ve fletes disponibles:**
```dart
.collection('fletes')
.where('estado', whereIn: ['disponible', 'solicitado'])
.orderBy('fecha_publicacion', descending: true)
```
Índice: `estado` + `fecha_publicacion`

### 7. Información del Proyecto

- **Proyecto Firebase:** `sellora-2xtskv`
- **Bucket Storage:** `sellora-2xtskv.firebasestorage.app`
- **URL Netlify:** `https://cargoclick.netlify.app`
- **GitHub Actions:** Compila automáticamente en cada push

### 8. Usuarios de Prueba

**Cliente (crear manualmente en Firestore):**
```
/users/{uid}
{
  tipoUsuario: "Cliente",
  email: "cliente@test.com",
  display_name: "Cliente Test",
  ...
}
```

**Chofer (se registra en la app):**
```
/users/{uid}
{
  tipoUsuario: "Chofer",
  email: "chofer@test.com",
  display_name: "Chofer Test",
  ...
}
```

---

## NOTAS IMPORTANTES

### Diferencias entre Reglas de Storage y CORS:
- **Storage Rules (`storage.rules`):** Controlan QUIÉN puede leer/escribir archivos (autorización)
- **CORS:** Controla QUÉ DOMINIOS pueden hacer peticiones HTTP al bucket
- **Ambos son necesarios** para que la web funcione correctamente

### Índices de Firestore:
- **Compuestos (2+ campos):** Van en `firestore.indexes.json` con deploy
- **Campo único:** Se pueden declarar en `fieldOverrides` o se crean automáticamente
- **CollectionGroup:** Necesitan `queryScope: "COLLECTION_GROUP"`

### StreamBuilder vs FutureBuilder:
- **StreamBuilder:** Datos en tiempo real, se actualiza automáticamente (usar para checkpoints, solicitudes)
- **FutureBuilder:** Una sola consulta, no se actualiza (usar para progreso puntual)

### Estructura de Datos:
- **Normalización vs Desnormalización:** Guardar `cliente_id` en cada solicitud (desnormalizado) mejora queries
- **Subcollections:** Útiles para datos que pertenecen a un padre, pero dificultan queries globales
- **CollectionGroup:** Solución para queries en subcollections, pero requiere índices especiales

### Deploy:
- **GitHub Actions:** Compila automáticamente en cada push
- **Netlify:** Solo hosting estático, no ejecuta código servidor
- **Firebase:** Backend completo (Auth, Firestore, Storage, Functions opcionales)

### Errores Comunes:
- **ERR_BLOCKED_BY_CLIENT:** Bloqueador de anuncios, ignorar
- **Missing Index:** Crear índice en Firebase Console o archivo JSON
- **CORS Error:** Configurar CORS en Google Cloud Storage (gsutil)
- **Permission Denied:** Verificar reglas de Firestore/Storage

---

**Última actualización:** 2025-01-24  
**Estado del proyecto:** ✅ MVP COMPLETADO Y FUNCIONAL  
**Deploy actual:** https://cargoclick.netlify.app  
**Proyecto Firebase:** sellora-2xtskv
