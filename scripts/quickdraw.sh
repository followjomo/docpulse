#!/usr/bin/env bash
set -euo pipefail
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

echo -e "${YELLOW}=== Quickdraw: Open and close an issue in < 5 min ===${NC}"

if ! gh auth status &>/dev/null; then
  echo -e "${RED}✗ Not authenticated. Run: gh auth login${NC}"; exit 1
fi

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "")
if [[ -z "$REPO" ]]; then
  echo -e "${RED}✗ Could not detect repo. Run from inside a git repo with a GitHub remote.${NC}"; exit 1
fi

TS=$(date +%s)
TITLE="chore: quickdraw achievement run [$TS]"

echo -e "${YELLOW}Creating issue...${NC}"
ISSUE_URL=$(gh issue create --repo "$REPO" --title "$TITLE" --body "Automated issue for Quickdraw achievement. Will be closed immediately." --label "" 2>/dev/null || \
            gh issue create --repo "$REPO" --title "$TITLE" --body "Automated issue for Quickdraw achievement. Will be closed immediately.")
ISSUE_NUM=$(echo "$ISSUE_URL" | grep -oE '[0-9]+$')

echo -e "${GREEN}✓ Issue #$ISSUE_NUM created${NC}"
sleep 2

echo -e "${YELLOW}Closing issue...${NC}"
gh issue close "$ISSUE_NUM" --repo "$REPO" --comment "Closed for Quickdraw achievement."
echo -e "${GREEN}✓ Issue #$ISSUE_NUM closed in under 5 minutes!${NC}"
echo -e "\n${GREEN}🏅 Quickdraw achievement triggered!${NC}"
echo -e "Check your profile: https://github.com/$(gh api user -q .login)"
