#!/usr/bin/env node
'use strict';
/**
 * docpulse — Documentation freshness checker
 */

const { program } = require('commander');
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');
const PKG = require('../package.json');

const R='\x1b[0m', G='\x1b[32m', Y='\x1b[33m', RED='\x1b[31m', B='\x1b[34m', BOLD='\x1b[1m', DIM='\x1b[2m';

// ─── Git helpers ──────────────────────────────────────────────────────────────

function gitLastModified(file) {
  try {
    const ts = execSync(`git log -1 --format="%at" -- "${file}"`, { encoding: 'utf8', stdio: ['pipe','pipe','pipe'] }).trim();
    return ts ? new Date(parseInt(ts) * 1000) : null;
  } catch { return null; }
}

function fsLastModified(file) {
  try { return fs.statSync(file).mtime; } catch { return null; }
}

function getLastModified(file) {
  return gitLastModified(file) || fsLastModified(file);
}

// ─── Config ───────────────────────────────────────────────────────────────────

function loadConfig() {
  const cfgPath = path.join(process.cwd(), '.docpulse.json');
  if (fs.existsSync(cfgPath)) return JSON.parse(fs.readFileSync(cfgPath, 'utf8'));
  return { threshold: 30, docsDir: 'docs', srcDir: 'src', pairs: [], ignore: [], exitOnStale: false };
}

// ─── Analysis ────────────────────────────────────────────────────────────────

function daysBetween(d1, d2) {
  return Math.floor(Math.abs(d2 - d1) / (1000 * 60 * 60 * 24));
}

function staleness(docDate, srcDate, threshold) {
  if (!docDate || !srcDate) return { stale: false, days: 0, score: 0 };
  const days = daysBetween(docDate, srcDate);
  const stale = srcDate > docDate && days > threshold;
  const score = stale ? Math.min(100, Math.round((days / threshold) * 50)) : 0;
  return { stale, days, score };
}

function colorForScore(score) {
  if (score >= 75) return RED;
  if (score >= 40) return Y;
  return G;
}

function statusIcon(s) {
  if (!s.stale) return `${G}✓ Fresh${R}`;
  if (s.score >= 75) return `${RED}✗ Very stale${R}`;
  if (s.score >= 40) return `${Y}⚠ Stale${R}`;
  return `${Y}~ Aging${R}`;
}

// ─── Commands ────────────────────────────────────────────────────────────────

program.name('docpulse').description('Documentation freshness checker').version(PKG.version);

program
  .command('init')
  .description('Create a starter .docpulse.json config')
  .action(() => {
    const cfg = {
      threshold: 30,
      docsDir: 'docs',
      srcDir: 'src',
      pairs: [
        { doc: 'docs/api.md', src: 'src/api.js', description: 'API reference' },
        { doc: 'README.md',   src: 'src/index.js', description: 'Main README' },
      ],
      ignore: ['docs/CHANGELOG.md', 'CHANGELOG.md'],
      exitOnStale: false,
    };
    fs.writeFileSync('.docpulse.json', JSON.stringify(cfg, null, 2));
    console.log(`${G}✓ Created .docpulse.json${R}`);
    console.log(`Edit pairs to map your docs to their source files, then run:`);
    console.log(`  ${Y}node src/docpulse.js check${R}`);
  });

