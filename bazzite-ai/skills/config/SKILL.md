---
name: config
description: |
  Unified system configuration dispatcher for bazzite-ai. Manages services
  (Docker, Cockpit, SSH), desktop settings (gamemode, Steam), security
  (passwordless sudo), and development environment (GPU containers). Use
  when users need to enable/disable system features or check configuration status.
---

# Config - System Configuration Dispatcher

## Overview

The `config` command is a unified dispatcher for system configuration tasks. It replaces scattered `toggle-*`, `setup-*`, and `config-*` commands with a single interface.

**Key Concept:** All configuration targets support consistent actions: `enable`, `disable`, `status`, and `help`.

## Quick Reference

| Category | Targets |
|----------|---------|
| **Services** | `docker`, `cockpit`, `syncthing`, `libvirtd`, `sshd` |
| **Desktop** | `gamemode`, `steam-autostart`, `shell` |
| **Security** | `passwordless-sudo` |
| **Apps** | `winboat` |
| **Development** | `gpu`, `dev-environment` |

## Parameters

### Command Pattern

```bash
ujust config TARGET="" ACTION="" ARGS...

```

| Parameter | Values | Description |
|-----------|--------|-------------|
| `TARGET` | See targets below | Configuration target |
| `ACTION` | `enable`, `disable`, `status`, `help` | Action to perform |
| `ARGS` | varies | Additional arguments |

Without `TARGET`, shows interactive picker.

## Service Targets

### Docker

```bash
ujust config docker status        # Show Docker service status
ujust config docker enable        # Enable Docker daemon
ujust config docker disable       # Disable Docker daemon
ujust config docker enable-socket # Enable socket activation only

```

### Cockpit

```bash
ujust config cockpit status       # Show Cockpit status
ujust config cockpit enable       # Enable web console
ujust config cockpit disable      # Disable web console

```

Access at: `[https://localhost](https://localhost):9090`

### Syncthing

```bash
ujust config syncthing status     # Show Syncthing status
ujust config syncthing enable     # Enable file sync
ujust config syncthing disable    # Disable file sync

```

### Libvirtd

```bash
ujust config libvirtd status      # Show libvirt status
ujust config libvirtd enable      # Enable virtualization
ujust config libvirtd disable     # Disable virtualization

```

### SSH Server

```bash
ujust config sshd status          # Show SSH server status
ujust config sshd enable          # Enable SSH server
ujust config sshd disable         # Disable SSH server

```

## Desktop Targets

### Gamemode

```bash
ujust config gamemode status      # Show current session type
ujust config gamemode gamemode    # Set to Game Mode session
ujust config gamemode desktop     # Set to Desktop session

```

### Steam Autostart

```bash
ujust config steam-autostart status   # Show autostart status
ujust config steam-autostart enable   # Enable Steam autostart
ujust config steam-autostart disable  # Disable Steam autostart

```

### Shell Configuration

Manages shell configuration files by synchronizing them with system skeleton defaults in `/etc/skel`.

```bash
ujust config shell status   # Check if configs match skeleton
ujust config shell update   # Update all configs from /etc/skel (with backup)

```

**Managed files:**

| File | Purpose |
|------|---------|
| `~/.bashrc` | Bash shell configuration |
| `~/.zshrc` | Zsh shell configuration |
| `~/.config/ghostty/` | Ghostty terminal config |

**Backup location:** `~/.config-backup-shell-YYYYMMDD_HHMMSS/`

## Security Targets

### Passwordless Sudo

```bash
ujust config passwordless-sudo status   # Show sudo config
ujust config passwordless-sudo enable   # Enable passwordless sudo
ujust config passwordless-sudo disable  # Disable passwordless sudo

```

**Warning:** Enabling passwordless sudo reduces security. Useful for development/automation.

## Application Targets

### WinBoat

```bash
ujust config winboat launch              # Launch Windows app
ujust config winboat info                # Show WinBoat info

```

## Development Targets

### GPU Containers

```bash
ujust config gpu status       # Show GPU container support
ujust config gpu setup        # Setup GPU passthrough

```

Configures:

- NVIDIA Container Toolkit

- AMD ROCm container support

- Intel oneAPI container support

### Dev Environment

```bash
ujust config dev-environment verify      # Verify dev tools installed

```

Checks for required development tools and reports missing items.

## Common Workflows

### Setup Development Environment

```bash
# Enable passwordless sudo for automation
ujust config passwordless-sudo enable

# Enable Docker for container development
ujust config docker enable

# Setup GPU container support
ujust config gpu setup

# Verify everything is ready
ujust config dev-environment verify

```

### Enable Remote Access

```bash
# Enable SSH server
ujust config sshd enable

# Enable web console (Cockpit)
ujust config cockpit enable

# Check both are running
ujust config sshd status
ujust config cockpit status

```

### Gaming Setup

```bash
# Set to Game Mode session
ujust config gamemode gamemode

# Enable Steam autostart
ujust config steam-autostart enable

```

### Return to Desktop

```bash
# Set to Desktop session
ujust config gamemode desktop

# Disable Steam autostart
ujust config steam-autostart disable

```

## Non-Interactive Usage

All commands work without TTY:

```bash
# CI/automation-friendly
ujust config docker enable
ujust config passwordless-sudo enable

```

## Troubleshooting

### Service Won't Start

**Symptom:** `ujust config <service> enable` completes but service not running

**Fix:**

```bash
# Check service status
systemctl status <service>

# Check logs
journalctl -u <service> -n 50

# Try manual start
sudo systemctl start <service>

```

### GPU Containers Not Working

**Symptom:** Containers can't access GPU

**Cause:** GPU container toolkit not configured

**Fix:**

```bash
ujust config gpu setup
# May require reboot

```

## Cross-References

- **Related Skills:** `install` (for installing tools), `test` (for development)

- **Services:** `jupyter`, `ollama`, `runners` (managed services with lifecycle)

- **Documentation:** [Service Targets](./references/service-targets.md)

## When to Use This Skill

Use when the user asks about:

- "enable Docker", "disable SSH", "configure cockpit"

- "gamemode", "Game Mode session", "desktop mode"

- "passwordless sudo", "sudo without password"

- "GPU containers", "container GPU access"

- "reset shell config", "restore bashrc", "default zshrc"

- "prompt broken", "shell configuration"

- "sync shell from skeleton", "ghostty config"
