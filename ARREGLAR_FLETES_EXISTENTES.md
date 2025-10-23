# CÓMO ARREGLAR FLETES EXISTENTES EN FIREBASE

Si tienes fletes en Firestore con estado "publicado" que no aparecen en la vista de choferes, necesitas cambiarlos manualmente a "disponible".

## Opción 1: Desde Firebase Console (Manual)

1. Ve a Firebase Console: https://console.firebase.google.com
2. Selecciona tu proyecto: `sellora-2xtskv`
3. Ve a Firestore Database
4. Busca la collection `fletes`
5. Para cada documento que tenga `estado: "publicado"`:
   - Click en el documento
   - Encuentra el campo `estado`
   - Cambia el valor de `"publicado"` a `"disponible"`
   - Guarda

## Opción 2: Script de Migración (Automático)

Si tienes muchos fletes, puedes usar este script de Node.js:

```javascript
// migrate-fletes.js
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function migrarFletes() {
  try {
    // Buscar todos los fletes con estado "publicado"
    const snapshot = await db.collection('fletes')
      .where('estado', '==', 'publicado')
      .get();

    console.log(`Encontrados ${snapshot.size} fletes con estado "publicado"`);

    // Actualizar cada uno
    const batch = db.batch();
    snapshot.docs.forEach(doc => {
      batch.update(doc.ref, {
        estado: 'disponible',
        updated_at: admin.firestore.FieldValue.serverTimestamp()
      });
    });

    await batch.commit();
    console.log('✅ Fletes actualizados exitosamente');
  } catch (error) {
    console.error('❌ Error:', error);
  }
}

migrarFletes();
```

### Cómo ejecutar el script:

1. Instala Firebase Admin SDK:
```bash
npm install firebase-admin
```

2. Descarga tu Service Account Key:
   - Firebase Console → Project Settings → Service Accounts
   - Generate new private key
   - Guarda como `serviceAccountKey.json`

3. Ejecuta el script:
```bash
node migrate-fletes.js
```

## Opción 3: Desde la App (Temporal)

Puedes agregar un botón temporal en la app de admin para migrar los fletes:

```dart
// En alguna vista de admin, agregar:
ElevatedButton(
  onPressed: () async {
    final fletes = await FirebaseFirestore.instance
        .collection('fletes')
        .where('estado', isEqualTo: 'publicado')
        .get();
    
    final batch = FirebaseFirestore.instance.batch();
    
    for (var doc in fletes.docs) {
      batch.update(doc.reference, {
        'estado': 'disponible',
        'updated_at': Timestamp.now(),
      });
    }
    
    await batch.commit();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${fletes.docs.length} fletes actualizados')),
    );
  },
  child: Text('Migrar fletes antiguos'),
)
```

## Verificar que funcionó

1. Ve a la vista de Chofer → Tab "Disponibles"
2. Deberías ver los fletes que acabas de migrar
3. Verifica en Firestore que el campo `estado` ahora dice `"disponible"`

---

**Importante:** Después de migrar, todos los nuevos fletes se crearán automáticamente con estado "disponible" gracias al cambio que hicimos en `publicar_flete_page.dart`.
