# 🚀 GUÍA DE INSTALACIÓN DE FLUTTER - Windows

## 📋 REQUISITOS PREVIOS

Antes de empezar, necesitas:
- ✅ Windows 10 o superior (64-bit)
- ✅ Espacio en disco: ~2.5 GB
- ✅ Git instalado (ya lo tienes)
- ✅ Editor de código (VS Code recomendado)

---

## 🔽 PASO 1: DESCARGAR FLUTTER

1. Ve a: https://docs.flutter.dev/get-started/install/windows
2. Click en **"Download Flutter SDK"**
3. O descarga directamente: https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip

**Tiempo estimado:** 2-5 minutos (depende de tu conexión)

---

## 📂 PASO 2: EXTRAER FLUTTER

1. **Crea una carpeta** en `C:\` llamada `src`:
   ```
   C:\src
   ```

2. **Extrae el archivo ZIP** en esa carpeta:
   - Click derecho en `flutter_windows_xxx.zip`
   - "Extraer aquí" o "Extract Here"
   - Deberías tener: `C:\src\flutter\`

⚠️ **IMPORTANTE:** NO instales Flutter en carpetas con:
- Espacios en el nombre
- Permisos especiales (como `Program Files`)
- Caracteres especiales

---

## 🔧 PASO 3: CONFIGURAR VARIABLES DE ENTORNO

### Opción A: Manual (Recomendado)

1. **Abre el menú inicio** y busca: "variables de entorno"
2. Click en **"Editar las variables de entorno del sistema"**
3. Click en **"Variables de entorno..."**
4. En "Variables del sistema", busca **Path** y click en **Editar**
5. Click en **Nuevo**
6. Agrega: `C:\src\flutter\bin`
7. Click **Aceptar** en todas las ventanas

### Opción B: Por PowerShell (Ejecutar como Administrador)

```powershell
[System.Environment]::SetEnvironmentVariable(
    "Path",
    [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User) + ";C:\src\flutter\bin",
    [System.EnvironmentVariableTarget]::User
)
```

---

## ✅ PASO 4: VERIFICAR INSTALACIÓN

Abre una **nueva ventana de PowerShell** (importante: nueva ventana) y ejecuta:

```powershell
flutter --version
```

Deberías ver algo como:
```
Flutter 3.24.5 • channel stable • https://github.com/flutter/flutter.git
Framework • revision xxx
Engine • revision xxx
Tools • Dart 3.5.4 • DevTools 2.37.3
```

---

## 🔍 PASO 5: DIAGNÓSTICO DE FLUTTER

Ejecuta este comando para ver qué falta:

```powershell
flutter doctor
```

**Salida esperada:**
```
[✓] Flutter (Channel stable, 3.24.5)
[✗] Android toolchain - develop for Android devices
    ✗ Unable to locate Android SDK
[✓] Chrome - develop for the web
[✗] Visual Studio - develop for Windows
[✗] Android Studio (not installed)
[✓] VS Code (version X.X.X)
[!] Connected device
[!] Network resources
```

**NO TE PREOCUPES** por los ❌ en Android/Visual Studio. Solo necesitamos **Chrome para web**.

---

## 🌐 PASO 6: HABILITAR WEB SUPPORT

Ejecuta:

```powershell
flutter config --enable-web
```

Verifica:

```powershell
flutter devices
```

Deberías ver:
```
Chrome (web) • chrome • web-javascript • Google Chrome XXX
Edge (web) • edge • web-javascript • Microsoft Edge XXX
```

---

## 📦 PASO 7: INSTALAR DEPENDENCIAS DEL PROYECTO

Navega a tu proyecto y ejecuta:

```powershell
cd C:\Proyectos\Cargo_click_mockpup
flutter pub get
```

Este comando descarga todas las dependencias de `pubspec.yaml`.

**Tiempo estimado:** 2-3 minutos

---

## 🎨 PASO 8: (OPCIONAL) INSTALAR VS CODE EXTENSIONS

Si usas VS Code, instala estas extensiones:

1. Abre VS Code
2. Ve a Extensions (Ctrl + Shift + X)
3. Busca e instala:
   - **Flutter** (por Dart Code)
   - **Dart** (por Dart Code)

---

## 🚀 PASO 9: EJECUTAR LA APP

Ahora sí, vamos a ver los cambios en vivo:

```powershell
cd C:\Proyectos\Cargo_click_mockpup
flutter run -d chrome
```

Esto abrirá Chrome con tu app corriendo localmente en `localhost:xxxxx`.

**Tiempo de compilación inicial:** 2-5 minutos (solo la primera vez)

---

## 🔥 MODO HOT RELOAD

Una vez que la app está corriendo:

- **Hot Reload:** Presiona `r` en la terminal (recargar sin perder estado)
- **Hot Restart:** Presiona `R` en la terminal (reiniciar app completa)
- **Quit:** Presiona `q` para salir

Cada vez que guardes un archivo `.dart`, se recargará automáticamente.

---

## 🐛 SOLUCIÓN DE PROBLEMAS COMUNES

### Problema 1: "flutter: command not found"

**Solución:**
1. Cierra TODAS las ventanas de PowerShell/CMD
2. Abre una nueva ventana
3. Intenta de nuevo

Si persiste, verifica que agregaste correctamente el PATH.

### Problema 2: "Waiting for another flutter command to release the startup lock"

**Solución:**
```powershell
cd C:\src\flutter
del bin\cache\lockfile
```

### Problema 3: Error al hacer `flutter pub get`

**Solución:**
```powershell
flutter clean
flutter pub get
```

### Problema 4: "No devices found"

**Solución:**
```powershell
flutter config --enable-web
flutter devices
```

Si no aparece Chrome, instálalo desde: https://www.google.com/chrome/

---

## 📝 COMANDOS ÚTILES

```powershell
# Ver versión de Flutter
flutter --version

# Ver dispositivos disponibles
flutter devices

# Limpiar build anterior
flutter clean

# Obtener dependencias
flutter pub get

# Actualizar Flutter
flutter upgrade

# Ver diagnóstico completo
flutter doctor -v

# Compilar para web (producción)
flutter build web --release
```

---

## 🎯 SIGUIENTE PASO

Una vez que tengas Flutter instalado y corriendo:

1. Ejecuta `flutter run -d chrome`
2. Haz login como transportista
3. Deberías ver la nueva vista con 3 botones
4. Haz cambios en el código
5. Presiona `r` para ver cambios al instante

---

## ⏱️ RESUMEN DE TIEMPOS

- Descarga: 2-5 min
- Extracción: 1 min
- Configuración PATH: 2 min
- Flutter doctor: 1 min
- Flutter pub get: 2-3 min
- Primera compilación: 3-5 min

**TOTAL:** ~15-20 minutos

---

## ✅ CHECKLIST FINAL

- [ ] Flutter descargado y extraído en `C:\src\flutter`
- [ ] PATH configurado correctamente
- [ ] `flutter --version` funciona
- [ ] `flutter doctor` muestra ✓ en Flutter y Chrome
- [ ] `flutter config --enable-web` ejecutado
- [ ] `flutter pub get` completado sin errores
- [ ] `flutter run -d chrome` abre la app

---

¿Listo para empezar? Ejecuta el primer comando:

```powershell
cd C:\
mkdir src
```

Y descarga Flutter desde: https://docs.flutter.dev/get-started/install/windows
