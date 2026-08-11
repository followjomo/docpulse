#!/usr/bin/env bash
set -euo pipefail
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'
BOLD='\033[1m'; NC='\033[0m'

echo -e "${BLUE}${BOLD}"
echo "╔══════════════════════════════════════════╗"
echo "║      Achievement Unlock Menu             ║"
echo "╠══════════════════════════════════════════╣"
echo "║  1) Quickdraw   (open+close issue fast)  ║"
echo "║  2) YOLO        (merge PR without review)║"
echo "║  3) Publicist   (create v1.0.0 release)  ║"
echo "║  4) Pull Shark  (Bronze – 2 PRs)         ║"
echo "║  5) Pull Shark  (Silver – 16 PRs)        ║"
echo "║  6) Pair Extraordinaire (co-authored PR) ║"
echo "║  7) Track Progress                       ║"
echo "║  8) ⚡ FULL BLAST (all achievements)     ║"
echo "║  9) Exit                                 ║"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"

read -rp "Select option [1-9]: " CHOICE

case $CHOICE in
  1) bash scripts/quickdraw.sh ;;
  2) bash scripts/yolo.sh ;;
  3) bash scripts/publicist.sh ;;
  4) bash scripts/pull-shark.sh 2 ;;
  5) bash scripts/pull-shark.sh 16 ;;
  6)
    read -rp "Co-author name: " CONAME
    read -rp "Co-author email: " COEMAIL
    bash scripts/pair-extraordinaire.sh "$CONAME" "$COEMAIL"
    ;;
  7) node src/achievement-tracker.js ;;
  8)
    echo -e "${YELLOW}${BOLD}⚡ FULL BLAST: Running all achievements...${NC}"
    bash scripts/quickdraw.sh
    bash scripts/yolo.sh
    bash scripts/publicist.sh
    bash scripts/pull-shark.sh 2
    bash scripts/pair-extraordinaire.sh "Pair Bot" "bot@example.com"
    node src/achievement-tracker.js
    echo -e "${GREEN}${BOLD}✅ Full Blast complete!${NC}"
    ;;
  9) echo "Goodbye!"; exit 0 ;;
  *) echo -e "${RED}Invalid option${NC}"; exit 1 ;;
esac
