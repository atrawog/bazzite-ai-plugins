---
name: portainer
description: |
  Portainer CE container management UI via Podman Quadlet. Provides web-based
  management of Podman containers, images, volumes, and networks. Supports
  multi-instance deployment and k3d Kubernetes integration. Use when users
  need a graphical interface to manage their containers.
---

# Portainer - Container Management UI

## Overview

The `portainer` command manages Portainer CE (Community Edition), a web-based container management UI. It provides visual management of Podman containers, images, volumes, and networks through a browser interface.

**Key Concept:** Portainer connects to the local Podman socket (rootless) and optionally to k3d Kubernetes clusters. Multi-instance support allows running separate Portainer instances for different use cases.

## Quick Reference

| Action | Command | Description |
|--------|---------|-------------|
| Config | `ujust portainer config [--port=N] [--bind=ADDR]` | Configure Portainer instance |
| Start | `ujust portainer start [--instance=N\|all]` | Start Portainer |
| Stop | `ujust portainer stop [--instance=N\|all]` | Stop Portainer |
| Restart | `ujust portainer restart [--instance=N\|all]` | Restart Portainer |
| Logs | `ujust portainer logs [--instance=N] [--lines=N]` | View container logs |
| Status | `ujust portainer status [--instance=N]` | Show status and info |
| URL | `ujust portainer url [--instance=N]` | Show web UI access URLs |
| Shell | `ujust portainer shell [--instance=N] [-- CMD]` | Execute command in container |
| Delete | `ujust portainer delete [--instance=N\|all]` | Remove instance and config |

## Parameters

| Parameter | Long Flag | Short | Default | Description |
|-----------|-----------|-------|---------|-------------|
| action | (positional) | - | required | Action: config, start, stop, etc. |
| port | `--port` | `-p` | `9443` | HTTPS port for web UI |
| bind | `--bind` | `-b` | `127.0.0.1` | Bind address |
| instance | `--instance` | `-n` | `1` | Instance number |
| image | `--image` | `-i` | `portainer/portainer-ce` | Container image |
| tag | `--tag` | `-t` | `latest` | Image tag |
| config_dir | `--config-dir` | `-c` | `~/.config/portainer/{N}` | Config directory |
| lines | `--lines` | `-l` | `50` | Log lines to show |
| admin_user | `--admin-user` | `-u` | `admin` | Admin username |
| admin_password | `--admin-password` | - | (generated) | Admin password |
| add_podman | `--add-podman` | - | `true` | Add local Podman endpoint |
| add_k3d | `--add-k3d` | - | `false` | Add k3d Kubernetes endpoint |
| k3d_instance | `--k3d-instance` | - | `1` | k3d instance to connect |

## Configuration

```bash
# Default: Port 9443, localhost only, Podman endpoint
ujust portainer config

# Custom HTTPS port (long form)
ujust portainer config --port=9444

# Custom HTTPS port (short form)
ujust portainer config -p 9444

# Network-wide access
ujust portainer config --bind=0.0.0.0

# Combine parameters (short form)
ujust portainer config -p 9444 -b 0.0.0.0

# With k3d Kubernetes integration
ujust portainer config --add-k3d

# Connect to specific k3d cluster
ujust portainer config --add-k3d --k3d-instance=2

# Custom admin credentials
ujust portainer config --admin-user=myuser --admin-password=mypassword

# Disable Podman endpoint (k3d only)
ujust portainer config --add-podman=false --add-k3d
```

### Update Existing Configuration

Running `config` when already configured will update settings. To fully reset:

```bash
ujust portainer delete
ujust portainer config
```

## Lifecycle Commands

### Start/Stop/Restart

```bash
# Start Portainer (instance 1 default)
ujust portainer start

# Start specific instance (long form)
ujust portainer start --instance=1

# Start specific instance (short form)
ujust portainer start -n 1

# Start all instances
ujust portainer start --instance=all

# Stop Portainer
ujust portainer stop
ujust portainer stop --instance=all

# Restart Portainer
ujust portainer restart
ujust portainer restart --instance=all
```

### View Logs

```bash
# View logs (default 50 lines)
ujust portainer logs

# More lines (long form)
ujust portainer logs --lines=100

# More lines (short form)
ujust portainer logs -l 100

# Specific instance
ujust portainer logs -n 2 -l 100
```

### Get URL

```bash
# Show access URL
ujust portainer url
# Output: https://localhost:9443

# Specific instance
ujust portainer url --instance=2
```

## Shell Access

```bash
# Interactive shell
ujust portainer shell

# Run specific command (use -- separator)
ujust portainer shell -- ls -la /data
ujust portainer shell -- cat /data/portainer.db

# Specific instance
ujust portainer shell -n 2 -- df -h
```

## Web UI Access

Portainer uses HTTPS with a self-signed certificate:

```
https://localhost:9443
```

