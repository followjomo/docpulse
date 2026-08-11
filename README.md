# docpulse

[![CI](https://github.com/YOUR_USERNAME/docpulse/actions/workflows/ci.yml/badge.svg)](https://github.com/YOUR_USERNAME/docpulse/actions/workflows/ci.yml)
[![npm version](https://img.shields.io/npm/v/docpulse.svg)](https://npmjs.com/package/docpulse)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Node.js](https://img.shields.io/badge/node-%3E%3D18-brightgreen)](https://nodejs.org)

> Keep your documentation fresh. DocPulse detects when code changes have made your docs stale and flags them for review.

## Features

- 🕵️ **Staleness detection** — Flags docs older than recently changed code
- 🔗 **Smart linking** — Maps source files to their documentation
- 📅 **Age scoring** — Rates docs by how outdated they are
- 🧪 **Config-driven** — Define doc/source pairs in `.docpulse.json`
- 📊 **Reports** — Markdown, JSON, or terminal table output
- 🚦 **CI integration** — Exit code 1 when stale docs exceed threshold

## Installation

```bash
npm install
```

## Usage

```bash
# Check all docs for staleness
node src/docpulse.js check

# Check with a specific threshold (days)
node src/docpulse.js check --threshold 30

# Generate a report file
node src/docpulse.js check --report stale-docs.md

# Check a specific doc directory
node src/docpulse.js check --docs ./docs --src ./src

# Output as JSON
node src/docpulse.js check --json

# Initialize config
node src/docpulse.js init

# Show doc age stats
node src/docpulse.js stats
```

## Configuration (`.docpulse.json`)

```json
{
  "threshold": 30,
  "docsDir": "docs",
  "srcDir": "src",
  "pairs": [
    { "doc": "docs/api.md", "src": "src/api.js" },
    { "doc": "docs/config.md", "src": "src/config.js" }
  ],
  "ignore": ["docs/CHANGELOG.md", "docs/LICENSE.md"],
  "exitOnStale": true
}
```

## CI Integration

```yaml
- name: Check documentation freshness
  run: node src/docpulse.js check --threshold 60
```

## npm Scripts

| Command | Description |
|---------|-------------|
| `npm start` | Run the CLI |
| `npm test` | Run tests |
| `npm run tracker` | Show achievement progress |
| `npm run roadmap` | Show Day 1 → Month 1 roadmap |

## License

MIT © Your Name
