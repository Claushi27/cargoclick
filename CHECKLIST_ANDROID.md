# ✅ CHECKLIST PRE-LANZAMIENTO ANDROID
## CargoClick v1.0.0

---

## 📱 CONFIGURACIÓN ANDROID

### Archivos de configuración:
- [x] `android/app/build.gradle` - Configurado para producción
  - [x] applicationId: com.cargoclick.app
  - [x] versionCode: 1
  - [x] versionName: 1.0.0
  - [x] Firma release configurada
  - [x] ProGuard habilitado

- [x] `android/app/proguard-rules.pro` - Reglas de ofuscación creadas
- [x] `android/app/src/main/AndroidManifest.xml` - Permisos correctos
- [x] `android/app/src/main/res/values/strings.xml` - Nombre de app
- [x] `android/app/src/main/res/values/colors.xml` - Colores splash

### Documentación creada:
- [x] `PRIVACY_POLICY.md` - Política de privacidad completa
- [x] `PLAY_STORE_LISTING.md` - Descripción y metadata
- [x] `GUIA_DEPLOY_ANDROID.md` - Guía paso a paso
- [x] `android/CREAR_KEYSTORE.txt` - Instrucciones keystore
- [x] `android/key.properties.template` - Template de credenciales
- [x] `build-release.bat` - Script automatizado

---

## 🔐 SEGURIDAD

