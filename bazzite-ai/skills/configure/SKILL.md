---
name: configure
description: |
  Unified system configuration dispatcher for bazzite-ai. Manages services
  (Docker, Cockpit, SSH), desktop settings (gamemode, Steam), security
  (passwordless sudo), and development environment (GPU containers). Use
  when users need to enable/disable system features or check configuration status.
---

# Configure - System Configuration Dispatcher

## Overview

The `configure` command is a unified dispatcher for system configuration tasks. It replaces scattered `toggle-*`, `setup-*`, and `configure-*` commands with a single interface.

**Key Concept:** All configuration targets support consistent actions: `enable`, `disable`, `status`, and `help`.

## Quick Reference

| Category | Targets |
|----------|---------|
| **Services** | `docker`, `cockpit`, `syncthing`, `libvirtd`, `sshd` |
| **Desktop** | `gamemode`, `steam-autostart` |
| **Security** | `passwordless-sudo` |
| **Apps** | `podman-permissions`, `podman-extensions`, `winboat` |
| **Development** | `gpu-containers`, `dev-environment` |

## Parameters

### Command Pattern

```bash
ujust configure TARGET="" ACTION="" ARGS...

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
ujust configure docker status        # Show Docker service status
ujust configure docker enable        # Enable Docker daemon
ujust configure docker disable       # Disable Docker daemon
ujust configure docker enable-socket # Enable socket activation only

```

### Cockpit

```bash
ujust configure cockpit status       # Show Cockpit status
ujust configure cockpit enable       # Enable web console
ujust configure cockpit disable      # Disable web console

```

Access at: `[https://localhost](https://localhost):9090`

### Syncthing

```bash
ujust configure syncthing status     # Show Syncthing status
ujust configure syncthing enable     # Enable file sync
ujust configure syncthing disable    # Disable file sync

```

### Libvirtd

```bash
ujust configure libvirtd status      # Show libvirt status
ujust configure libvirtd enable      # Enable virtualization
ujust configure libvirtd disable     # Disable virtualization

```

### SSH Server

```bash
ujust configure sshd status          # Show SSH server status
ujust configure sshd enable          # Enable SSH server
ujust configure sshd disable         # Disable SSH server

```

## Desktop Targets

### Gamemode

```bash
ujust configure gamemode status      # Show current session type
ujust configure gamemode gamemode    # Set to Game Mode session
ujust configure gamemode desktop     # Set to Desktop session

```

### Steam Autostart

```bash
ujust configure steam-autostart status   # Show autostart status
ujust configure steam-autostart enable   # Enable Steam autostart
ujust configure steam-autostart disable  # Disable Steam autostart

```

## Security Targets

### Passwordless Sudo

```bash
ujust configure passwordless-sudo status   # Show sudo config
ujust configure passwordless-sudo enable   # Enable passwordless sudo
ujust configure passwordless-sudo disable  # Disable passwordless sudo

```

**Warning:** Enabling passwordless sudo reduces security. Useful for development/automation.

## Application Targets

### Podman Permissions

```bash
ujust configure podman-permissions status   # Show Podman access
ujust configure podman-permissions enable   # Grant Podman Desktop access
ujust configure podman-permissions disable  # Revoke access

```

### Podman Extensions

```bash
ujust configure podman-extensions show      # List installed extensions
ujust configure podman-extensions open      # Open extension manager

```

### WinBoat

```bash
ujust configure winboat launch              # Launch Windows app
ujust configure winboat info                # Show WinBoat info

```

## Development Targets

### GPU Containers

```bash
ujust configure gpu-containers status       # Show GPU container support
ujust configure gpu-containers setup        # Setup GPU passthrough

```

Configures:

- NVIDIA Container Toolkit

- AMD ROCm container support

- Intel oneAPI container support

### Dev Environment

```bash
ujust configure dev-environment verify      # Verify dev tools installed

```

Checks for required development tools and reports missing items.

## Common Workflows

### Setup Development Environment

```bash
# Enable passwordless sudo for automation
ujust configure passwordless-sudo enable

# Enable Docker for container development
ujust configure docker enable

# Setup GPU container support
ujust configure gpu-containers setup

# Verify everything is ready
ujust configure dev-environment verify

```

### Enable Remote Access

```bash
# Enable SSH server
ujust configure sshd enable

# Enable web console (Cockpit)
ujust configure cockpit enable

# Check both are running
ujust configure sshd status
ujust configure cockpit status

```

### Gaming Setup

```bash
# Set to Game Mode session
ujust configure gamemode gamemode

# Enable Steam autostart
ujust configure steam-autostart enable

```

### Return to Desktop

```bash
# Set to Desktop session
ujust configure gamemode desktop

# Disable Steam autostart
ujust configure steam-autostart disable

```

## Non-Interactive Usage

All commands work without TTY:

```bash
# CI/automation-friendly
ujust configure docker enable
ujust configure passwordless-sudo enable

```

## Troubleshooting

### Service Won't Start

**Symptom:** `ujust configure <service> enable` completes but service not running

**Fix:**

```bash
# Check service status
systemctl status <service>

# Check logs
journalctl -u <service> -n 50

# Try manual start
sudo systemctl start <service>

```

### Podman Permissions Not Working

**Symptom:** Podman Desktop can't access podman

**Cause:** Flatpak permissions not configured

**Fix:**

```bash
ujust configure podman-permissions enable
# Restart Podman Desktop

```

### GPU Containers Not Working

**Symptom:** Containers can't access GPU

**Cause:** GPU container toolkit not configured

**Fix:**

```bash
ujust configure gpu-containers setup
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

- "podman permissions", "flatpak access"