program
  .command('check')
  .description('Check all docs for staleness')
  .option('-t, --threshold <days>', 'Days before a doc is considered stale')
  .option('-d, --docs <dir>', 'Documentation directory')
  .option('-s, --src <dir>', 'Source code directory')
  .option('-r, --report <file>', 'Write report to a Markdown file')
  .option('--json', 'Output as JSON')
  .option('--fail-on-stale', 'Exit with code 1 if any stale docs found')
  .action(async (opts) => {
    const cfg = loadConfig();
    const threshold = parseInt(opts.threshold || cfg.threshold || 30);
    const docsDir   = opts.docs || cfg.docsDir || 'docs';
    const srcDir    = opts.src  || cfg.srcDir  || 'src';
    const ignore    = new Set(cfg.ignore || []);

    // Build pairs: use config pairs + auto-discover
    let pairs = [...(cfg.pairs || [])];

    // Auto-discover: find docs and try to match source files
    if (fs.existsSync(docsDir)) {
      const { glob } = require('glob');
      const docFiles = await glob(path.join(docsDir, '**/*.md'), { nodir: true });
      for (const doc of docFiles) {
        const rel = path.relative(process.cwd(), doc);
        if (ignore.has(rel) || pairs.find(p => p.doc === rel)) continue;
        // Try to find matching src file
        const base = path.basename(doc, '.md');
        const candidates = [
          path.join(srcDir, `${base}.js`),
          path.join(srcDir, `${base}.ts`),
          path.join(srcDir, `${base}/index.js`),
        ];
        const srcFile = candidates.find(c => fs.existsSync(c));
        pairs.push({ doc: rel, src: srcFile || null, auto: true });
      }
    }

    if (!pairs.length) {
      console.log(`${Y}No doc pairs found. Run: node src/docpulse.js init${R}`);
      return;
    }

    const results = pairs.map(pair => {
      const docDate = getLastModified(pair.doc);
      const srcDate = pair.src ? getLastModified(pair.src) : null;
      const st = staleness(docDate, srcDate, threshold);
      return {
        doc: pair.doc,
        src: pair.src || null,
        description: pair.description || '',
        docDate: docDate?.toISOString().split('T')[0] || 'unknown',
        srcDate: srcDate?.toISOString().split('T')[0] || 'unknown',
        ...st,
        exists: fs.existsSync(pair.doc),
      };
    });

    if (opts.json) {
      console.log(JSON.stringify(results, null, 2));
      return;
    }

    const staleCount   = results.filter(r => r.stale).length;
    const missingCount = results.filter(r => !r.exists).length;

    console.log(`\n${BOLD}DocPulse — Freshness Check${R}`);
    console.log(`${DIM}Threshold: ${threshold} days  |  ${results.length} docs checked${R}`);
    console.log('─'.repeat(70));

    for (const r of results) {
      const icon = r.exists ? statusIcon(r) : `${RED}✗ Missing${R}`;
      const srcInfo = r.src ? `${DIM}← ${r.src}${R}` : `${DIM}(no source linked)${R}`;
      const age = r.stale ? `  ${colorForScore(r.score)}${r.days}d old${R}` : '';
      console.log(`  ${r.doc.padEnd(30)} ${icon}${age}`);
      console.log(`  ${''.padEnd(30)} ${srcInfo}`);
    }

    console.log('─'.repeat(70));
    const freshCount = results.filter(r => !r.stale && r.exists).length;
    console.log(`  ${G}✓ Fresh: ${freshCount}${R}   ${staleCount ? RED : G}✗ Stale: ${staleCount}${R}   ${missingCount ? Y : G}Missing: ${missingCount}${R}\n`);

    if (opts.report) {
      const lines = [`# DocPulse Report\n`, `Generated: ${new Date().toISOString().split('T')[0]}\n`,
        `| Doc | Source | Status | Age (days) | Doc Date | Src Date |`,
        `|-----|--------|--------|-----------|----------|----------|`,
        ...results.map(r => `| ${r.doc} | ${r.src||'—'} | ${r.stale?'🔴 Stale':'🟢 Fresh'} | ${r.days} | ${r.docDate} | ${r.srcDate} |`)
      ];
      fs.writeFileSync(opts.report, lines.join('\n') + '\n');
      console.log(`${G}✓ Report written: ${opts.report}${R}`);
    }

    if ((opts.failOnStale || cfg.exitOnStale) && staleCount > 0) {
      console.log(`${RED}Exiting with code 1: ${staleCount} stale doc(s) found.${R}`);
      process.exit(1);
    }
  });

program
  .command('stats')
  .description('Show documentation age statistics')
  .action(async () => {
    const cfg = loadConfig();
    const { glob } = require('glob');
    const docsDir = cfg.docsDir || 'docs';

    const docFiles = fs.existsSync(docsDir)
      ? await glob(path.join(docsDir, '**/*.md'), { nodir: true })
      : ['README.md'].filter(f => fs.existsSync(f));

    if (!docFiles.length) { console.log(`${Y}No docs found.${R}`); return; }

    const now = new Date();
    const aged = docFiles.map(f => {
      const d = getLastModified(f);
      return { file: f, days: d ? daysBetween(now, d) : 9999, date: d?.toISOString().split('T')[0] || 'unknown' };
    }).sort((a,b) => b.days - a.days);

    console.log(`\n${BOLD}Documentation Age Stats${R}`);
    console.log('─'.repeat(55));
    aged.forEach(a => {
      const color = a.days > 180 ? RED : a.days > 60 ? Y : G;
      console.log(`  ${color}${String(a.days).padStart(4)}d${R}  ${a.date}  ${a.file}`);
    });
    const avg = Math.round(aged.reduce((s,a)=>s+a.days,0)/aged.length);
    console.log('─'.repeat(55));
    console.log(`  Average age: ${avg} days  |  ${docFiles.length} docs\n`);
  });

program.parse(process.argv);
if (!process.argv.slice(2).length) program.outputHelp();
