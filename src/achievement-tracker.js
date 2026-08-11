#!/usr/bin/env node
'use strict';

const achievements = [
  { id: 'quickdraw',           name: 'Quickdraw',            emoji: '🤠', desc: 'Open & close an issue in < 5 min',      script: 'scripts/quickdraw.sh' },
  { id: 'yolo',                name: 'YOLO',                 emoji: '🎲', desc: 'Merge a PR without a review',            script: 'scripts/yolo.sh' },
  { id: 'publicist',           name: 'Publicist',            emoji: '📢', desc: 'Create a v1.0.0 GitHub Release',         script: 'scripts/publicist.sh' },
  { id: 'pull-shark-bronze',   name: 'Pull Shark (Bronze)',  emoji: '🦈', desc: '2 merged PRs',                           script: 'scripts/pull-shark.sh 2' },
  { id: 'pull-shark-silver',   name: 'Pull Shark (Silver)',  emoji: '🦈', desc: '16 merged PRs',                          script: 'scripts/pull-shark.sh 16' },
  { id: 'pull-shark-gold',     name: 'Pull Shark (Gold)',    emoji: '🦈', desc: '128 merged PRs',                         script: 'scripts/pull-shark.sh 128' },
  { id: 'pair-extraordinaire', name: 'Pair Extraordinaire',  emoji: '👥', desc: 'Co-authored merged PR',                  script: 'scripts/pair-extraordinaire.sh "Name" "email@example.com"' },
  { id: 'galaxy-brain',        name: 'Galaxy Brain',         emoji: '🧠', desc: 'Answer marked as helpful (manual)',      script: null },
  { id: 'starstruck',          name: 'Starstruck',           emoji: '⭐', desc: '16 stars on a repo (manual)',            script: null },
  { id: 'heart-on-sleeve',     name: 'Heart on Your Sleeve', emoji: '❤️', desc: 'React with heart emoji to items',       script: null },
];

const roadmap = [
  { period: 'Day 1',   tasks: ['Create GitHub repo', 'Push first commit', 'Run: bash scripts/setup.sh'] },
  { period: 'Day 2',   tasks: ['Run: bash scripts/quickdraw.sh', 'Run: bash scripts/yolo.sh', 'Check CI passes on GitHub'] },
  { period: 'Day 3',   tasks: ['Run: bash scripts/publicist.sh', 'Run: bash scripts/pull-shark.sh 2'] },
  { period: 'Week 1',  tasks: ['Run: bash scripts/pull-shark.sh 16', 'Run: bash scripts/pair-extraordinaire.sh "Name" "email"'] },
  { period: 'Week 2',  tasks: ['Answer a discussion question for Galaxy Brain', 'Promote repo to get 16 stars for Starstruck'] },
  { period: 'Month 1', tasks: ['Run: bash scripts/pull-shark.sh 128 (Gold tier)', 'Verify all badges on your GitHub profile'] },
];

const R='\x1b[0m', G='\x1b[32m', Y='\x1b[33m', B='\x1b[34m', BOLD='\x1b[1m', DIM='\x1b[2m';

console.log(`\n${BOLD}${B}========================================${R}`);
console.log(`${BOLD}${B}  Achievement Tracker — docpulse  ${R}`);
console.log(`${BOLD}${B}========================================${R}\n`);

console.log(`${BOLD}ACHIEVEMENTS${R}`);
console.log('─'.repeat(58));
achievements.forEach((a, i) => {
  const n = String(i+1).padStart(2);
  console.log(`  ${n}. ${a.emoji}  ${BOLD}${a.name}${R}`);
  console.log(`      ${DIM}${a.desc}${R}`);
  if (a.script) {
    console.log(`      → bash ${a.script}`);
  } else {
    console.log(`      ${Y}★ Manual — verify on your GitHub profile${R}`);
  }
});

console.log(`\n${BOLD}DAY 1 TO MONTH 1 ROADMAP${R}`);
console.log('─'.repeat(58));
roadmap.forEach(r => {
  console.log(`\n  ${BOLD}${G}${r.period}${R}`);
  r.tasks.forEach(t => console.log(`    [ ] ${t}`));
});

console.log(`\n${BOLD}QUICK LINKS${R}`);
console.log('─'.repeat(58));
console.log(`  Profile : https://github.com/YOUR_USERNAME`);
console.log(`  Run all : bash scripts/unlock-all.sh`);
console.log('');
