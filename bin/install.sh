#!/bin/bash
# Sonar-Swift Installer
# Usage:
#   Install:  curl -sL https://raw.githubusercontent.com/Viniciuscarvalho/sonar-swift/main/bin/install.sh | bash
#   Update:   curl -sL https://raw.githubusercontent.com/Viniciuscarvalho/sonar-swift/main/bin/install.sh | bash -s -- update
#   Force:    curl -sL https://raw.githubusercontent.com/Viniciuscarvalho/sonar-swift/main/bin/install.sh | bash -s -- --force

set -e

REPO="https://github.com/Viniciuscarvalho/sonar-swift.git"
TMP="/tmp/sonar-swift-$$"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

MODE="install"
[[ "$1" == "update" ]] && MODE="update"
[[ "$1" == "--force" ]] && MODE="force"

echo -e "${CYAN}Sonar-Swift ($MODE)${NC}"
echo ""

git clone --depth 1 "$REPO" "$TMP" 2>/dev/null

# .swiftlint.yml
if [[ "$MODE" == "update" ]]; then
  echo -e "${YELLOW}Skipping .swiftlint.yml (update mode preserves your custom rules)${NC}"
elif [[ -f .swiftlint.yml ]]; then
  if [[ "$MODE" == "force" ]]; then
    cp "$TMP/.swiftlint.yml" .
    echo -e "${GREEN}Replaced${NC} .swiftlint.yml (--force)"
  else
    echo -e "${YELLOW}Skipping${NC} .swiftlint.yml (already exists — use --force to overwrite)"
    echo "         Your custom rules are preserved. Edit this file to customize lint rules."
  fi
else
  cp "$TMP/.swiftlint.yml" .
  echo -e "${GREEN}Created${NC} .swiftlint.yml"
fi

# GitHub Actions
mkdir -p .github/workflows
cp "$TMP/.github/workflows/swiftlint.yml" .github/workflows/
cp "$TMP/.github/workflows/swift-review.yml" .github/workflows/
echo -e "${GREEN}Updated${NC} .github/workflows/swiftlint.yml  (Layer 1: SwiftLint)"
echo -e "${GREEN}Updated${NC} .github/workflows/swift-review.yml (Layer 2: AI Review)"

rm -rf "$TMP"

echo ""
echo -e "${GREEN}Done!${NC}"
echo ""
echo "  Two-layer architecture:"
echo ""
echo "    Layer 1 — SwiftLint (always runs, \$0)"
echo "      Posts PR comment with lint report + fix options"
echo "      No API key needed"
echo ""
echo "    Layer 2 — AI Review (on-demand, ~\$0.01-0.04/review)"
echo "      Add the 'ai-review' label to a PR to trigger"
echo "      Requires ANTHROPIC_API_KEY secret"
echo "      Uses Sonnet with max_tokens: 2048"
echo "      Token usage shown in review footer"
echo ""
echo "  Installed files:"
echo "    .swiftlint.yml                      Lint rules (edit to customize)"
echo "    .github/workflows/swiftlint.yml     Layer 1: SwiftLint CI"
echo "    .github/workflows/swift-review.yml  Layer 2: AI Code Review"
echo ""
echo "  Next steps:"
echo "    1. Customize lint rules:  edit .swiftlint.yml"
echo "    2. Enable AI review:     gh secret set ANTHROPIC_API_KEY -R owner/repo"
echo "    3. Create 'ai-review' label: gh label create ai-review -c 8B5CF6 -d 'Trigger AI code review'"
echo "    4. Run locally:          brew install swiftlint && swiftlint lint"
echo ""
echo "  Update workflows later (keeps your .swiftlint.yml intact):"
echo "    curl -sL https://raw.githubusercontent.com/Viniciuscarvalho/sonar-swift/main/bin/install.sh | bash -s -- update"
