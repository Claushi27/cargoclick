# CARGOCLICK - CONTEXTO COMPLETO DEL PROYECTO

## DESCRIPCIÓN
Marketplace para transporte de carga marítimo que conecta Admin (quien publica fletes) con Choferes (quienes los aceptan y ejecutan).

## ROLES DE USUARIO

### ADMIN
- Publica fletes nuevos
- Aprueba/rechaza solicitudes de choferes
- Ve detalles de cada flete con checkpoints y fotos en tiempo real
- Puede ver el progreso de cada flete (checkpoints completados)
- Accede a links GPS en tiempo real compartidos por choferes
- Ve lista de todos los choferes registrados

### CHOFER
- Se registra en la app (único rol que puede registrarse)
- Ve fletes disponibles
- Solicita fletes
- Sube fotos durante el recorrido
- Ve sus recorridos asignados

**IMPORTANTE:** No hay registro de clientes, solo choferes pueden registrarse.

---

## FLUJOS CRÍTICOS

### 1. REGISTRO (Solo Choferes)
```
1. Usuario llena formulario registro
2. Firebase Auth crea cuenta
3. Documento en users/ con role: "driver"
4. Redirect a vista choferes
```

### 2. PUBLICAR FLETE (Solo Admin)
```
1. Admin llena formulario
2. Crear documento en fletes/ con status: "disponible"
3. Mostrar en lista "Fletes Disponibles"
```

### 3. SOLICITAR FLETE (Chofer)
```
1. Chofer ve lista "Fletes Disponibles"
2. Click "Aceptar"
3. Crear documento en solicitudes/ con status: "pending"
4. Actualizar flete.status = "solicitado"
5. TRIGGER: Notificación al admin
```

### 4. APROBAR SOLICITUD (Admin)
```
1. Admin ve "Solicitudes de Choferes"
2. Click "Aprobar"
3. Actualizar solicitud.status = "approved"
4. Actualizar flete.status = "en_proceso"
5. Actualizar flete.choferAsignado = choferId
6. TRIGGER: Notificación al chofer
7. Flete aparece en "Mis Recorridos" del chofer
```

### 5. SUBIR FOTO (Chofer)
```
1. Chofer en "Mis Recorridos"
2. Click "Subir Foto" en flete activo
3. Abrir input file (accept="image/*", capture="environment")
4. Upload a Storage: /fletes/{fleteId}/fotos/{timestamp}_{choferId}.jpg
5. Agregar objeto a flete.fotos[]
6. TRIGGER: Notificación al admin
```

---

## ESTADOS DEL FLETE (Ciclo de Vida)

```
disponible → solicitado → asignado → en_proceso → completado
```

| Estado | Descripción | Quién lo puede ver |
|--------|-------------|-------------------|
| **disponible** | Flete recién publicado por admin, esperando solicitudes | Admin, Choferes |
| **solicitado** | Chofer envió solicitud, esperando aprobación admin | Admin, Chofer solicitante |
| **asignado** | Admin aprobó solicitud, flete asignado a chofer | Admin, Chofer asignado |
| **en_proceso** | Chofer comenzó checkpoints | Admin, Chofer asignado |
| **completado** | Chofer completó los 5 checkpoints | Admin, Chofer asignado |

**IMPORTANTE:** 
- Al publicar flete → estado = **"disponible"**
- Al aceptar flete → estado = **"solicitado"**
- Al aprobar solicitud → estado = **"asignado"**
- Al completar checkpoints → estado = **"completado"**

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

### Collection: solicitudes
```javascript
{
  id: string (auto),
  flete_id: string,
  chofer_id: string,
  status: "pending" | "approved" | "rejected",
  fecha_solicitud: Timestamp,
  fecha_respuesta: Timestamp | null,
  created_at: Timestamp,
  updated_at: Timestamp
}
```

---

## FIRESTORE SECURITY RULES

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    // Perfil del usuario: cada usuario gestiona su propio documento
    match /users/{uid} {
      allow create: if request.auth != null && request.auth.uid == uid;
      allow read, update, delete: if request.auth != null && request.auth.uid == uid;
    }

    // Fletes: lectura para autenticados; creación por el cliente dueño
    match /fletes/{fleteId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null
        && request.resource.data.cliente_id == request.auth.uid;

      // Actualizaciones permitidas al dueño (cliente) o transportista asignado
      allow update, delete: if request.auth != null
        && (
          request.auth.uid == resource.data.cliente_id
          || (resource.data.transportista_id != null
              && request.auth.uid == resource.data.transportista_id)
        );
    }

    // Solicitudes: lectura y creación para autenticados
    match /solicitudes/{solicitudId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null
        && request.resource.data.chofer_id == request.auth.uid;
      allow update: if request.auth != null;
    }

    // Catch-all: denegar todo lo demás
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

---

## STORAGE SECURITY RULES

```javascript
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    
    // Fotos de fletes
    match /fletes/{fleteId}/fotos/{fileName} {
      // Lectura: cualquier usuario autenticado
      allow read: if request.auth != null;
      
      // Escritura: solo choferes autenticados
      allow write: if request.auth != null;
    }
    
    // Denegar todo lo demás
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

---

## ÍNDICES FIRESTORE REQUERIDOS

### Collection: fletes
```
Composite Index 1:
- status (Ascending)
- fechaPublicacion (Descending)

Composite Index 2:
- choferAsignado (Ascending)
- status (Ascending)
```

### Collection: solicitudes
```
Composite Index 1:
- fleteId (Ascending)
- status (Ascending)

