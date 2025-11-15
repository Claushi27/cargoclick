@echo off
REM ====================================
REM Script para generar build de producción
REM CargoClick - Android Release
REM ====================================

echo.
echo ========================================
echo   CARGOCLICK - BUILD DE PRODUCCION
echo ========================================
echo.

REM Verificar que estamos en la carpeta correcta
if not exist "pubspec.yaml" (
    echo [ERROR] No se encuentra pubspec.yaml
    echo [ERROR] Ejecuta este script desde la raiz del proyecto
    pause
    exit /b 1
)

echo [1/7] Verificando keystore...
if not exist "android\upload-keystore.jks" (
    echo.
    echo [ADVERTENCIA] No se encuentra el keystore!
    echo.
    echo Por favor crea el keystore primero:
    echo   1. Abre una terminal en la carpeta android/
    echo   2. Ejecuta: keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
    echo   3. Crea el archivo key.properties con tus credenciales
    echo.
    echo Lee CREAR_KEYSTORE.txt para mas instrucciones
    echo.
    pause
    exit /b 1
)

if not exist "android\key.properties" (
    echo.
    echo [ADVERTENCIA] No se encuentra key.properties!
    echo.
    echo Por favor crea el archivo android/key.properties con:
    echo   storePassword=TU_CONTRASEÑA
    echo   keyPassword=TU_CONTRASEÑA
    echo   keyAlias=upload
    echo   storeFile=upload-keystore.jks
    echo.
    pause
    exit /b 1
)

echo [OK] Keystore encontrado
echo.

echo [2/7] Limpiando proyecto...
call flutter clean
if errorlevel 1 (
    echo [ERROR] Error al limpiar proyecto
    pause
    exit /b 1
)
echo [OK] Proyecto limpio
echo.

echo [3/7] Obteniendo dependencias...
call flutter pub get
if errorlevel 1 (
    echo [ERROR] Error al obtener dependencias
    pause
    exit /b 1
)
echo [OK] Dependencias actualizadas
echo.

echo [4/7] Verificando configuracion...
echo    - ApplicationId: com.cargoclick.app
echo    - VersionName: 1.0.0
echo    - VersionCode: 1
echo [OK] Configuracion verificada
echo.

echo [5/7] Generando App Bundle (AAB)...
echo    Esto puede tardar varios minutos...
echo.
call flutter build appbundle --release
if errorlevel 1 (
    echo.
    echo [ERROR] Error al generar App Bundle
    echo.
    echo Posibles causas:
    echo   - Credenciales incorrectas en key.properties
    echo   - Problemas con el keystore
    echo   - Errores de compilacion
    echo.
    pause
    exit /b 1
)
echo.
echo [OK] App Bundle generado exitosamente!
echo.

echo [6/7] Generando APK (para testing)...
call flutter build apk --release
if errorlevel 1 (
    echo [ADVERTENCIA] No se pudo generar APK, pero AAB esta OK
) else (
    echo [OK] APK generado exitosamente!
)
echo.

echo [7/7] Verificando archivos generados...
echo.

if exist "build\app\outputs\bundle\release\app-release.aab" (
    echo [OK] App Bundle encontrado:
    echo     build\app\outputs\bundle\release\app-release.aab
    for %%I in (build\app\outputs\bundle\release\app-release.aab) do echo     Tamaño: %%~zI bytes
    echo.
) else (
    echo [ERROR] App Bundle NO encontrado!
    pause
    exit /b 1
)

if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo [OK] APK encontrado:
    echo     build\app\outputs\flutter-apk\app-release.apk
    for %%I in (build\app\outputs\flutter-apk\app-release.apk) do echo     Tamaño: %%~zI bytes
    echo.
)

echo ========================================
echo   BUILD COMPLETADO EXITOSAMENTE!
echo ========================================
echo.
echo Archivos listos para subir a Play Store:
echo.
echo   1. AAB (Google Play):
echo      build\app\outputs\bundle\release\app-release.aab
echo.
echo   2. APK (Testing directo):
echo      build\app\outputs\flutter-apk\app-release.apk
echo.
echo Proximos pasos:
echo   1. Ir a https://play.google.com/console
echo   2. Crear nueva aplicacion o nuevo release
echo   3. Subir el archivo app-release.aab
echo   4. Completar la informacion de la tienda
echo   5. Enviar a revision
echo.
echo Buena suerte! 🚀
echo.

pause