**First Login:**
1. Open URL in browser
2. Accept self-signed certificate warning
3. Create admin account (or use credentials from `--admin-user`/`--admin-password`)
4. Select "Get Started" or configure additional endpoints

## Endpoints

Portainer can manage multiple container runtimes:

### Local Podman (Default)

Connects to the local Podman socket at:
```
/run/user/$(id -u)/podman/podman.sock
```

**Prerequisite:**
```bash
systemctl --user enable --now podman.socket
```

### k3d Kubernetes

Connect to local k3d clusters:

```bash
# Add k3d endpoint during config
ujust portainer config --add-k3d

# Or connect to specific cluster
ujust portainer config --add-k3d --k3d-instance=2
```

## Multi-Instance

Run multiple Portainer instances:

```bash
# Primary instance (port 9443)
ujust portainer config -n 1 -p 9443

# Secondary instance (port 9444)
ujust portainer config -n 2 -p 9444

# List status of all
ujust portainer status

# Start/stop all
ujust portainer start --instance=all
ujust portainer stop --instance=all
```

| Instance | Default Port | Config Dir |
|----------|--------------|------------|
| 1 | 9443 | `~/.config/portainer/1/` |
| 2 | 9444 | `~/.config/portainer/2/` |
| N | 9442+N | `~/.config/portainer/N/` |

## Common Workflows

### Initial Setup

```bash
# 1. Enable Podman socket
systemctl --user enable --now podman.socket

# 2. Configure Portainer
ujust portainer config

# 3. Start Portainer
ujust portainer start

# 4. Get URL
ujust portainer url

# 5. Open browser at https://localhost:9443
```

### With k3d Kubernetes

```bash
# 1. Create k3d cluster
ujust k3d config
ujust k3d start

# 2. Configure Portainer with k3d
ujust portainer config --add-k3d

# 3. Start Portainer
ujust portainer start

# 4. Access UI - both Podman and k3d visible
```

### Network Access

```bash
# Configure for remote access
ujust portainer config --bind=0.0.0.0

# Access from other machines
# https://<hostname>:9443
```

### Headless Setup (Scripted)

```bash
# Configure with predefined credentials
ujust portainer config \
  --admin-user=admin \
  --admin-password=mysecurepassword \
  --bind=0.0.0.0

# Start non-interactively
ujust portainer start

# Verify running
ujust portainer status
```

## Configuration Files

| File | Purpose | Location |
|------|---------|----------|
| Quadlet unit | Service definition | `~/.config/containers/systemd/portainer-{N}.container` |
| Instance config | Per-instance settings | `~/.config/portainer/{N}/config` |
| Portainer data | UI settings, users | `~/.config/portainer/{N}/data/` |

## Volume Mounts

| Container Path | Host Path | Purpose |
|----------------|-----------|---------|
| `/data` | `~/.config/portainer/{N}/data` | Portainer database |
| `/var/run/podman/podman.sock` | Socket | Podman access |

## Troubleshooting

### Can't Access Web UI

**Symptom:** Browser shows "connection refused"

**Check:**

```bash
ujust portainer status
ujust portainer logs
```

**Common causes:**

- Portainer not started
- Wrong port
- Firewall blocking

**Fix:**

```bash
ujust portainer start
ujust portainer url  # Verify correct URL
```

### Certificate Warning

**Symptom:** Browser warns about untrusted certificate

**Cause:** Self-signed certificate (expected)

**Fix:** Accept the certificate warning in your browser. This is normal for local development.

### Podman Socket Not Found

**Symptom:** "Unable to connect to Docker/Podman"

**Check:**

```bash
systemctl --user status podman.socket
ls -la /run/user/$(id -u)/podman/podman.sock
```

**Fix:**

```bash
systemctl --user enable --now podman.socket
```

### k3d Not Connecting

**Symptom:** k3d endpoint shows "Connection failed"

**Check:**

```bash
ujust k3d status
ujust k3d shell -- kubectl get nodes
```

**Fix:**

```bash
# Ensure k3d is running
ujust k3d start

# Recreate Portainer with k3d
ujust portainer delete
ujust portainer config --add-k3d
ujust portainer start
```

### Admin Password Lost

**Symptom:** Forgot admin password

**Fix:**

```bash
# Reset Portainer
ujust portainer delete
ujust portainer config --admin-password=newpassword
ujust portainer start
```

## Cross-References

- **Related Skills:** `k3d` (Kubernetes), `pods` (pod management)
- **Portainer Docs:** <https://docs.portainer.io/>
- **Podman Socket:** `systemctl --user enable --now podman.socket`

## When to Use This Skill

Use when the user asks about:

- "portainer", "container UI", "docker UI"
- "visual container management", "web interface for containers"
- "manage podman containers", "podman web UI"
- "start portainer", "configure portainer", "portainer not working"
- "k3d management UI", "kubernetes dashboard"
