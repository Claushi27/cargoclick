# 🐛 BUGS IDENTIFICADOS - 15 NOV 2025

## ✅ ESTADO
- **Privacy Policy:** https://claushi27.github.io/cargoclick-privacy/
- **MainActivity:** ✅ Corregida
- **Logo:** ✅ Cambiado
- **Keystore:** ✅ Configurado

---

## 🔴 BUGS PENDIENTES

### 1. **LOGIN - Mensajes de error feos**
**Problema:** Sale error rojo cuando email/contraseña incorrectos  
**Solución:** Mejorar mensajes en `lib/services/auth_service.dart`

**Archivo:** `lib/screens/login_page.dart` o donde captures el error

**Cambio necesario:**
```dart
// En el catch del login, agregar:
catch (e) {
  String mensaje = 'Error al iniciar sesión';
  
  if (e.toString().contains('user-not-found')) {
    mensaje = '❌ Email no registrado';
  } else if (e.toString().contains('wrong-password')) {
    mensaje = '❌ Contraseña incorrecta';
  } else if (e.toString().contains('invalid-email')) {
    mensaje = '❌ Email inválido';
  } else if (e.toString().contains('invalid-credential')) {
    mensaje = '❌ Credenciales incorrectas';
  }
  
  // Mostrar SnackBar bonito en lugar de error rojo
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.white),
          SizedBox(width: 12),
          Expanded(child: Text(mensaje)),
        ],
      ),
      backgroundColor: Colors.orange.shade700,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      duration: Duration(seconds: 3),
    ),
  );
}
```

---

### 2. **HISTORIAL CAMBIOS - Error "requires an index"**
**Problema:** En celular sale error de índice requerido  
**Archivo:** `lib/services/flete_service.dart` línea ~400-500

**Solución:** Agregar índice compuesto en Firestore

**Ir a Firebase Console:**
1. Firestore → Indexes
2. Crear índice compuesto:
   - Collection: `cambios_asignacion`
   - Fields:
     - `flete_id` Ascending
     - `fecha_cambio` Descending
   - Query scope: Collection

**O usar este link directo cuando salga el error:**
El error te dará un link directo para crear el índice, solo haz click.

---

### 3. **FOTOS NO SE SUBEN - App se traba**
**Problema:** Tomas foto, das OK y se queda trabada  
**Archivos:** 
- `lib/screens/flete_detail_page.dart`
- `lib/screens/mis_recorridos_page.dart`

**Posibles causas:**
1. Permisos de cámara no otorgados
2. Compresión muy agresiva
3. Error en upload

**Debug necesario:**
Agregar logs para ver qué pasa:

```dart
// En la función que sube fotos:
try {
  print('📸 Iniciando captura de foto...');
  final XFile? photo = await ImagePicker().pickImage(
    source: ImageSource.camera,
  );
  
  if (photo == null) {
    print('❌ Usuario canceló');
    return;
  }
  
  print('✅ Foto capturada: ${photo.path}');
  print('📦 Tamaño: ${await photo.length()} bytes');
  
  // Mostrar loading
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Center(
      child: CircularProgressIndicator(),
    ),
  );
  
  print('🗜️ Comprimiendo...');
  final compressedBytes = await FlutterImageCompress.compressWithFile(
    photo.path,
    quality: 70,
    minWidth: 1024,
    minHeight: 768,
  );
  
  print('✅ Comprimida: ${compressedBytes?.length ?? 0} bytes');
  
  // Subir a Storage
  print('☁️ Subiendo a Firebase Storage...');
  // ... código de upload
  
  Navigator.pop(context); // Cerrar loading
  print('✅ Foto subida exitosamente');
  
} catch (e) {
  print('❌ ERROR subiendo foto: $e');
  Navigator.pop(context); // Cerrar loading si hay
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Error: ${e.toString()}'),
      backgroundColor: Colors.red,
    ),
  );
}
```

**Verificar permisos en AndroidManifest.xml:**
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

---

### 4. **CHOFER/CAMIÓN YA ASIGNADO - Error rojo feo**
**Problema:** Cuando chofer/camión ya tiene flete, sale error rojo  
**Archivo:** `lib/screens/asignar_flete_page.dart`

**Solución:** Mostrar disabled en lugar de permitir click

```dart
// En ListTile de chofer/camión:
ListTile(
  leading: CircleAvatar(
    backgroundColor: chofer.tieneFleteActivo ? Colors.grey : Colors.blue,
    child: Icon(
      Icons.person,
      color: Colors.white,
    ),
  ),
  title: Text(
    chofer.nombre,
    style: TextStyle(
      color: chofer.tieneFleteActivo ? Colors.grey : Colors.black87,
      fontWeight: chofer.tieneFleteActivo ? FontWeight.normal : FontWeight.bold,
    ),
  ),
  subtitle: chofer.tieneFleteActivo 
    ? Row(
        children: [
          Icon(Icons.local_shipping, size: 14, color: Colors.orange),
          SizedBox(width: 4),
          Text(
            'En flete activo',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      )
    : null,
  enabled: !chofer.tieneFleteActivo, // ← CLAVE: Deshabilitar si ocupado
  onTap: chofer.tieneFleteActivo 
    ? null // No hacer nada si ocupado
    : () {
        // Asignar chofer
      },
)
```

---

### 5. **FILTRO POR PUERTO - Feature nueva**
**Problema:** Transportistas quieren filtrar solo Valparaíso o San Antonio  
**Archivos a modificar:**
- `lib/models/transportista.dart` - Agregar campo `puerto_preferido`
- `lib/screens/perfil_transportista_page.dart` - Agregar dropdown
- `lib/screens/fletes_disponibles_page.dart` - Filtrar por puerto

