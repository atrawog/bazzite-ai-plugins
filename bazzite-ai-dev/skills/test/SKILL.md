---
name: test
description: |
  Overlay testing session management for bazzite-ai development. Enables live
  editing of justfiles via symlinks to /usr on immutable OS (OSTree) or traditional
  Linux systems. Use when users need to test ujust changes, enable overlay mode,
  troubleshoot testing sessions, or run VM/install tests.
---

# Test - Overlay Testing Management

## Overview

The `test` command manages overlay testing sessions for bazzite-ai development. It creates symlinks from the repository to `/usr/share/bazzite-ai/just/`, allowing live editing of justfiles without rebuilding the OS image.

**Key Concept:** On immutable OSTree systems (Bazzite-AI, Silverblue), `/usr` is read-only. Overlay mode temporarily unlocks it. On traditional systems (Fedora, CentOS), symlinks provide the same live-editing capability.

**Command Prefix:**
- `just test` - Development mode (from repository root, any Linux system)
- `ujust test` - Installed mode (on bazzite-ai system with test.just installed)

The Quick Reference shows `ujust` commands (installed mode). The Common Workflows section shows `just` commands (development mode from repo root).

## Quick Reference

| Action | Command | Description |
|--------|---------|-------------|
| Enable overlay | `ujust test overlay enable` | Bootstrap overlay testing session |
| Check status | `ujust test overlay check` | Show current overlay/symlink status |
| Refresh | `ujust test overlay refresh` | Regenerate 60-custom.just after changes |
| VM testing | `ujust test vm` | VM testing submenu |
| Install testing | `ujust test install` | Test install commands |
| Install all | `ujust test install all` | Test all install commands |
| System info | `ujust test info` | Show detailed system info |
| Help | `ujust test help` | Show usage help |

## Parameters

### ACTION Parameter

```bash
ujust test ACTION="" SUBACTION="" ARGS...

```

| Parameter | Values | Description |
|-----------|--------|-------------|
| `ACTION` | `overlay`, `vm`, `install`, `info`, `help` | Primary action |
| `SUBACTION` | `enable`, `check`, `refresh` (for overlay) | Subaction |
| `ARGS` | varies | Additional arguments for vm/install |

### Rule of Intent

When `ACTION` is provided, the command runs non-interactively. Without it, an interactive menu appears.

## Overlay Subcommands

### Enable Overlay

```bash
ujust test overlay enable

```

1. Activates overlay mode (OSTree) or creates symlinks (traditional)
2. Detects repository location automatically
3. Sets up symlinks to `/usr/share/bazzite-ai/just/`
4. Generates `60-custom.just` import file
5. Requires sudo (handles internally)

### Check Status

```bash
ujust test overlay check

```

Shows current status:

- **Immutable OS**: Whether overlay mode is active

- **Traditional OS**: Whether symlinks are configured

- Target repository path

### Refresh Overlay

```bash
ujust test overlay refresh

```

Use after:

- Adding new `.just` files

- Removing `.just` files

- Modifying the generator script

Regenerates `60-custom.just` without full restart.

## VM Testing

```bash
ujust test vm              # Interactive VM test menu
ujust test vm list         # List available VM tests
ujust test vm <name>       # Run specific VM test

```

Delegates to the VM testing harness for testing in virtual machines.

## Install Testing

```bash
ujust test install         # Interactive install test menu
ujust test install all     # Test all install commands
ujust test install <name>  # Test specific install command

```

Tests install commands for validation.

## Common Workflows

### Initial Development Setup

```bash
# 1. Clone repository
git clone <repo-url> && cd bazzite-ai

# 2. Enable overlay testing (one-time)
just test overlay enable

# 3. Make changes to justfiles
vim just/bazzite-ai/my-feature.just

# 4. Test immediately with ujust
ujust my-feature

# 5. If adding new files, refresh
just test overlay refresh

```

### After Reboot (Immutable OS Only)

```bash
# Overlay resets on reboot - re-enable
just test overlay enable

# Your git commits persist, overlay changes don't

```

### Testing a New Command

```bash
# 1. Create/edit the justfile
vim just/bazzite-ai/new-command.just

# 2. Refresh to pick up new file
just test overlay refresh

# 3. Test the command
ujust new-command

```

## OS Type Detection

| OS Type | Detection | Overlay Method |
|---------|-----------|----------------|
| Immutable (OSTree) | `/run/ostree-booted` exists | `rpm-ostree` overlay |
| Traditional | No OSTree marker | Symlinks only |

## Troubleshooting

### Overlay Not Active After Enable

**Symptom:** `ujust test overlay check` shows "Normal immutable mode"

**Cause:** Overlay activation failed or needs reboot

**Fix:**

```bash
# Check if rpm-ostree unlock succeeded
sudo rpm-ostree status | grep -i unlock

# If not, try manual unlock
sudo rpm-ostree usroverlay

```

### Symlinks Not Working

**Symptom:** Changes to justfiles not reflected in `ujust` output

**Cause:** Symlinks not properly created or 60-custom.just not regenerated

**Fix:**

```bash
# Check symlink status
ls -la /usr/share/bazzite-ai/just/

# Re-enable overlay
just test overlay enable

# Refresh imports
just test overlay refresh

```

### Command Not Found After Adding File

**Symptom:** New recipe not available in `ujust --list`

**Cause:** 60-custom.just needs regeneration

**Fix:**

```bash
just test overlay refresh

```

### Permission Denied

**Symptom:** `sudo: a terminal is required`

**Cause:** Running in non-interactive mode without passwordless sudo

**Fix:**

```bash
# Enable passwordless sudo first
ujust config passwordless-sudo enable

# Then retry
just test overlay enable

```

## Cross-References

- **Related Skills:** `install` (for testing install commands), `vm` (for VM testing)

- **Configuration:** `ujust config passwordless-sudo enable` for sudo access

- **Documentation:** [Overlay Testing Architecture](./references/overlay-architecture.md)

## When to Use This Skill

Use when the user asks about:

- "enable overlay", "start testing session", "development mode"

- "test my changes", "live reload justfiles"

- "overlay not working", "symlinks not configured"

- "refresh overlay", "pick up new files"

- "VM testing", "test in VM"

- "test install commands"
