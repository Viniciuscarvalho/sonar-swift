#!/bin/bash
# Sonar-Swift Installer
# Usage: curl -sL https://raw.githubusercontent.com/Viniciuscarvalho/sonar-swift/main/bin/install.sh | bash

set -e

REPO="https://github.com/Viniciuscarvalho/sonar-swift.git"
TMP="/tmp/sonar-swift-$$"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "Installing Sonar-Swift..."

git clone --depth 1 "$REPO" "$TMP" 2>/dev/null

# .swiftlint.yml
if [[ -f .swiftlint.yml ]]; then
  echo -e "${YELLOW}Warning: .swiftlint.yml already exists — skipping (use --force to overwrite)${NC}"
  [[ "$1" == "--force" ]] && cp "$TMP/.swiftlint.yml" .
else
  cp "$TMP/.swiftlint.yml" .
fi

# GitHub Actions
mkdir -p .github/workflows
cp "$TMP/.github/workflows/swiftlint.yml" .github/workflows/
cp "$TMP/.github/workflows/swift-review.yml" .github/workflows/
echo -e "${GREEN}Done${NC} GitHub Actions workflows copied"

rm -rf "$TMP"

echo ""
echo -e "${GREEN}Sonar-Swift installed!${NC}"
echo "   - SwiftLint runs on CI for every PR automatically"
echo "   - AI Code Review requires ANTHROPIC_API_KEY secret (see README)"
echo "   - Run 'swiftlint lint' locally if you want (optional)"
