---
name: docs
description: |
  Development: Documentation building and serving with MkDocs Material.
  Builds HTML documentation from markdown sources with auto-reload for
  development. Run from repository root with 'just docs-build' or
  'just docs-serve'. Use when developers need to build or preview docs.
---

# Docs - Documentation Building

## Overview

The `docs` development commands build and serve the bazzite-ai documentation using MkDocs Material. It supports live preview with auto-reload for efficient documentation development.

**Key Concept:** This is a **development command** - run with `just` from the repository root, not `ujust`. Documentation is built during CI/CD and deployed to GitHub Pages automatically.

## Quick Reference

| Action | Command | Description |
|--------|---------|-------------|
| Install deps | `just docs-install` | Install pixi dependencies |
| Build docs | `just docs-build` | Build HTML documentation |
| Serve locally | `just docs-serve` | Serve with auto-reload |
| Full rebuild | `just docs-rebuild` | Clean + build |

## Commands

### docs-install

Installs Python dependencies via pixi:

```bash
just docs-install
```

**Requirements:** pixi must be installed (`curl -fsSL https://pixi.sh/install.sh | bash`)

### docs-build

Builds HTML documentation:

```bash
just docs-build
```

**Output:** `docs/_build/html/`

### docs-serve

Serves documentation locally with auto-reload:

```bash
just docs-serve
```

**URL:** <http://localhost:3000>

Press `Ctrl+C` to stop the server.

### docs-rebuild

Full rebuild (clean + build):

```bash
just docs-rebuild
```

## Documentation Stack

| Tool | Purpose |
|------|---------|
| **MkDocs Material** | Static site generator |
| **pixi** | Python environment management |
| **MyST Markdown** | Extended markdown syntax |

## Common Workflows

### First-Time Setup

```bash
# 1. Install dependencies
just docs-install

# 2. Start development server
just docs-serve

# 3. Open browser
# http://localhost:3000
```

### Development Workflow

```bash
# 1. Start server (auto-reloads on changes)
just docs-serve

# 2. Edit markdown files in docs/
# 3. Browser auto-refreshes

# 4. When done, build for verification
just docs-build
```

### Pre-Commit Validation

```bash
# Build docs before committing
just docs-build

# Verify no broken links or errors in output
```

## Directory Structure

```
docs/
├── index.md              # Home page
├── os/                   # OS documentation
├── pods/                 # Pod documentation
├── development/          # Development docs
├── hooks/                # MkDocs hooks
│   ├── skills_generator.py  # Skills auto-generation
│   └── r2_asset_rewriter.py # Asset handling
└── _build/               # Build output (gitignored)
    └── html/             # HTML output
```

## Configuration Files

| File | Purpose |
|------|---------|
| `mkdocs.yml` | MkDocs configuration |
| `pixi.toml` | Python dependencies |
| `docs/hooks/*.py` | Custom MkDocs hooks |

## Auto-Generated Content

The documentation includes auto-generated content:

- **Skills Reference:** Generated from `plugins/*/skills/*/SKILL.md`
- Skills are transformed and rendered at build time
- No manual duplication needed

## Troubleshooting

### pixi Not Found

**Symptom:** `pixi: command not found`

**Fix:**

```bash
# Install pixi
curl -fsSL https://pixi.sh/install.sh | bash

# Add to PATH
source ~/.bashrc
```

### Build Fails with Import Error

**Symptom:** Python import errors

**Fix:**

```bash
# Reinstall dependencies
just docs-install
```

### Server Won't Start

**Symptom:** Port already in use

**Fix:**

```bash
# Find process using port 3000
lsof -i :3000

# Kill it
kill <PID>

# Or use different port (edit pixi.toml)
```

### Broken Links

**Symptom:** Build warnings about broken links

**Fix:**

```bash
# Check build output for specific files
just docs-build 2>&1 | grep -i "warning"

# Fix the referenced files
```

## CI/CD Integration

Documentation is automatically built and deployed:

1. Push to `testing` branch → Preview at `testing.bazzite-ai.pages.dev`
2. Merge to `main` → Deploy to `bazzite-ai.pages.dev`

**Workflow:** `.github/workflows/docs.yml`

## Cross-References

- **Related Skills:** `lint` (validate markdown), `clean` (clean build output)
- **Configuration:** `mkdocs.yml`, `pixi.toml`
- **Live Site:** <https://bazzite.ai/>

## When to Use This Skill

Use when the user asks about:

- "build docs", "build documentation", "mkdocs"
- "serve docs", "preview docs", "localhost documentation"
- "docs not building", "documentation error"
- "just docs-build", "just docs-serve"
- "add documentation", "write docs"
