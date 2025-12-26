---
name: shell
description: |
  Shell configuration management for bazzite-ai. Updates bashrc, zshrc,
  starship.toml, and ghostty configs from /etc/skel defaults. Use when
  users want to reset shell configs to system defaults, check synchronization
  status, or troubleshoot shell configuration issues.
---

# Shell - Configuration Management

## Overview

The `shell` command manages shell configuration files by synchronizing them with system skeleton defaults in `/etc/skel`. It supports bashrc, zshrc, Starship prompt, and Ghostty terminal configurations.

**Key Concept:** System skeleton files in `/etc/skel` contain the default configurations shipped with bazzite-ai. This command helps restore or update user configs to match these defaults.

## Quick Reference

| Action | Command | Description |
|--------|---------|-------------|
| Update configs | `ujust shell update` | Update all configs from /etc/skel (with backup) |
| Check status | `ujust shell status` | Check if configs match skeleton |
| Help | `ujust shell help` | Show usage help |

## Parameters

### ACTION Parameter

```bash
ujust shell ACTION=""

```

| Parameter | Values | Description |
|-----------|--------|-------------|
| `ACTION` | `update`, `status`, `help` | Action to perform |

Without `ACTION`, shows interactive menu (requires TTY).

## Managed Configuration Files

| File | Purpose | Location |
|------|---------|----------|
| `.bashrc` | Bash shell configuration | `~/.bashrc` |
| `.zshrc` | Zsh shell configuration | `~/.zshrc` |
| `starship.toml` | Starship prompt config | `~/.config/starship.toml` |
| `ghostty/` | Ghostty terminal config | `~/.config/ghostty/` |

## Commands

### Update Configurations

```bash
ujust shell update

```

1. Creates timestamped backup of existing configs
2. Copies fresh configs from `/etc/skel`
3. Reports what was updated

**Backup location:** `~/.config-backup-shell-YYYYMMDD_HHMMSS/`

### Check Status

```bash
ujust shell status

```

Shows synchronization status for each config file:

- **Green check**: Up to date (matches skeleton)

- **Yellow X**: Modified (differs from skeleton)

- **Yellow circle**: Not installed (missing)

## Common Workflows

### Reset to Defaults

```bash
# Check current status
ujust shell status

# Update all configs (creates backup first)
ujust shell update

# Reload shell to apply
exec $SHELL

```

### Restore After Bad Customization

```bash
# 1. Update from skeleton (auto-backup)
ujust shell update

# 2. If needed, restore from backup
cp ~/.config-backup-shell-*/.<file> ~/

```

### Check Before Customizing

```bash
# See current sync status
ujust shell status

# If modified, you might want to backup first
cp ~/.bashrc ~/.bashrc.custom

# Then reset to defaults
ujust shell update

```

## Non-Interactive Usage

```bash
# For automation/CI - runs without confirmation
echo | ujust shell update

# Or pipe yes for explicit confirmation
echo "y" | ujust shell update

```

## Troubleshooting

### Starship Prompt Not Working

**Symptom:** Plain bash prompt, no Starship styling

**Cause:** Starship not initialized in shell config

**Fix:**

```bash
ujust shell update
exec $SHELL

```

### Zsh Plugins Not Loading

**Symptom:** Zsh starts without expected plugins

**Cause:** Modified .zshrc missing plugin configuration

**Fix:**

```bash
ujust shell update
source ~/.zshrc

```

### Ghostty Config Missing

**Symptom:** Ghostty uses default settings

**Cause:** Config directory not created

**Fix:**

```bash
ujust shell update
# Restart Ghostty

```

### Backup Location

**Question:** Where are my old configs?

**Answer:**

```bash
ls -la ~/.config-backup-shell-*
# Sorted by date, most recent last

```

## Cross-References

- **Related Skills:** `configure` (for system-level settings)

- **Modern Shell Features:** Includes fzf, zoxide, ripgrep, bat, eza integrations

- **Documentation:** [Managed Configs](./references/managed-configs.md)

## When to Use This Skill

Use when the user asks about:

- "reset shell config", "restore bashrc", "default zshrc"

- "starship not working", "prompt broken"

- "update shell configuration", "sync from skeleton"

- "ghostty config", "terminal settings"

- "compare my config to defaults"
