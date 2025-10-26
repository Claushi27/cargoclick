# 🚀 Deploy a Firebase Hosting

## Por qué Firebase Hosting?

- ✅ **GRATIS:** 10GB storage + 360MB/día transferencia
- ✅ **Integrado con tu proyecto Firebase actual**
- ✅ **CDN global automático**
- ✅ **SSL gratis**
- ✅ **No hay límite de builds mensuales** (vs Netlify 300 minutos)
- ✅ **Deploy en 2 comandos**

---

## Paso 1: Instalar Firebase CLI (si no lo tienes)

```powershell
npm install -g firebase-tools
```

## Paso 2: Login a Firebase

```powershell
firebase login
```

## Paso 3: Inicializar Hosting (solo primera vez)

```powershell
# Ya está configurado en firebase.json, solo verificar
firebase use sellora-2xtskv
```

## Paso 4: Build LIMPIO de Flutter Web

**IMPORTANTE:** Siempre limpiar cache antes de build

```powershell
# Limpiar cache (OBLIGATORIO)
flutter clean

# Obtener dependencias
flutter pub get

# Build release
flutter build web --release
```

## Paso 5: Deploy a Firebase Hosting

```powershell
firebase deploy --only hosting
```

### ⚡ ATAJO: Usar script automático

```powershell
# Ejecutar deploy limpio automático
.\deploy-clean.bat
```

**¡Listo!** Tu app estará en: `https://sellora-2xtskv.web.app`

---

## 🔄 Deploy Automático con GitHub Actions

Crea el archivo `.github/workflows/firebase-deploy.yml`:

```yaml
name: Deploy to Firebase Hosting

on:
  push:
    branches:
      - main

jobs:
  build_and_deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.35.7'
          channel: 'stable'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Build web
        run: flutter build web --release
      
      - name: Deploy to Firebase
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
          channelId: live
          projectId: sellora-2xtskv
```

---

## Configurar Secret de Firebase

1. Ve a Firebase Console → Project Settings → Service Accounts
2. Click "Generate new private key"
3. Descarga el JSON
4. En GitHub: Settings → Secrets and Variables → Actions
5. Crea secret `FIREBASE_SERVICE_ACCOUNT` con el contenido del JSON

---

## URLs del Proyecto

- **Producción:** https://sellora-2xtskv.web.app
- **Alternativa:** https://sellora-2xtskv.firebaseapp.com
- **Console:** https://console.firebase.google.com/project/sellora-2xtskv/hosting

---

## Comandos Útiles

```powershell
# Build local
flutter build web --release

# Deploy manual
firebase deploy --only hosting

# Preview antes de deploy
firebase hosting:channel:deploy preview

# Ver logs
firebase hosting:sites:list

# Rollback a versión anterior
# (desde Firebase Console → Hosting → Release History)
```

---

## Ventajas vs Netlify

| Feature | Netlify Free | Firebase Free |
|---------|--------------|---------------|
| Build minutes | 300/mes | ❌ Ilimitado (build local) |
| Bandwidth | 100GB/mes | 10GB storage + 360MB/día |
| Sites | 1 | Ilimitado |
| Deploy automático | ✅ | ✅ (con GitHub Actions) |
| CDN | ✅ | ✅ |
| SSL | ✅ | ✅ |
| Integración Firebase | ❌ | ✅ Perfecta |
| Custom domain | ✅ | ✅ |

---

## Solución de Problemas

### Error: "Firebase project not found"
```powershell
firebase projects:list
firebase use sellora-2xtskv
```

### Error: "Not authorized"
```powershell
firebase logout
firebase login
```

### Build/web no existe
```powershell
flutter build web --release
```

### Caché en navegador
Hacer hard refresh: `Ctrl + Shift + R`
