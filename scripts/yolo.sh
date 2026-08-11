#!/usr/bin/env bash
set -euo pipefail
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

echo -e "${YELLOW}=== YOLO: Create branch, PR, and merge without review ===${NC}"

if ! gh auth status &>/dev/null; then
  echo -e "${RED}✗ Not authenticated. Run: gh auth login${NC}"; exit 1
fi

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "")
if [[ -z "$REPO" ]]; then
  echo -e "${RED}✗ Could not detect repo.${NC}"; exit 1
fi

TS=$(date +%s)
BRANCH="yolo/achievement-$TS"
DEFAULT_BRANCH=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)

echo -e "${YELLOW}Creating branch $BRANCH...${NC}"
git checkout -b "$BRANCH"
echo "# YOLO run at $(date)" >> .yolo-log.md
git add .yolo-log.md
git commit -m "chore: yolo achievement run [$TS]" --allow-empty
git push origin "$BRANCH"

echo -e "${YELLOW}Opening PR...${NC}"
PR_URL=$(gh pr create --repo "$REPO" --base "$DEFAULT_BRANCH" --head "$BRANCH" \
  --title "chore: yolo achievement [$TS]" \
  --body "Automated PR for YOLO achievement. Merging without review.")
PR_NUM=$(echo "$PR_URL" | grep -oE '[0-9]+$')
echo -e "${GREEN}✓ PR #$PR_NUM created${NC}"

echo -e "${YELLOW}Merging PR without review...${NC}"
gh pr merge "$PR_NUM" --repo "$REPO" --squash --delete-branch --admin || \
gh pr merge "$PR_NUM" --repo "$REPO" --squash --delete-branch

git checkout "$DEFAULT_BRANCH"
git pull origin "$DEFAULT_BRANCH"

echo -e "${GREEN}✓ PR merged! YOLO achievement triggered!${NC}"
echo -e "Check your profile: https://github.com/$(gh api user -q .login)"
