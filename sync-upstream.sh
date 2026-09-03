#!/usr/bin/env bash
# Sincroniza el fork con upstream manteniendo el commit del revert encima.
set -euo pipefail
cd "$(dirname "$0")"
BRANCH=upscaling-restored

git remote get-url upstream >/dev/null 2>&1 || git remote add upstream https://github.com/flyinghead/flycast.git
git fetch upstream master

if [ -n "$(git status --porcelain)" ]; then
  echo "Hay cambios sin commitear. Guárdalos (commit/stash) antes de sincronizar." >&2
  exit 1
fi

git checkout -q "$BRANCH"
echo "Rebase de $BRANCH sobre upstream/master ($(git rev-parse --short upstream/master))..."
if ! git rebase upstream/master; then
  echo
  echo "CONFLICTO en el rebase. Resuélvelo, luego: git add <fichero> && git rebase --continue" >&2
  echo "Después vuelve a ejecutar este script para publicar." >&2
  exit 1
fi

git push --force-with-lease origin "$BRANCH"
# master del fork = espejo de upstream
git push origin upstream/master:master
echo
echo "Listo. $BRANCH = upstream/master + revert. Los binarios se compilan en GitHub Actions."
