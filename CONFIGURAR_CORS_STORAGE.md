# Configuración CORS para Firebase Storage

## Problema
Las imágenes no se cargan en la aplicación web desplegada en Netlify debido a error CORS:
```
Access to XMLHttpRequest at 'https://firebasestorage.googleapis.com/...' from origin 'https://cargoclick.netlify.app' has been blocked by CORS policy
```

## Solución

### Opción 1: Usar Google Cloud Console (Más fácil)

1. Ve a [Google Cloud Console](https://console.cloud.google.com)
2. Selecciona tu proyecto: `sellora-2xtskv`
3. Ve a **Cloud Storage** → **Buckets**
4. Encuentra tu bucket: `sellora-2xtskv.firebasestorage.app` o `sellora-2xtskv.appspot.com`
5. Click en el bucket
6. Ve a la pestaña **Permissions** (Permisos)
7. Click en **Grant Access** (Otorgar acceso)
8. En "Add principals", agrega: `allUsers`
9. En "Assign roles", selecciona: `Storage Object Viewer`
10. Click **Save**

### Opción 2: Usar Firebase CLI con archivo CORS

Si tienes Firebase CLI instalado:

```bash
# 1. Instalar gcloud CLI si no lo tienes
# Descarga de: https://cloud.google.com/sdk/docs/install

# 2. Autenticarte
gcloud auth login

# 3. Configurar proyecto
gcloud config set project sellora-2xtskv

# 4. Aplicar configuración CORS
gsutil cors set cors.json gs://sellora-2xtskv.appspot.com
```

### Opción 3: Hacer el bucket público (Más simple pero menos seguro)

En Firebase Console:
1. Ve a **Storage** en tu proyecto Firebase
2. Click en la pestaña **Rules**
3. Cambia las reglas temporalmente a:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read: if true;  // Público para lectura
      allow write: if request.auth != null;  // Escritura solo autenticados
    }
  }
}
```

4. Click **Publish**

**Nota:** Esta opción hace que TODAS las imágenes sean públicas sin necesidad de autenticación.

### Opción 4: Actualizar CORS desde consola de Cloud Storage

1. Ve a [Cloud Storage Settings](https://console.cloud.google.com/storage/settings)
2. Selecciona tu bucket
3. En el menú de la derecha, click en **Edit CORS configuration**
4. Pega esta configuración:

```json
[
  {
    "origin": ["https://cargoclick.netlify.app", "http://localhost:*"],
    "method": ["GET", "HEAD", "PUT", "POST", "DELETE"],
    "responseHeader": ["Content-Type", "Authorization", "Content-Length"],
    "maxAgeSeconds": 3600
  }
]
```

## Archivo cors.json

El archivo `cors.json` incluido en este proyecto tiene la configuración necesaria para permitir:
- Origen: `https://cargoclick.netlify.app`
- Métodos: GET, HEAD, PUT, POST, DELETE
- Headers: Content-Type, Authorization
- Cache: 1 hora

### Contenido del archivo:
```json
[
  {
    "origin": ["https://cargoclick.netlify.app"],
    "method": ["GET", "HEAD", "PUT", "POST", "DELETE"],
    "responseHeader": ["Content-Type", "Authorization"],
    "maxAgeSeconds": 3600
  }
]
```

## Verificar que funciona

Después de aplicar cualquiera de las opciones:

1. Abre tu app: https://cargoclick.netlify.app
2. Navega a un flete con fotos
3. Las imágenes deberían cargarse correctamente
4. Abre DevTools (F12) → Console
5. No deberías ver más errores CORS

## Solución Recomendada

**Opción 3** (hacer bucket público para lectura) es la más rápida y funciona inmediatamente. Es segura para tu caso de uso porque:
- Las imágenes son de fletes (no datos sensibles)
- Solo usuarios autenticados pueden subir fotos (regla `allow write: if request.auth != null`)
- Los clientes necesitan ver las fotos de sus fletes

## Problema relacionado: Storage Rules

Actualmente tus reglas de Storage son:
```javascript
match /fletes/{fleteId}/{allPaths=**} {
  allow read: if isAuthenticated();
  allow write: if isAuthenticated();
}
```

Esto requiere que el usuario esté autenticado para leer las imágenes. Si usas la Opción 3, cambiaría a:
```javascript
match /fletes/{fleteId}/{allPaths=**} {
  allow read: if true;  // Público
  allow write: if isAuthenticated();
}
```

O mantén las reglas restrictivas y usa la configuración CORS (Opciones 1, 2 o 4).
