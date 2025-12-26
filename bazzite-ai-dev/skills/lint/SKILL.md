---
name: lint
description: |
  Development: Pre-commit hooks and linting for code quality. Validates
  shell scripts, YAML, markdown, TOML, and justfiles. Run from repository
  root with 'just lint'. Use when developers need to validate code before
  committing or set up pre-commit hooks.
---

# Lint - Pre-commit Hooks & Linting

## Overview

The `lint` development commands manage pre-commit hooks and run linters for code quality validation. It validates shell scripts, YAML, markdown, TOML, and justfile syntax.

**Key Concept:** This is a **development command** - run with `just` from the repository root, not `ujust`. Pre-commit hooks run automatically on `git commit` after installation.

## Quick Reference

| Action | Command | Description |
|--------|---------|-------------|
| Run all linters | `just lint` | Validate all files |
| Install hooks | `just lint-install` | Set up pre-commit hooks |
| Staged files only | `just lint-staged` | Validate staged files |
| Auto-fix | `just lint-fix` | Fix linting issues |
| Update hooks | `just lint-update` | Update hook versions |
| Verify setup | `just verify-hooks` | Check hook installation |

## Linters

| Linter | Files | Description |
|--------|-------|-------------|
| **ShellCheck** | `*.sh`, `*.bash` | Shell script validation |
| **yamllint** | `*.yml`, `*.yaml` | YAML syntax |
| **markdownlint** | `*.md` | Markdown formatting |
| **taplo** | `*.toml` | TOML syntax |
| **just --fmt** | `*.just`, `Justfile` | Justfile syntax |

## Commands

### lint

Run all linters on all files:

```bash
just lint
```

### lint-install

Set up pre-commit hooks (one-time setup):

```bash
just lint-install
```

**Installs hooks:**

- `pre-commit` - Runs before each commit
- `commit-msg` - Validates commit message format
- `pre-push` - Runs before push
- `post-checkout` - Refreshes environment

**Parameters:**

```bash
just lint-install SKIP_PROMPTS="yes"  # Non-interactive mode
```

### lint-staged

Run linters on staged files only (faster):

```bash
just lint-staged
```

### lint-fix

Auto-fix linting issues where possible:

```bash
just lint-fix
```

### lint-update

Update pre-commit hook versions:

```bash
just lint-update
```

### verify-hooks

Verify hook installation and run validation test:

```bash
just verify-hooks
```

## Common Workflows

### First-Time Setup

```bash
# 1. Install linters (if missing)
ujust install linters

# 2. Install pre-commit hooks
just lint-install

# 3. Verify installation
just verify-hooks
```

### Before Committing

```bash
# 1. Stage changes
git add .

# 2. Run linters on staged files
just lint-staged

# 3. Fix any issues
just lint-fix

# 4. Commit (hooks run automatically)
git commit -m "Your message"
```

### CI/CD Validation

```bash
# Run full validation (same as CI)
just lint

# Non-interactive mode for scripts
just lint-install SKIP_PROMPTS="yes"
```

## Pre-commit Configuration

Hooks are configured in `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    # Basic checks
  - repo: https://github.com/shellcheck-py/shellcheck-py
    # Shell script validation
  - repo: https://github.com/adrienverge/yamllint
    # YAML validation
  - repo: https://github.com/igorshubovych/markdownlint-cli
    # Markdown validation
  - repo: https://github.com/tamasfe/taplo
    # TOML validation
```

## Hook Types

| Hook | When | Purpose |
|------|------|---------|
| `pre-commit` | Before commit | Validate code |
| `commit-msg` | After message | Validate commit message |
| `pre-push` | Before push | Final validation |
| `post-checkout` | After checkout | Refresh environment |

## Troubleshooting

### pre-commit Not Found

**Symptom:** `pre-commit: command not found`

**Fix:**

```bash
# Install via pixi
ujust install pixi

# Or via pip
pip install pre-commit
```

### Linters Not Found

**Symptom:** `markdownlint: command not found` or `taplo: command not found`

**Fix:**

```bash
# Install linters
ujust install linters

# This installs markdownlint-cli via npm and taplo via cargo
```

### Hooks Not Installed

**Symptom:** Commits don't run validation

**Fix:**

```bash
# Reinstall hooks
just lint-install

# Verify
just verify-hooks
```

### Hook Fails on Commit

**Symptom:** Commit rejected with linting errors

**Fix:**

```bash
# View specific errors
just lint

# Auto-fix if possible
just lint-fix

# Manually fix remaining issues
# Then commit again
```

### False Positives

**Symptom:** Linter complains about valid code

**Fix:**

```bash
# Add inline ignore comment
# shellcheck disable=SC2086
# yamllint disable-line rule:line-length
<!-- markdownlint-disable MD013 -->
```

## Requirements

- `pre-commit` - Hook framework
- `pixi` - Python environment
- `markdownlint-cli` - Markdown linter (npm)
- `taplo` - TOML linter (cargo)
- ShellCheck, yamllint (system packages)

## Cross-References

- **Related Skills:** `validate` (justfile syntax), `clean` (clean pre-commit cache)
- **Configuration:** `.pre-commit-config.yaml`
- **Linter Install:** `ujust install linters`

## When to Use This Skill

Use when the user asks about:

- "lint", "linting", "validate code"
- "pre-commit", "git hooks", "commit hooks"
- "shellcheck", "yamllint", "markdownlint"
- "just lint", "just lint-install"
- "code quality", "validation failed"
