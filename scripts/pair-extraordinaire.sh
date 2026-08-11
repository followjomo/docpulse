#!/usr/bin/env bash
set -euo pipefail
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

CO_NAME=${1:-"Pair Partner"}
CO_EMAIL=${2:-"partner@example.com"}

echo -e "${YELLOW}=== Pair Extraordinaire: Co-authored merged PR ===${NC}"
echo -e "Co-author: $CO_NAME <$CO_EMAIL>"

if ! gh auth status &>/dev/null; then
  echo -e "${RED}✗ Not authenticated. Run: gh auth login${NC}"; exit 1
fi

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "")
if [[ -z "$REPO" ]]; then
  echo -e "${RED}✗ Could not detect repo.${NC}"; exit 1
fi

TS=$(date +%s)
DEFAULT_BRANCH=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)
BRANCH="pair-extraordinaire/run-$TS"

git checkout "$DEFAULT_BRANCH" 2>/dev/null; git pull origin "$DEFAULT_BRANCH" 2>/dev/null || true
git checkout -b "$BRANCH"
echo "# Pair Extraordinaire at $(date)" >> .pair-log.md
git add .pair-log.md
git commit -m "chore: pair extraordinaire run [$TS]

Co-authored-by: $CO_NAME <$CO_EMAIL>"
git push origin "$BRANCH"

PR_URL=$(gh pr create --repo "$REPO" --base "$DEFAULT_BRANCH" --head "$BRANCH" \
  --title "chore: pair extraordinaire [$TS]" \
  --body "Co-authored-by: $CO_NAME <$CO_EMAIL>

Automated PR for Pair Extraordinaire achievement.")
PR_NUM=$(echo "$PR_URL" | grep -oE '[0-9]+$')

gh pr merge "$PR_NUM" --repo "$REPO" --squash --delete-branch --admin 2>/dev/null || \
gh pr merge "$PR_NUM" --repo "$REPO" --squash --delete-branch

git checkout "$DEFAULT_BRANCH"; git pull origin "$DEFAULT_BRANCH" 2>/dev/null || true

echo -e "${GREEN}✓ Co-authored PR #$PR_NUM merged!${NC}"
echo -e "${GREEN}🏅 Pair Extraordinaire achievement triggered!${NC}"
echo -e "Check your profile: https://github.com/$(gh api user -q .login)"
