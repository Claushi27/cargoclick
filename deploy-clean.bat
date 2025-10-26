@echo off
echo ========================================
echo   DEPLOY LIMPIO A FIREBASE HOSTING
echo ========================================
echo.

echo [1/4] Limpiando cache de Flutter...
flutter clean

echo.
echo [2/4] Obteniendo dependencias...
flutter pub get

echo.
echo [3/4] Building web en modo release...
flutter build web --release

echo.
echo [4/4] Desplegando a Firebase Hosting...
firebase deploy --only hosting

echo.
echo ========================================
echo   DEPLOY COMPLETADO
echo ========================================
echo.
echo URL: https://sellora-2xtskv.web.app
echo.
echo IMPORTANTE: Hacer HARD REFRESH en el navegador
echo Ctrl + Shift + R (Chrome/Firefox)
echo Cmd + Shift + R (Mac)
echo.
pause