### Keystore (Firma de la app):
- [ ] Keystore creado (`upload-keystore.jks`)
  - Comando: `keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
  - Ubicación: `android/upload-keystore.jks`
  
- [ ] Archivo `key.properties` creado
  - Ubicación: `android/key.properties`
  - Contiene: storePassword, keyPassword, keyAlias, storeFile
  
- [ ] Keystore respaldado en 3 lugares seguros
  - [ ] Ubicación 1: _____________
  - [ ] Ubicación 2: _____________
  - [ ] Ubicación 3: _____________

- [ ] Credenciales guardadas en lugar seguro
  - [ ] Password manager
  - [ ] Documento encriptado
  - [ ] Caja fuerte física

⚠️ **CRÍTICO**: Si pierdes el keystore NO podrás actualizar la app NUNCA

---

## 🎨 ASSETS VISUALES

### Íconos de la app:
- [ ] Logo en alta resolución (1024x1024 mínimo)
- [ ] Íconos generados para todos los tamaños
  - [ ] mipmap-mdpi (48x48)
  - [ ] mipmap-hdpi (72x72)
  - [ ] mipmap-xhdpi (96x96)
  - [ ] mipmap-xxhdpi (144x144)
  - [ ] mipmap-xxxhdpi (192x192)
- [ ] Adaptive icons (Android 8+)
- [ ] Colocados en: `android/app/src/main/res/mipmap-*/`

**Herramienta recomendada:** https://icon.kitchen/

### Splash Screen:
- [ ] Logo para splash (`splash_logo.png`)
- [ ] Ubicado en: `android/app/src/main/res/drawable/`
- [ ] Color de fondo configurado en `colors.xml`

### Screenshots (Google Play):
- [ ] Mínimo 2 capturas (recomendado 4-8)
- [ ] Tamaño: 1080x1920 o 1440x2560
- [ ] Formato: PNG o JPEG

**Capturas sugeridas:**
1. [ ] Login/Registro
2. [ ] Dashboard/Lista de fletes
3. [ ] Detalle de flete con mapa
4. [ ] Checkpoints con fotos
5. [ ] Validación de documentos
6. [ ] Sistema de rating
7. [ ] Notificaciones
8. [ ] Hoja de cobro

### Feature Graphic:
- [ ] Imagen creada (1024x500)
- [ ] Formato: PNG o JPEG
- [ ] Sin bordes blancos
- [ ] Incluye: Logo + Slogan + Mockup

**Herramientas:** Canva, Figma

---

## 📄 DOCUMENTACIÓN LEGAL

### Privacy Policy:
- [ ] Texto completo escrito (ver `PRIVACY_POLICY.md`)
- [ ] Publicada online (accesible públicamente)
  - Opciones:
    - [ ] GitHub Pages (gratis)
    - [ ] Sitio web propio
    - [ ] Google Sites (gratis)
- [ ] URL de la policy: ____________________________

### Información de contacto:
- [ ] Email de soporte: soporte@cargoclick.cl
- [ ] Dirección de empresa: ____________________________
- [ ] RUT de empresa: ____________________________
- [ ] Representante legal: ____________________________

---

## 🏗️ BUILD DE PRODUCCIÓN

### Preparación:
- [x] Código limpio sin errores
- [x] Todas las features funcionando
- [ ] Testing en dispositivos físicos
  - [ ] Android viejo (API 21-23)
  - [ ] Android moderno (API 30+)
  - [ ] Diferentes tamaños de pantalla

### Generar build:
- [ ] Ejecutar `flutter clean`
- [ ] Ejecutar `flutter pub get`
- [ ] Ejecutar `flutter build appbundle --release`
  - O ejecutar: `build-release.bat` (automático)

### Verificar archivos:
- [ ] AAB generado: `build/app/outputs/bundle/release/app-release.aab`
- [ ] APK generado: `build/app/outputs/flutter-apk/app-release.apk`
- [ ] Tamaño razonable (< 50 MB para AAB)

---

## 🧪 TESTING FINAL

### Funcionalidades core:
- [ ] Login/Registro funciona
- [ ] Publicar flete funciona
- [ ] Asignar flete funciona
- [ ] Tracking GPS funciona
- [ ] Subir fotos funciona (cámara + galería)
- [ ] Notificaciones push funcionan
- [ ] Emails se envían correctamente
- [ ] Validación de documentos funciona
- [ ] Sistema de rating funciona
- [ ] Hoja de cobro se genera

### Performance:
- [ ] App inicia en < 3 segundos
- [ ] No hay crashes
- [ ] Memoria bajo control
- [ ] Batería no se consume excesivamente
- [ ] Imágenes cargan rápido (compresión)

### Permisos:
- [ ] GPS solicita permiso correctamente
- [ ] Cámara solicita permiso correctamente
- [ ] Notificaciones solicitan permiso
- [ ] Mensajes de permiso son claros

---

## 🏪 GOOGLE PLAY CONSOLE

### Cuenta:
- [ ] Cuenta de desarrollador creada
- [ ] $25 USD pagados
- [ ] Acceso a https://play.google.com/console

### Información de la app:
- [ ] Nombre: CargoClick
- [ ] Categoría: Negocios (Business)
- [ ] Clasificación: PEGI 3 / Everyone
- [ ] Países: Chile + LATAM seleccionados
- [ ] Idioma: Español (Chile)

### Contenido de la tienda:
- [ ] Título (50 caracteres): "CargoClick - Gestión de Fletes"
- [ ] Descripción corta (80 caracteres)
- [ ] Descripción completa (ver `PLAY_STORE_LISTING.md`)
- [ ] Screenshots subidos (mínimo 2)
- [ ] Icono de app subido (512x512)
- [ ] Feature graphic subido (1024x500)

### Configuración de release:
- [ ] AAB subido
- [ ] Notas de la versión agregadas
- [ ] Advertencias revisadas
- [ ] Release marcado como producción

### Políticas:
- [ ] Privacy Policy URL agregada
- [ ] Email de contacto agregado
- [ ] Cuestionario de contenido completado
- [ ] Declaraciones de cumplimiento aceptadas

---

## 📤 ENVÍO A REVISIÓN

### Pre-envío:
- [ ] Todos los campos requeridos completados
- [ ] No hay errores marcados en rojo
- [ ] Screenshots se ven bien
- [ ] Descripción sin errores de ortografía

### Envío:
- [ ] Click en "Revisar release"
- [ ] Verificar resumen final
- [ ] Click en "Iniciar implementación en producción"
- [ ] Confirmación recibida

### Post-envío:
- [ ] Estado: "En revisión" visible
- [ ] Email de confirmación recibido
- [ ] Fecha de envío: ____________________

---

## ⏰ TIEMPOS ESPERADOS

- **Revisión de Google:** 1-7 días (promedio 2-3 días)
- **Primera aprobación:** Puede tardar más
- **Actualizaciones posteriores:** Usualmente más rápido

---

## 📊 POST-LANZAMIENTO

### Monitoreo (primeras 24 horas):
- [ ] Revisar crashes en Play Console
- [ ] Revisar calificaciones
- [ ] Revisar comentarios
- [ ] Responder reviews

### Primera semana:
- [ ] Monitorear instalaciones diarias
- [ ] Revisar tasa de desinstalación
- [ ] Analizar países con más descargas
- [ ] Identificar bugs reportados

### Primer mes:
- [ ] Compilar feedback de usuarios
- [ ] Planificar versión 1.1
- [ ] Optimizar listing si es necesario
- [ ] Promoción en redes sociales

---

## 🚨 PROBLEMAS COMUNES

### App rechazada:
- [ ] Leer motivo del rechazo
- [ ] Corregir problema
- [ ] Re-subir release
- [ ] Agregar nota explicando corrección

### Crashes reportados:
- [ ] Revisar stack traces en Play Console
- [ ] Reproducir localmente
- [ ] Corregir
- [ ] Generar versión 1.0.1

### Reviews negativas:
- [ ] Responder profesionalmente
- [ ] Ofrecer solución
- [ ] Mejorar en próxima versión

---

## 📝 NOTAS IMPORTANTES

### Versioning:
- **versionCode** se incrementa en 1 cada release (1, 2, 3...)
- **versionName** sigue semver (1.0.0, 1.0.1, 1.1.0, 2.0.0)

### Actualizaciones:
Para cada actualización:
1. Incrementar versionCode y versionName en build.gradle
2. Generar nuevo build
3. Crear nuevo release en Play Console
4. Agregar notas de cambios

### Rollback:
Si algo sale mal después de publicar:
- Play Console permite pausar rollout
- Puedes volver a versión anterior
- Usuarios nuevos no verán la versión problemática

---

## ✅ RESUMEN FINAL

**Antes de enviar, verifica:**

- [ ] ✅ Keystore creado y respaldado
- [ ] ✅ Build de producción generado sin errores
- [ ] ✅ Privacy Policy publicada online
- [ ] ✅ Screenshots de calidad
- [ ] ✅ Descripción completa y sin errores
- [ ] ✅ Testing en dispositivos reales
- [ ] ✅ Cuenta Play Console activa
- [ ] ✅ Toda la info de la tienda completada

**Si todo está marcado, ¡ESTÁS LISTO PARA PUBLICAR! 🚀**

---

## 📞 RECURSOS DE AYUDA

- **Guía completa:** Ver `GUIA_DEPLOY_ANDROID.md`
- **Privacy Policy:** Ver `PRIVACY_POLICY.md`
- **Descripción Play Store:** Ver `PLAY_STORE_LISTING.md`
- **Script de build:** Ejecutar `build-release.bat`

**Documentación oficial:**
- Flutter: https://docs.flutter.dev/deployment/android
- Google Play: https://support.google.com/googleplay/android-developer

---

**Última actualización:** 15 Noviembre 2025  
**Versión del checklist:** 1.0
