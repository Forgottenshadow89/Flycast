# Fork notes (LuismaSP89/flycast)

Rama de trabajo: **`upscaling-restored`** (rama por defecto del fork).

## Qué cambia respecto a upstream

Un único commit propio encima de `upstream/master`:

- `Revert "rend: disable texture upscaling on mobile. hide option on desktop"`
  (revierte parcialmente `d450c84a14645cd483a68d558260362743cc8187`).
  - Restaura la sección **Texture Upscaling** (xBRZ: factor, tamaño máximo de
    textura, hilos) en Ajustes > Vídeo. Solo aparece si el binario se compiló
    con OpenMP (`_OPENMP`), que en escritorio es el valor por defecto.
  - Restaura la clave de configuración original `rend.TextureUpscale`
    (upstream la renombró a `rend.TextureUpscale2` para forzar el valor 1).
  - NO se revierten los cambios de CI/móvil de ese commit (scripts OpenMP
    para iOS, `-DUSE_OPENMP=OFF` en Android/iOS). Así se evitan conflictos
    recurrentes al sincronizar; en escritorio no afectan.

## Cómo actualizar con upstream

Ejecuta `sync-upstream.cmd` (Windows) o `sync-upstream.sh` (Git Bash / Linux).
El script hace:

1. `git fetch upstream`
2. `git rebase upstream/master` sobre `upscaling-restored` (el commit del
   revert se recoloca encima de la última versión de upstream).
3. `git push --force-with-lease origin upscaling-restored`
4. Actualiza también `origin/master` como espejo de `upstream/master`.

Si el rebase da conflicto (upstream tocó `core/cfg/option.cpp` o
`core/ui/settings_video.cpp` en las mismas líneas), resuélvelo, `git add` y
`git rebase --continue`; después vuelve a ejecutar el script para hacer el push.

## Binarios

GitHub Actions está activado en el fork: cada push a `upscaling-restored`
compila Windows/Linux/macOS y deja los binarios como *artifacts* del workflow
"Linux, macOS, Windows" (pestaña Actions del repo). Los pasos de subida a S3
solo se ejecutan en el repo upstream.
