#!/bin/bash
# Instalar Git Hooks KODA
# Ejecutar desde raíz del repo: ./scripts/install-hooks.sh

set -e

echo "🪝 Instalando git hooks KODA..."

# Verificar que estamos en un repo git
if [ ! -d ".git" ]; then
  echo "❌ Error: No se detectó repositorio git"
  echo "   Ejecuta este script desde la raíz del repo"
  exit 1
fi

# Copiar hooks
if [ -f "hooks/pre-commit" ]; then
  cp hooks/pre-commit .git/hooks/pre-commit
  chmod +x .git/hooks/pre-commit
  echo "✅ Pre-commit hook instalado"
else
  echo "⚠️  hooks/pre-commit no encontrado"
fi

if [ -f "hooks/post-commit" ]; then
  cp hooks/post-commit .git/hooks/post-commit
  chmod +x .git/hooks/post-commit
  echo "✅ Post-commit hook instalado"
fi

echo ""
echo "🎉 Git hooks instalados correctamente"
echo ""
echo "Los hooks ahora se ejecutarán automáticamente:"
echo "  - pre-commit: Valida agentes modificados"
echo "  - post-commit: Registra nuevos agentes"
echo ""
echo "Para desinstalar:"
echo "  rm .git/hooks/pre-commit .git/hooks/post-commit"
