# MÉTODO MÁS FÁCIL Y CONFIABLE 🚀

## GitHub Actions + Netlify Drop

Este método es **100% confiable** y super rápido.

### Paso 1: Subir código a GitHub

```bash
cd C:\Proyectos\Cargo_click_mockpup
git init
git add .
git commit -m "CargoClick app"
git branch -M main
git remote add origin https://github.com/TU_USUARIO/cargoclick.git
git push -u origin main
```

### Paso 2: Configurar GitHub Actions

1. En tu repositorio de GitHub, crea esta estructura de carpetas:
   ```
   .github/
     └── workflows/
           └── build.yml
   ```

2. Copia el contenido del archivo `build-workflow.yml` (que está en la raíz del proyecto) al nuevo archivo `.github/workflows/build.yml`

3. Haz commit y push:
   ```bash
   git add .
   git commit -m "Add GitHub Actions workflow"
   git push
   ```

### Paso 3: Esperar el build (5-7 minutos)

1. Ve a tu repo en GitHub
2. Click en la pestaña "Actions"
3. Verás un workflow corriendo
4. Espera a que termine (se pone verde ✅)

### Paso 4: Descargar el build

1. En la página del workflow completado, baja hasta "Artifacts"
2. Click en "web-build" para descargar
3. Descomprime el archivo ZIP

### Paso 5: Deploy a Netlify Drop

1. Ve a https://app.netlify.com/drop
2. Arrastra la carpeta descomprimida
3. ¡Listo! Tu app está online

### Paso 6: (Opcional) Dominio personalizado

1. En Netlify, click "Site settings"
2. "Change site name" → pon `cargoclick`
3. Tu URL será: `https://cargoclick.netlify.app`

---

## Para actualizar la app después

Cada vez que yo haga cambios aquí:

1. Tú copias los archivos actualizados
2. Haces commit y push:
   ```bash
   git add .
   git commit -m "Actualización"
   git push
   ```
3. GitHub Actions compila automáticamente
4. Descargas el nuevo build
5. Lo arrastras a Netlify (reemplaza el anterior)

**Toma 2 minutos actualizar todo.**

---

## Troubleshooting

**No veo la pestaña "Actions" en GitHub**
- Asegúrate de que el repo sea público, o habilita Actions en Settings

**El workflow falla**
- Revisa los logs en la pestaña Actions
- Probablemente sea un error en el código Dart/Flutter

**Netlify no carga la app**
- Asegúrate de arrastrar la carpeta correcta (la que contiene index.html)
- Revisa la consola del navegador (F12) para ver errores
