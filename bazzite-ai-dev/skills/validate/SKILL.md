---
name: validate
description: |
  Development: Justfile syntax validation and auto-fixing. Checks all .just
  files for syntax errors using 'just --fmt --check'. Run from repository
  root with 'just check' or 'just fix'. Use when developers need to validate
  or fix justfile syntax.
---

# Validate - Justfile Syntax Validation

## Overview

The `validate` development commands check and fix justfile syntax across the repository. It uses `just --fmt` to ensure consistent formatting and valid syntax.

**Key Concept:** This is a **development command** - run with `just` from the repository root, not `ujust`. Syntax validation is also included in pre-commit hooks.

## Quick Reference

| Action | Command | Description |
|--------|---------|-------------|
| Check syntax | `just check` | Validate all .just files |
| Fix syntax | `just fix` | Auto-fix all .just files |

## Commands

### check

Validates syntax of all `.just` files and the root `Justfile`:

```bash
just check
```

**Output:**

- Lists each file being checked
- Reports any syntax errors
- Exits with error code if issues found

### fix

Auto-fixes syntax of all `.just` files and the root `Justfile`:

```bash
just fix
```

**Output:**

- Lists each file being fixed
- Applies formatting corrections
- Exits with error if unfixable issues

## Files Checked

The commands validate:

- All `*.just` files in the repository
- The root `Justfile`

**Typical structure:**

```
.
├── Justfile                    # Root entry point
├── just/
│   ├── build/
│   │   ├── build-os.just
│   │   ├── build-pods.just
│   │   ├── build-vms.just
│   │   ├── build-docs.just
│   │   ├── dev-lint.just
│   │   ├── dev-validation.just
│   │   ├── clean.just
│   │   └── gh.just
│   └── bazzite-ai/
│       ├── test.just
│       └── lib/*.just
```

## Common Workflows

### Before Committing

```bash
# 1. Check for syntax errors
just check

# 2. Fix any issues
just fix

# 3. Verify fixes
just check

# 4. Commit
git add -A && git commit -m "Your message"
```

### CI/CD Validation

```bash
# Check only (fails on error)
just check

# This is equivalent to:
just --unstable --fmt --check -f Justfile
```

## Syntax Rules

The formatter enforces:

- Consistent indentation
- Proper recipe syntax
- Valid interpolation (`{{ variable }}`)
- Correct attribute placement (`[group(...)]`, `[private]`)

## Troubleshooting

### Check Fails with Syntax Error

**Symptom:** `error: unexpected token`

**Fix:**

```bash
# Try auto-fix first
just fix

# If still fails, manually edit the file
# Common issues:
# - Missing quotes around strings
# - Invalid interpolation syntax
# - Incorrect indentation
```

### Fix Doesn't Change Anything

**Symptom:** `just fix` runs but issues persist

**Cause:** Some errors can't be auto-fixed

**Fix:**

```bash
# Check the specific error
just --unstable --fmt --check -f <file>

# Manually edit to fix
```

### Unstable Flag Warning

**Symptom:** Warning about unstable features

**Cause:** `--fmt` requires `--unstable` flag

**Note:** This is expected. The commands include `--unstable` automatically.

## Integration with Pre-commit

Justfile validation is included in pre-commit hooks:

```yaml
# .pre-commit-config.yaml
- repo: local
  hooks:
    - id: just-fmt
      name: just --fmt
      entry: just --unstable --fmt --check
      files: '(\.just$|^Justfile$)'
```

## Cross-References

- **Related Skills:** `lint` (full linting suite), `clean` (clean caches)
- **Justfile Guide:** See `just/build/CLAUDE.md` for conventions
- **Tool:** [just](https://github.com/casey/just)

## When to Use This Skill

Use when the user asks about:

- "check justfile", "validate just", "just syntax"
- "fix justfile", "format just"
- "just check", "just fix"
- "justfile error", "just --fmt"
