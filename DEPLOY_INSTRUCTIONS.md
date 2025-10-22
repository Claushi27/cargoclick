# INSTRUCCIONES PARA DEPLOY A FIREBASE HOSTING

## Paso 1: Crear repositorio en GitHub

1. Ve a https://github.com/new
2. Crea un repositorio nuevo (puede ser privado o público)
3. NO inicialices con README (ya lo tenemos)

## Paso 2: Subir código a GitHub

En tu terminal (cmd o PowerShell) en la carpeta del proyecto:

```bash
git init
git add .
git commit -m "Initial commit - CargoClick app"
git branch -M main
git remote add origin https://github.com/TU_USUARIO/TU_REPO.git
git push -u origin main
```

## Paso 3: Configurar Firebase Hosting

1. Instala Firebase CLI (si no lo tienes):
   - Descarga Node.js de https://nodejs.org
   - Abre terminal y ejecuta: `npm install -g firebase-tools`

2. Login a Firebase:
   ```bash
   firebase login
   ```

3. Inicializa hosting en el proyecto:
   ```bash
   firebase init hosting
   ```
   - Selecciona tu proyecto: sellora-2xtskv
   - Public directory: `build/web`
   - Configure as single-page app: `Yes`
   - Set up automatic builds with GitHub: `No` (lo haremos manual)

## Paso 4: Configurar GitHub Actions (Deploy automático)

1. Genera una Service Account Key:
   - Ve a Firebase Console → Project Settings → Service Accounts
   - Click "Generate new private key"
   - Descarga el archivo JSON

2. Agrega el secreto a GitHub:
   - Ve a tu repo en GitHub → Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Name: `FIREBASE_SERVICE_ACCOUNT`
   - Value: Pega TODO el contenido del archivo JSON descargado
   - Click "Add secret"

3. Crea la carpeta de workflows:
   En tu proyecto, crea manualmente:
   ```
   .github/
     └── workflows/
           └── firebase-hosting-deploy.yml
   ```
   
4. Copia el contenido del archivo `.github_workflows_firebase-hosting-deploy.yml` 
   al nuevo archivo `firebase-hosting-deploy.yml`

5. Haz commit y push:
   ```bash
   git add .
   git commit -m "Add GitHub Actions workflow"
   git push
   ```

## Paso 5: Deploy

Ahora cada vez que hagas push a `main`, GitHub Actions compilará y desplegará automáticamente.

### Deploy manual (si prefieres):

Si tienes Flutter instalado localmente:
```bash
flutter build web --release
firebase deploy --only hosting
```

## Verificar deploy

Después del primer deploy, tu app estará en:
`https://sellora-2xtskv.web.app`

O la URL personalizada que configures en Firebase Console.

## Notas importantes

- El primer deploy puede tardar 5-10 minutos
- Cada push a `main` despliega automáticamente
- Puedes ver el progreso en GitHub → Actions
- Si algo falla, revisa los logs en GitHub Actions

## Troubleshooting

**Error: Flutter not found**
- Verifica que la versión de Flutter en el workflow esté actualizada

**Error: Firebase deploy failed**
- Verifica que el FIREBASE_SERVICE_ACCOUNT esté bien configurado
- Verifica que el projectId en el workflow sea correcto

**La app no carga**
- Revisa la consola del navegador (F12)
- Verifica que firebase_options.dart tenga la configuración correcta para web