**Paso 1: Modelo Transportista**
```dart
class Transportista {
  // ... campos existentes
  final String? puertoPreferido; // 'Valparaiso', 'San Antonio', null (ambos)
  
  Transportista({
    // ... params existentes
    this.puertoPreferido,
  });
  
  factory Transportista.fromJson(Map<String, dynamic> json) {
    return Transportista(
      // ... campos existentes
      puertoPreferido: json['puerto_preferido'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      // ... campos existentes
      'puerto_preferido': puertoPreferido,
    };
  }
}
```

**Paso 2: Perfil Transportista - Agregar dropdown**
```dart
DropdownButtonFormField<String>(
  value: _puertoPreferido,
  decoration: InputDecoration(
    labelText: 'Puerto Preferido',
    hintText: 'Selecciona tu puerto',
    prefixIcon: Icon(Icons.location_on),
  ),
  items: [
    DropdownMenuItem(value: null, child: Text('Ambos puertos')),
    DropdownMenuItem(value: 'Valparaiso', child: Text('Valparaíso')),
    DropdownMenuItem(value: 'San Antonio', child: Text('San Antonio')),
  ],
  onChanged: (value) {
    setState(() {
      _puertoPreferido = value;
    });
  },
)
```

**Paso 3: Filtrar fletes por puerto**
```dart
// En fletes_disponibles_page.dart
query = query.where('puerto_origen', whereIn: [
  transportista.puertoPreferido ?? 'Valparaiso',
  transportista.puertoPreferido ?? 'San Antonio',
]);
```

---

### 6. **NOTIFICACIONES INCORRECTAS**
**Problema:** Se envían notificaciones a todos los usuarios logueados en mismo celular  
**Archivo:** `lib/services/notification_service.dart`

**Causa:** El token FCM se guarda por dispositivo, no por usuario

**Solución:** Al hacer login/logout, actualizar tokens

```dart
// En auth_service.dart, método login():
Future<Usuario?> login({...}) async {
  // ... código existente
  
  if (credential.user != null) {
    // BORRAR tokens viejos de otros usuarios en este dispositivo
    await _limpiarTokensViejos();
    
    // Guardar nuevo token para este usuario
    final notificationService = NotificationService();
    await notificationService.saveTokenToFirestore(credential.user!.uid);
  }
  
  return await getCurrentUsuario();
}

// En auth_service.dart, método logout():
Future<void> logout() async {
  if (!_isBackendReady) return;
  
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    // BORRAR token de este usuario
    await NotificationService().removeTokenFromFirestore(user.uid);
  }
  
  await FirebaseAuth.instance.signOut();
}

// Nuevo método helper:
Future<void> _limpiarTokensViejos() async {
  final messaging = FirebaseMessaging.instance;
  final token = await messaging.getToken();
  
  if (token == null) return;
  
  // Buscar todos los usuarios que tengan este token
  final usersQuery = await FirebaseFirestore.instance
      .collection('users')
      .where('fcm_tokens', arrayContains: token)
      .get();
  
  for (var doc in usersQuery.docs) {
    await doc.reference.update({
      'fcm_tokens': FieldValue.arrayRemove([token]),
    });
  }
  
  final transportistasQuery = await FirebaseFirestore.instance
      .collection('transportistas')
      .where('fcm_tokens', arrayContains: token)
      .get();
  
  for (var doc in transportistasQuery.docs) {
    await doc.reference.update({
      'fcm_tokens': FieldValue.arrayRemove([token]),
    });
  }
}
```

---

### 7. **RIGHT OVERFLOWED BY 86 PIXELS**
**Problema:** Error de layout al inicio  
**Buscar:** Probablemente en página de inicio o login

**Solución:** Envolver texto largo en `Flexible` o `Expanded`

```dart
// Buscar filas con textos largos:
Row(
  children: [
    Icon(...),
    Expanded( // ← Agregar Expanded/Flexible
      child: Text('Texto largo que causa overflow'),
    ),
  ],
)

// O usar Wrap en lugar de Row si hay múltiples widgets
```

**Cómo encontrarlo:**
1. Ejecutar app en debug
2. Ver error en consola que dice exactamente qué widget
3. Buscar ese widget en el código

---

## 🎯 PRIORIDAD DE ARREGLOS

### CRÍTICOS (Hacer YA):
1. ✅ Fotos no se suben (bloqueador total)
2. ✅ Notificaciones incorrectas (funcionalidad core)
3. ✅ Historial cambios error index (funcionalidad core)

### IMPORTANTES (Hacer pronto):
4. ⚠️ Login error messages (UX)
5. ⚠️ Chofer/Camión disabled (UX)
6. ⚠️ Right overflow (UX)

### FEATURES NUEVAS (Después):
7. 💡 Filtro puerto (nice to have)

---

## 📝 TESTING RECOMENDADO

### Para cada fix:
1. Probar en emulador
2. Probar en celular físico
3. Probar con datos reales
4. Verificar que no rompa nada más

### Logs útiles:
```dart
print('🐛 DEBUG: variable = $variable');
print('✅ SUCCESS: operación completada');
print('❌ ERROR: ${e.toString()}');
```

---

## 🚀 DESPUÉS DE ARREGLAR TODO

1. ✅ Generar build producción: `flutter build appbundle --release`
2. ✅ Tomar screenshots (4-8)
3. ✅ Subir a Play Console
4. ✅ Completar ficha
5. ✅ Enviar a revisión

---

**Creado:** 15 Noviembre 2025  
**Estado:** Bugs identificados, pendiente implementar fixes
