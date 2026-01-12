# Service Configuration Targets

## Overview

The `ujust config` command manages various system services and settings. This reference documents all available targets.

## Service Targets (systemd)

| Target | Service Unit | Default Port | Purpose |
|--------|--------------|--------------|---------|
| `docker` | `docker.service` | - | Container runtime |
| `cockpit` | `cockpit.socket` | 9090 | Web administration |
| `syncthing` | `syncthing@.service` | 8384 | File synchronization |
| `libvirtd` | `libvirtd.service` | - | Virtualization |
| `sshd` | `sshd.service` | 22 | SSH server |

### Docker

Docker daemon for container development.

```bash
ujust config docker enable        # Full daemon
ujust config docker enable-socket # Socket activation (on-demand)

```

**Socket activation** starts Docker only when needed, saving resources.

### Cockpit

Web-based system administration console.

```bash
ujust config cockpit enable
# Access at: [https://localhost](https://localhost):9090

```

Features:

- System monitoring

- Container management

- Terminal access

- User management

### Syncthing

Peer-to-peer file synchronization.

```bash
ujust config syncthing enable
# Web UI at: http://localhost:8384

```

### Libvirtd

Virtualization management (QEMU/KVM).

```bash
ujust config libvirtd enable

```

Required for:

- `ujust vm` commands

- Virtual Machine Manager (virt-manager)

- GNOME Boxes

### SSHD

SSH server for remote access.

```bash
ujust config sshd enable

```

## Desktop Targets

### Gamemode

Controls boot session type on Steam Deck / gaming-focused systems.

| Value | Session | Description |
|-------|---------|-------------|
| `gamemode` | Steam Big Picture | Boot directly to Steam |
| `desktop` | GNOME/KDE | Boot to desktop environment |

### Steam Autostart

Controls whether Steam starts on login.

```bash
ujust config steam-autostart enable   # Start Steam on login
ujust config steam-autostart disable  # Don't start Steam

```

## Security Targets

### Passwordless Sudo

Allows sudo without password prompt.

**Security implications:**

- Convenience for development

- Required for some automation

- Not recommended for production/shared systems

```bash
ujust config passwordless-sudo enable
# Creates: /etc/sudoers.d/50-<username>-nopasswd

```

## Application Targets

### WinBoat

Windows application integration layer.

```bash
ujust config winboat launch
ujust config winboat info

```

## Development Targets

### GPU Containers

Configures GPU passthrough for containers.

```bash
ujust config gpu setup

```

Configures:

- NVIDIA Container Toolkit (nvidia-ctk)

- AMD ROCm runtime

- Intel oneAPI containers

### Dev Environment

Verifies development tool installation.

```bash
ujust config dev-environment verify

```

Checks for:

- Compilers (gcc, g++, clang)

- Build tools (make, cmake, ninja)

- Languages (Python, Node.js, Go, Rust)

- Utilities (git, curl, jq)
