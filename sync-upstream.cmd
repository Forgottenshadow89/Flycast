@echo off
rem Sincroniza el fork con upstream manteniendo el commit del revert encima.
cd /d "%~dp0"
set BRANCH=upscaling-restored

git remote get-url upstream >nul 2>&1 || git remote add upstream https://github.com/flyinghead/flycast.git
git fetch upstream master || exit /b 1

for /f "delims=" %%i in ('git status --porcelain') do (
  echo Hay cambios sin commitear. Guardalos ^(commit/stash^) antes de sincronizar.
  exit /b 1
)

git checkout -q %BRANCH% || exit /b 1
echo Rebase de %BRANCH% sobre upstream/master...
git rebase upstream/master
if errorlevel 1 (
  echo.
  echo CONFLICTO en el rebase. Resuelvelo, luego: git add ^<fichero^> ^&^& git rebase --continue
  echo Despues vuelve a ejecutar este script para publicar.
  exit /b 1
)

git push --force-with-lease origin %BRANCH% || exit /b 1
git push origin upstream/master:master
echo.
echo Listo. %BRANCH% = upstream/master + revert. Los binarios se compilan en GitHub Actions.
pause
