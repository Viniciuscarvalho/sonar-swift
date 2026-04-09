#!/bin/bash
# Sonar-Swift Installer
# Uso: curl -sL https://raw.githubusercontent.com/Viniciuscarvalho/sonar-swift/main/bin/install.sh | bash

set -e

REPO="https://github.com/Viniciuscarvalho/sonar-swift.git"
TMP="/tmp/sonar-swift-$$"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🔍 Instalando Sonar-Swift..."

git clone --depth 1 "$REPO" "$TMP" 2>/dev/null

# .swiftlint.yml
if [[ -f .swiftlint.yml ]]; then
  echo -e "${YELLOW}⚠  .swiftlint.yml já existe — pulando (use --force para sobrescrever)${NC}"
  [[ "$1" == "--force" ]] && cp "$TMP/.swiftlint.yml" .
else
  cp "$TMP/.swiftlint.yml" .
fi

# GitHub Actions
mkdir -p .github/workflows
cp "$TMP/.github/workflows/swiftlint.yml" .github/workflows/
cp "$TMP/.github/workflows/swift-review.yml" .github/workflows/
echo -e "${GREEN}✓${NC} GitHub Actions workflows copiados"

rm -rf "$TMP"

echo ""
echo -e "${GREEN}✅ Sonar-Swift instalado!${NC}"
echo "   - SwiftLint roda no CI em todo PR automaticamente"
echo "   - Rode 'swiftlint lint' local se quiser (opcional)"
