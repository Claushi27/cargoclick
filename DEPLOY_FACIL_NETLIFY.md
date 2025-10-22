# DEPLOY RÁPIDO CON NETLIFY (SIN INSTALAR FLUTTER)

## Método 1: Usando Zapp.run (Compilador Flutter Online)

### Paso 1: Subir proyecto a GitHub
1. Ve a https://github.com/new
2. Crea un repo público llamado `cargoclick`
3. En tu terminal:
   ```bash
   cd C:\Proyectos\Cargo_click_mockpup
   git init
   git add .
   git commit -m "CargoClick initial commit"
   git branch -M main
   git remote add origin https://github.com/TU_USUARIO/cargoclick.git
   git push -u origin main
   ```

### Paso 2: Compilar con Zapp.run
1. Ve a https://zapp.run/new
2. Click "Import from GitHub"
3. Conecta tu cuenta de GitHub
4. Selecciona el repo `cargoclick`
5. Espera que cargue (1-2 minutos)
6. En el menú superior, selecciona "Web" como platform
7. Click en el botón de build (ícono de martillo)
8. Espera a que compile (2-5 minutos)
9. Click derecho en la carpeta `build/web` → Download

### Paso 3: Deploy a Netlify
1. Ve a https://app.netlify.com/drop
2. Arrastra la carpeta `build/web` que descargaste
3. ¡Listo! Te da una URL tipo: `https://random-name-12345.netlify.app`

### Paso 4: Configurar dominio personalizado (opcional)
1. En Netlify, click "Site settings"
2. "Change site name" → pon `cargoclick` (si está disponible)
3. Ahora será: `https://cargoclick.netlify.app`

---

## Método 2: GitHub + Netlify (Deploy automático - RECOMENDADO)

### Paso 1: Subir a GitHub (igual que arriba)

### Paso 2: Conectar Netlify a GitHub
1. Ve a https://app.netlify.com
2. Click "Add new site" → "Import an existing project"
3. Selecciona GitHub
4. Autoriza Netlify
5. Busca y selecciona `cargoclick`
6. **NO configures nada manualmente** - El archivo `netlify.toml` ya tiene todo configurado
7. Click "Deploy site"
8. **ESPERA 10-15 MINUTOS** - La primera vez tarda porque descarga Flutter

**IMPORTANTE**: El archivo `netlify.toml` ya incluye la instalación de Flutter automáticamente.

---

## Método 3: Usando CodeSandbox (El MÁS RÁPIDO)

### Paso 1: Crear cuenta en CodeSandbox
1. Ve a https://codesandbox.io
2. Regístrate con GitHub

### Paso 2: Importar proyecto
1. Click "Import repository"
2. Pega la URL de tu repo de GitHub
3. Espera a que cargue

### Paso 3: Build y deploy
1. CodeSandbox compilará automáticamente
2. Ve al preview
3. Click en "Deploy" (botón arriba)
4. Selecciona Netlify
5. Autoriza y listo

**Este método es el más fácil porque CodeSandbox compila automáticamente cada vez que hagas cambios.**

---

## ⚡ RECOMENDACIÓN FINAL: CodeSandbox + Netlify

Es la combinación perfecta porque:
- No instalas nada
- Editas código directo en el navegador
- Compila automáticamente
- Deploy con un click
- Gratis
- Perfecto para pruebas y desarrollo

## Próximos pasos AHORA MISMO:

1. ¿Tienes cuenta de GitHub? Si no, créala: https://github.com/signup
2. Sube el código (te ayudo con los comandos)
3. Usamos CodeSandbox para compilar y deployar

**¿Listo para empezar?** Dime si ya tienes GitHub y comenzamos.
