# 🔧 SOLUCIÓN: keytool no reconocido

## PROBLEMA:
`keytool` no se reconoce porque falta Java JDK o no está en el PATH.

---

## ✅ SOLUCIÓN RÁPIDA (3 opciones)

---

## OPCIÓN 1: Usar Java que viene con Android Studio (MÁS RÁPIDO) ⭐

Android Studio YA incluye Java. Solo necesitas encontrarlo:

### Paso 1: Buscar keytool en Android Studio

**Ubicaciones comunes:**
```
C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe
C:\Program Files\Android\Android Studio\jre\bin\keytool.exe
```

### Paso 2: Ejecutar con ruta completa

```cmd
cd C:\Proyectos\Cargo_click_mockpup\android

"C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**O si está en jre:**
```cmd
"C:\Program Files\Android\Android Studio\jre\bin\keytool.exe" -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

---

## OPCIÓN 2: Buscar keytool automáticamente

### Ejecuta este comando para encontrarlo:

```cmd
dir /s /b "C:\Program Files\Android\Android Studio\keytool.exe"
```

O en todo el disco C:
```cmd
where /R "C:\Program Files" keytool.exe
```

Luego usa la ruta que encuentre.

---

## OPCIÓN 3: Instalar Java JDK

Si Android Studio no está instalado o no lo encuentras:

### 1. Descargar Java JDK:

**Opción A - Microsoft OpenJDK (Recomendado para Windows):**
- Link: https://learn.microsoft.com/en-us/java/openjdk/download
- Descargar: OpenJDK 17 o superior (MSI installer)
- Instalar con opciones por defecto

**Opción B - Oracle JDK:**
- Link: https://www.oracle.com/java/technologies/downloads/
- Descargar: JDK 17 o superior
- Instalar

**Opción C - Eclipse Temurin (Adoptium):**
- Link: https://adoptium.net/
- Descargar: JDK 17 o superior
- Instalar

### 2. Verificar instalación:

```cmd
java -version
keytool
```

Si `keytool` no funciona, continúa al paso 3.

### 3. Agregar al PATH (si es necesario):

**Windows 11/10:**
1. Buscar "Variables de entorno" en el inicio
2. Click en "Variables de entorno"
3. En "Variables del sistema", buscar "Path"
4. Click "Editar"
5. Click "Nuevo"
6. Agregar: `C:\Program Files\Java\jdk-17\bin` (ajustar según tu instalación)
7. Click "Aceptar" en todo
8. **CERRAR y REABRIR** la terminal

### 4. Reintentar:

```cmd
cd C:\Proyectos\Cargo_click_mockpup\android
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

---

## 📋 PROCESO COMPLETO DEL KEYSTORE

Una vez que `keytool` funcione:

### 1. Ejecutar comando:

```cmd
cd C:\Proyectos\Cargo_click_mockpup\android

keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 2. Responder preguntas:

**Pregunta 1:** `Introduzca la contraseña del almacén de claves:`
- Escribe una contraseña SEGURA
- **¡GUÁRDALA! La necesitarás**

**Pregunta 2:** `Vuelva a escribir la contraseña nueva:`
- Repite la misma contraseña

**Pregunta 3:** `¿Cuál es su nombre y apellido?`
- Tu nombre completo (ej: Juan Pérez)

**Pregunta 4:** `¿Cuál es el nombre de su unidad de organización?`
- Nombre de tu empresa (ej: CargoClick)

**Pregunta 5:** `¿Cuál es el nombre de su organización?`
- Nombre de tu empresa (ej: CargoClick SpA)

**Pregunta 6:** `¿Cuál es el nombre de su ciudad o localidad?`
- Tu ciudad (ej: Santiago)

**Pregunta 7:** `¿Cuál es el nombre de su estado o provincia?`
- Tu región (ej: Región Metropolitana)

**Pregunta 8:** `¿Cuál es el código de país de dos letras para esta unidad?`
- CL (para Chile)

**Pregunta 9:** `¿Es correcto?`
- Escribe: `si` o `yes`

**Pregunta 10:** `Introduzca la contraseña de clave para <upload>`
- Presiona ENTER (usa la misma contraseña que antes)
- O escribe una diferente (pero GUÁRDALA)

### 3. ✅ Resultado:

Verás algo como:
```
Generando par de claves RSA de 2.048 bits...
[Almacenando upload-keystore.jks]
```

### 4. Verificar archivo creado:

```cmd
dir upload-keystore.jks
```

Debe aparecer el archivo.

---

## 📄 CREAR key.properties

### 1. Crea el archivo:

```cmd
cd C:\Proyectos\Cargo_click_mockpup\android
notepad key.properties
```

### 2. Escribe esto (con TUS contraseñas):

```properties
storePassword=TU_CONTRASEÑA_AQUI
keyPassword=TU_CONTRASEÑA_AQUI
keyAlias=upload
storeFile=upload-keystore.jks
```

**Ejemplo:**
```properties
storePassword=miPasswordSeguro123
keyPassword=miPasswordSeguro123
keyAlias=upload
storeFile=upload-keystore.jks
```

### 3. Guardar y cerrar

---

## ⚠️ IMPORTANTE

### ✅ HACER:
- [ ] Respaldar `upload-keystore.jks` en 3 lugares:
  - USB
  - Nube privada (Google Drive, Dropbox)
  - Disco externo
- [ ] Guardar contraseñas en password manager
- [ ] Guardar contraseñas en archivo seguro
- [ ] NO compartir con nadie

### ❌ NO HACER:
- ❌ NO subir a Git (ya protegido en .gitignore)
- ❌ NO perder el archivo
- ❌ NO olvidar las contraseñas
- ❌ NO compartir públicamente

**Si pierdes el keystore, NO podrás actualizar tu app NUNCA.**

---

## 🧪 PROBAR QUE FUNCIONA

Una vez creado, prueba generar el build:

```cmd
cd C:\Proyectos\Cargo_click_mockpup
build-release.bat
```

O manualmente:
```cmd
flutter clean
flutter pub get
flutter build appbundle --release
```

Si funciona, verás:
```
✓ Built build\app\outputs\bundle\release\app-release.aab
```

---

## 🆘 PROBLEMAS COMUNES

### Error: "Contraseña incorrecta"
- Verifica que `key.properties` tenga las contraseñas correctas
- Sin espacios extras
- Sin comillas

### Error: "storeFile not found"
- Verifica que `upload-keystore.jks` esté en la carpeta `android/`
- Ruta correcta en `key.properties`

### Error: "keytool sigue sin funcionar"
- Reinicia la terminal después de instalar Java
- Verifica PATH
- Usa ruta completa al keytool

---

## 📞 NECESITAS AYUDA?

Si nada funciona:
1. Dime qué mensaje de error ves
2. Envía output de: `dir "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"`
3. O output de: `java -version`

---

**¡Éxito! Una vez creado el keystore, estarás al 90% del camino! 🚀**
