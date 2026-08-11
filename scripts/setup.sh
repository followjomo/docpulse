#!/usr/bin/env bash
set -euo pipefail
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

echo -e "${GREEN}=== Setup: Checking dependencies ===${NC}"

check_cmd() {
  if ! command -v "$1" &>/dev/null; then
    echo -e "${RED}✗ $1 not found. $2${NC}"; exit 1
  else
    echo -e "${GREEN}✓ $1 found ($(${1} --version 2>&1 | head -1))${NC}"
  fi
}

check_cmd node  "Install from https://nodejs.org"
check_cmd npm   "Install from https://nodejs.org"
check_cmd git   "Install from https://git-scm.com"
check_cmd gh    "Install from https://cli.github.com"

echo -e "\n${YELLOW}Checking GitHub authentication...${NC}"
if ! gh auth status &>/dev/null; then
  echo -e "${RED}✗ Not authenticated with GitHub CLI.${NC}"
  echo -e "  Run: ${YELLOW}gh auth login${NC}"
  exit 1
fi
echo -e "${GREEN}✓ GitHub CLI authenticated${NC}"

echo -e "\n${YELLOW}Making scripts executable...${NC}"
chmod +x scripts/*.sh
echo -e "${GREEN}✓ All scripts are executable${NC}"

echo -e "\n${YELLOW}Installing npm dependencies...${NC}"
npm install
echo -e "${GREEN}✓ Dependencies installed${NC}"

echo -e "\n${GREEN}=== Setup complete! ===${NC}"
