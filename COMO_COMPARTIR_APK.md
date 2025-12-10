# 📱 CÓMO COMPARTIR Y PROBAR EL APK DE CARGOCLICK

## 📦 APK GENERADO

**Ubicación:** `build\app\outputs\flutter-apk\app-release.apk`  
**Tamaño:** 61.9 MB (64,938,601 bytes)  
**Versión:** 1.0.0  
**Package:** com.cargoclick.app

---

## 🚀 MÉTODOS PARA COMPARTIR EL APK

### Opción 1: WhatsApp (MÁS FÁCIL) ✅

1. Abre WhatsApp en tu PC
2. Envía el APK como archivo adjunto a la persona que quieres que pruebe
3. La persona lo descarga desde WhatsApp en su celular
4. Abre el archivo descargado y acepta "Instalar apps desconocidas"
5. Instala la app

**Pros:** Súper rápido y fácil  
**Contras:** Límite de 100 MB (pero tu APK es de 61.9 MB, así que pasa)

---

### Opción 2: Google Drive (RECOMENDADO) ✅

1. Sube el APK a Google Drive
2. Haz clic derecho → "Obtener enlace"
3. Cambia a "Cualquiera con el enlace puede ver"
4. Copia el enlace
5. Comparte el enlace por WhatsApp/Email
6. La persona lo descarga en su celular Android

**Pros:** Profesional, no hay límite de tamaño, puedes compartir con muchas personas  
**Contras:** Necesitas cuenta de Google

**Pasos detallados:**
```
1. Ve a drive.google.com
2. Arrastra app-release.apk
3. Clic derecho en el archivo → Compartir
4. "Cambiar a cualquiera con el enlace"
5. Copiar enlace
6. Compartir
```

---

### Opción 3: Telegram

1. Abre Telegram
2. Envía el APK como archivo
3. La persona lo descarga e instala

**Pros:** Rápido, sin compresión  
**Contras:** Necesitas Telegram

---

### Opción 4: Email

1. Crea un nuevo email
2. Adjunta el APK
3. Envíalo

**Pros:** Formal y profesional  
**Contras:** Algunos emails tienen límite de tamaño (Gmail: 25 MB) - **NO FUNCIONARÁ**

---

### Opción 5: Dropbox / OneDrive

Similar a Google Drive:
1. Sube el archivo
2. Comparte el enlace
3. La persona lo descarga

---

## 📲 CÓMO INSTALAR EL APK EN ANDROID

### En el celular que va a probar:

**Paso 1: Habilitar instalación de fuentes desconocidas**
1. Abre **Configuración**
2. Busca "**Seguridad**" o "**Privacidad**"
3. Encuentra "**Fuentes desconocidas**" o "**Instalar apps desconocidas**"
4. Habilita la opción para **Chrome** o **WhatsApp** (según de dónde descargues)

**En Android moderno (10+):**
- Configuración → Apps → Acceso especial → Instalar apps desconocidas
- Selecciona Chrome/WhatsApp/Drive → Permitir

**Paso 2: Descargar el APK**
1. Abre el enlace que compartiste
2. Descarga el archivo `app-release.apk`
3. Espera a que termine la descarga

**Paso 3: Instalar**
1. Abre el archivo descargado (desde notificaciones o carpeta Descargas)
2. Si pide permisos, acepta "**Instalar desde esta fuente**"
3. Toca **Instalar**
4. Espera unos segundos
5. Toca **Abrir**

**Paso 4: ¡Listo!**
- La app debe abrir correctamente
- Verás el logo de CargoClick
- Podrás usar todas las funcionalidades

---

## ✅ QUÉ PROBAR EN LA APP

### Pruebas Básicas:
- [ ] La app abre sin crashear
- [ ] El logo se ve correctamente
- [ ] Puedes hacer login
- [ ] Puedes registrarte
- [ ] Firebase funciona

### Pruebas de Funcionalidad:
- [ ] Crear orden de transporte
- [ ] Ver órdenes
- [ ] Editar perfil
- [ ] Notificaciones
- [ ] Subir fotos
- [ ] Ver mapa/tracking

### Pruebas de Performance:
- [ ] La app no se traba
- [ ] Navegar entre pantallas es fluido
- [ ] Las imágenes cargan bien

---

## 🐛 SI HAY PROBLEMAS

### "No se puede instalar"
- Verifica que habilitaste "Fuentes desconocidas"
- Intenta desde otra app (Chrome en vez de WhatsApp)

### "La app crashea al abrir"
- Desinstala completamente
- Vuelve a instalar
- Si sigue crasheando, manda screenshot del error

### "No descarga"
- Verifica conexión a internet
- Prueba otro método de compartir
- Verifica espacio en el celular (necesitas ~200 MB libres)

---

## 📊 FORMATO PARA REPORTAR PRUEBAS

Cuando alguien pruebe la app, pídele que te mande:

```
✅ REPORTE DE PRUEBA - CARGOCLICK

Celular: [Marca y modelo]
Android: [Versión]
Fecha: [Hoy]

INSTALACIÓN:
- [ ] Se descargó correctamente
- [ ] Se instaló sin problemas
- [ ] Abrió correctamente

FUNCIONALIDAD:
- [ ] Login funciona
- [ ] Ver órdenes funciona
- [ ] [Otras funciones probadas]

PROBLEMAS ENCONTRADOS:
- [Ninguno / Lista de problemas]

COMENTARIOS:
- [Opiniones y sugerencias]
```

---

## 🎯 PRÓXIMOS PASOS DESPUÉS DE PROBAR

### Si todo funciona bien:
1. ✅ Tomar screenshots de la app
2. ✅ Generar AAB para Play Store
3. ✅ Crear cuenta Google Play Console ($25 USD único pago)
4. ✅ Subir a Play Store para revisión

### Si hay bugs:
1. ⚠️ Recopilar reportes
2. ⚠️ Arreglar problemas
3. ⚠️ Generar nuevo APK
4. ⚠️ Volver a probar

---

## 📁 COMANDO RÁPIDO PARA GENERAR NUEVO APK

Si necesitas regenerar el APK:

```cmd
flutter clean
flutter build apk --release
```

O usa el script automatizado:
```cmd
build-release.bat
```

---

## 🔐 NOTA IMPORTANTE

**Este APK NO está en Play Store todavía.**

- Es una versión de prueba (sideload)
- Solo pueden instalarlo directamente (no desde la tienda)
- Una vez subida a Play Store, se actualiza automáticamente

---

## ✨ VENTAJAS DE ESTA VERSIÓN

✅ **Firmada con keystore de producción**  
✅ **Optimizada (release mode)**  
✅ **Mismo package que usarás en Play Store**  
✅ **Firebase configurado correctamente**  
✅ **Logo nuevo incluido**  

---

## 🚀 LISTO PARA COMPARTIR

**Tu APK está en:**
```
C:\Proyectos\Cargo_click_mockpup\build\app\outputs\flutter-apk\app-release.apk
```

**Solo necesitas:**
1. Subirlo a Drive/WhatsApp/Telegram
2. Compartir el enlace
3. Que la persona lo descargue e instale
4. ¡Probar!

---

## 📞 SOPORTE

Si tienes problemas:
1. Revisa que el APK esté completo (61.9 MB)
2. Verifica que descargue completo en el celular
3. Asegúrate de habilitar fuentes desconocidas
4. Si crashea, toma screenshot del error

---

**¡Buena suerte con las pruebas!** 🎉

**Versión generada:** 18 Noviembre 2025  
**Build:** Release 1.0.0  
**Estado:** ✅ Listo para distribución de prueba
