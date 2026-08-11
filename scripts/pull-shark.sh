#!/usr/bin/env bash
set -euo pipefail
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'

COUNT=${1:-2}

echo -e "${BLUE}${BOLD}=== Pull Shark: Merging $COUNT PRs ===${NC}"
echo -e "${YELLOW}Tier reference: 2=Bronze 🥉  16=Silver 🥈  128=Gold 🥇${NC}\n"

if ! gh auth status &>/dev/null; then
  echo -e "${RED}✗ Not authenticated. Run: gh auth login${NC}"; exit 1
fi

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "")
if [[ -z "$REPO" ]]; then
  echo -e "${RED}✗ Could not detect repo.${NC}"; exit 1
fi

DEFAULT_BRANCH=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)

for i in $(seq 1 "$COUNT"); do
  TS=$(date +%s)
  BRANCH="pull-shark/pr-$i-$TS"
  echo -e "${YELLOW}[$i/$COUNT] Creating PR on branch $BRANCH...${NC}"

  git checkout "$DEFAULT_BRANCH" 2>/dev/null; git pull origin "$DEFAULT_BRANCH" 2>/dev/null || true
  git checkout -b "$BRANCH"
  echo "# Pull Shark run $i at $(date)" >> .pull-shark-log.md
  git add .pull-shark-log.md
  git commit -m "chore: pull-shark run $i of $COUNT [$TS]" --allow-empty
  git push origin "$BRANCH"

  PR_URL=$(gh pr create --repo "$REPO" --base "$DEFAULT_BRANCH" --head "$BRANCH" \
    --title "chore: pull-shark #$i [$TS]" \
    --body "Automated PR $i of $COUNT for Pull Shark achievement.")
  PR_NUM=$(echo "$PR_URL" | grep -oE '[0-9]+$')

  gh pr merge "$PR_NUM" --repo "$REPO" --squash --delete-branch --admin 2>/dev/null || \
  gh pr merge "$PR_NUM" --repo "$REPO" --squash --delete-branch

  echo -e "${GREEN}✓ PR #$PR_NUM merged ($i/$COUNT)${NC}"
  git checkout "$DEFAULT_BRANCH"; git pull origin "$DEFAULT_BRANCH" 2>/dev/null || true
  sleep 2
done

echo -e "\n${GREEN}${BOLD}🦈 All $COUNT PRs merged!${NC}"
if   [[ "$COUNT" -ge 128 ]]; then echo -e "${YELLOW}🥇 Gold Pull Shark unlocked!${NC}"
elif [[ "$COUNT" -ge 16  ]]; then echo -e "${YELLOW}🥈 Silver Pull Shark unlocked!${NC}"
elif [[ "$COUNT" -ge 2   ]]; then echo -e "${YELLOW}🥉 Bronze Pull Shark unlocked!${NC}"
fi
echo -e "Check your profile: https://github.com/$(gh api user -q .login)"