Composite Index 2:
- choferId (Ascending)
- fechaSolicitud (Descending)
```

**Crear en Firebase Console:**
Firestore Database → Indexes → Composite → Add index

---

## VISTAS DE LA APP

### ADMIN
- `/publicar-flete` - Formulario para crear flete
- `/` (home) - Lista de fletes publicados (clickeables)
- `/flete-detalle` - Vista detallada de un flete con checkpoints, fotos y progreso en tiempo real
- `/solicitudes` - Lista de solicitudes pendientes
- `/choferes` - Lista de todos los choferes registrados

### CHOFER
- `/fletes-disponibles` - Lista de fletes disponibles (solo lectura)
- `/mis-recorridos` - Fletes asignados con botón para ver detalles
- `/flete-detalle` - Vista para subir checkpoints con fotos y link GPS
- `/perfil` - Editar datos personales

---

## ERRORES CORREGIDOS

### ✅ ERROR 1: Type Error en fechas (SOLUCIONADO)
- **Problema:** Fechas llegaban como String desde Firestore
- **Solución:** Agregada función `parseDate()` en `Flete.fromJson()` que maneja String y Timestamp
- **Archivo:** `lib/models/flete.dart`

### ✅ ERROR 2: Estado incorrecto en query (SOLUCIONADO)
- **Problema:** Query buscaba estado 'publicado' en lugar de 'disponible'
- **Solución:** Cambiado a `.where('estado', isEqualTo: 'disponible')`
- **Archivo:** `lib/services/flete_service.dart`

### ✅ ERROR 3: Índice compuesto faltante (SOLUCIONADO)
- **Problema:** Query con múltiples filtros y order by necesitaba índice
- **Solución:** Query simplificada, filtrado y ordenamiento en memoria
- **Archivo:** `lib/services/flete_service.dart` - método `getFletesAsignadosChofer()`

### ✅ ERROR 4: Reglas Firestore para solicitudes (SOLUCIONADO)
- **Problema:** "Missing rules" al aprobar/rechazar solicitudes
- **Solución:** Agregados permisos de `delete` y `update` para cliente en subcollection solicitantes
- **Archivo:** `firestore.rules`

### ✅ ERROR 5: Reglas Storage para fotos de checkpoints (SOLUCIONADO)
- **Problema:** "Usuario no autorizado" al subir fotos
- **Solución:** Agregadas reglas para subcollections checkpoints y fotos, permitiendo escritura a chofer asignado y cliente
- **Archivo:** `firestore.rules` - reglas de fletes/checkpoints y fletes/fotos

### ✅ ERROR 6: Link GPS en tiempo real (IMPLEMENTADO)
- **Funcionalidad:** Chofer puede agregar link de GPS en tiempo real al checkpoint de Ubicación GPS
- **Vista Cliente:** Puede ver y hacer clic en el link para ver ubicación en tiempo real
- **Archivos:** `lib/models/checkpoint.dart`, `lib/services/checkpoint_service.dart`, `lib/screens/flete_detail_page.dart`

---

## ERRORES ACTUALES A RESOLVER

### 🔴 Firestore Index Missing
- Crear índice compuesto para queries de fletes
- Crear índice para solicitudes

### 🔴 Type Error en Disponibles
- Convertir timestamps a Date objects correctamente
- Validar que todos los campos requeridos existan

### 🔴 Permission Denied
- Configurar reglas de Firestore según especificación
- Configurar reglas de Storage para fotos

### 🔴 Galería vacía
- Implementar query correcta para traer fletes con fotos
- Manejar caso cuando no hay fotos

### 🔴 Falta Collection solicitudes
- Crear estructura de datos
- Implementar service layer

---

## PRIORIDADES DE DESARROLLO

### FASE 1 (Actual) - MVP Funcional

#### ✅ COMPLETADO
- Estructura básica de la app
- Autenticación con Firebase
- Modelos de datos (Usuario, Flete)
- Deploy en Netlify

#### ⚠️ EN PROGRESO / PENDIENTE

1. **Eliminar opción registro como cliente**
   - Solo permitir registro de choferes
   - Ocultar selector de tipo de usuario en registro

2. **Configurar reglas Firestore/Storage**
   - Aplicar reglas de seguridad especificadas
   - Probar permisos para cada rol

3. **Crear índices compuestos**
   - Índices para fletes
   - Índices para solicitudes

4. **Implementar vista "Solicitudes de Choferes" (Admin)**
   - Lista de solicitudes pendientes
   - Botones Aprobar/Rechazar
   - Actualizar estado del flete al aprobar

5. **Implementar vista "Mis Recorridos" (Chofer)**
   - Lista de fletes asignados al chofer
   - Botón "Subir Foto" por flete
   - Mostrar fotos ya subidas

6. **Implementar upload de fotos**
   - Input file con preview
   - Upload a Storage
   - Guardar metadata en Firestore
   - Notificación al admin

7. **Implementar galería funcional (Admin)**
   - Query correcto para traer fletes con fotos
   - Grid de fotos con metadata
   - Filtros por flete/chofer

---

## NOTAS IMPORTANTES

- **Plan Blaze pendiente:** Se agregará mañana para habilitar Firebase Functions y notificaciones
- **Notificaciones:** Por implementar cuando se active plan Blaze
- **Testing:** Probar cada flujo con usuarios reales antes de producción
- **Backup:** Configurar backup automático de Firestore

---

## COMANDOS ÚTILES

### Deploy a Netlify
```bash
# Actualizar código
git add .
git commit -m "Descripción del cambio"
git push

# GitHub Actions compila automáticamente
# Descargar artifact y subir a Netlify Drop
```

### Firestore Rules Deploy
```bash
firebase deploy --only firestore:rules
```

### Storage Rules Deploy
```bash
firebase deploy --only storage
```

---

**Última actualización:** 2025-10-23
**Estado del proyecto:** En desarrollo - Fase 1
**Deploy actual:** https://cargoclick.netlify.app (o URL asignada)
