#!/usr/bin/env bash
set -euo pipefail
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

echo -e "${YELLOW}=== Publicist: Create v1.0.0 GitHub Release ===${NC}"

if ! gh auth status &>/dev/null; then
  echo -e "${RED}✗ Not authenticated. Run: gh auth login${NC}"; exit 1
fi

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "")
if [[ -z "$REPO" ]]; then
  echo -e "${RED}✗ Could not detect repo.${NC}"; exit 1
fi

TAG="v1.0.0"
if gh release view "$TAG" --repo "$REPO" &>/dev/null; then
  TS=$(date +%s)
  TAG="v1.0.0-$TS"
  echo -e "${YELLOW}v1.0.0 already exists, using $TAG${NC}"
fi

echo -e "${YELLOW}Creating release $TAG...${NC}"
gh release create "$TAG" --repo "$REPO" \
  --title "🚀 Release $TAG" \
  --notes "## What's New
- Initial public release
- Core features implemented
- Full documentation included

## Installation
\`\`\`bash
npm install
\`\`\`

See README.md for full usage instructions." \
  --latest

echo -e "${GREEN}✓ Release $TAG created!${NC}"
echo -e "${GREEN}🏅 Publicist achievement triggered!${NC}"
echo -e "Release URL: https://github.com/$REPO/releases/tag/$TAG"
echo -e "Profile: https://github.com/$(gh api user -q .login)"
