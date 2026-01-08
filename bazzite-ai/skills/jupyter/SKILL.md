---
name: jupyter
description: |
  JupyterLab ML/AI development environment management via Podman Quadlet.
  Supports multi-instance deployment, GPU acceleration (NVIDIA/AMD/Intel),
  token authentication, and per-instance configuration. Use when users need
  to configure, start, stop, or manage JupyterLab containers for ML development.
---

# Jupyter - ML/AI Development Environment

## Overview

The `jupyter` command manages JupyterLab instances for ML/AI development using Podman Quadlet containers. Each instance runs as a systemd user service with optional GPU acceleration.

**Key Concept:** Multi-instance support allows running multiple isolated JupyterLab environments simultaneously, each on different ports with different GPU configurations.

## Quick Reference

| Action | Command | Description |
|--------|---------|-------------|
| Config | `ujust jupyter config [N] [PORT] [GPU] [IMAGE] [WORKSPACE]` | Configure instance N |
| Start | `ujust jupyter start [N\|all]` | Start instance(s) |
| Stop | `ujust jupyter stop [N\|all]` | Stop instance(s) |
| Restart | `ujust jupyter restart [N\|all]` | Restart instance(s) |
| Logs | `ujust jupyter logs [N] [LINES]` | View logs |
| List | `ujust jupyter list` | List all instances |
| Status | `ujust jupyter status [N]` | Show instance status |
| URL | `ujust jupyter url [N]` | Show access URL |
| Shell | `ujust jupyter shell [CMD] [N]` | Open shell in container |
| Token enable | `ujust jupyter token-enable [N]` | Enable token auth |
| Token show | `ujust jupyter token-show [N]` | Show token |
| Token disable | `ujust jupyter token-disable [N]` | Disable token auth |
| Token regenerate | `ujust jupyter token-regenerate [N]` | Generate new token |
| Delete | `ujust jupyter delete [N\|all]` | Remove instance(s) and images |

## Parameters

### Config Parameters

```bash
ujust jupyter config [INSTANCE] [PORT] [GPU_TYPE] [IMAGE] [WORKSPACE]
```

| Parameter | Default | Description |
|-----------|---------|-------------|
| `INSTANCE` | `1` | Instance number (1, 2, 3...) |
| `PORT` | `8888` | Web UI port |
| `GPU_TYPE` | `auto` | GPU type: `nvidia`, `amd`, `intel`, `none`, `auto` |
| `IMAGE` | `stable` | Container image or tag |
| `WORKSPACE` | (empty) | Optional additional mount to /workspace |

### Instance Numbering

- Instance 1: Port 8888 (default)
- Instance 2: Port 8889
- Instance N: Port 8887+N

## Configuration Examples

```bash
# Default: Instance 1, port 8888, auto-detect GPU
ujust jupyter config

# Instance 2 with custom port and NVIDIA GPU
ujust jupyter config 2 8889 nvidia

# Instance 3 with AMD GPU
ujust jupyter config 3 8890 amd

# No GPU acceleration
ujust jupyter config 1 8888 none

# With workspace mount
ujust jupyter config 1 8888 nvidia stable /home/user/projects

# Custom image
ujust jupyter config 1 8888 nvidia "ghcr.io/custom/jupyter:v1" /projects
```

### Update Existing Configuration

Running `config` when already configured will update the existing configuration, preserving values not explicitly changed.

### Shell Access

```bash
# Interactive bash shell
ujust jupyter shell

# Run specific command
ujust jupyter shell "pip list"

# Shell in specific instance
ujust jupyter shell "nvidia-smi" 2
```

## Lifecycle Commands

### Start/Stop/Restart

```bash
# Single instance
ujust jupyter start 1
ujust jupyter stop 1
ujust jupyter restart 1

# All instances
ujust jupyter start all
ujust jupyter stop all
ujust jupyter restart all
```

### View Logs

```bash
# Follow logs (default)
ujust jupyter logs 1

# Last N lines
ujust jupyter logs 1 100
```

### Get Access URL

```bash
ujust jupyter url 1
# Output: http://localhost:8888
```

## Token Authentication

By default, JupyterLab requires no token for local development. Enable token auth for remote access or shared environments.

```bash
# Enable token (generates random token)
ujust jupyter token-enable 1

# Show current token
ujust jupyter token-show 1

# Disable token (password-less access)
ujust jupyter token-disable 1

# Generate new token
ujust jupyter token-regenerate 1
```

## Configuration Files

| File | Purpose | Location |
|------|---------|----------|
| Quadlet unit | Service definition | `~/.config/containers/systemd/jupyter-1.container` |
| Instance config | Per-instance settings | `~/.config/jupyter/instance-1.env` |

## Volume Mounts

| Container Path | Host Path | Purpose |
|----------------|-----------|---------|
| `/workspace` | `$HOME` | User home directory |
| `/home/jovyan/.jupyter` | `~/.jupyter` | Jupyter config |

## Common Workflows

### Initial Setup

```bash
# 1. Configure JupyterLab with GPU support
ujust jupyter config 1 8888 nvidia

# 2. Start the instance
ujust jupyter start 1

# 3. Get the URL
ujust jupyter url 1

# 4. Open in browser
# http://localhost:8888
```

### Multiple Environments

```bash
# PyTorch environment
ujust jupyter config 1 8888 nvidia pytorch

# TensorFlow environment
ujust jupyter config 2 8889 nvidia tensorflow

# CPU-only data science
ujust jupyter config 3 8890 none datascience

# Start all
ujust jupyter start all

# List all
ujust jupyter list
```

### Remote Access

```bash
# Enable token for security
ujust jupyter token-enable 1

# Get token
ujust jupyter token-show 1
# Use: http://your-ip:8888/?token=<token>
```

## GPU Support

### Automatic Detection

```bash
ujust jupyter config  # Auto-detects GPU type
```

### Manual Selection

| GPU Type | Flag | Requirements |
|----------|------|--------------|
| NVIDIA | `nvidia` | NVIDIA drivers + nvidia-container-toolkit |
| AMD | `amd` | ROCm drivers |
| Intel | `intel` | oneAPI runtime |
| None | `none` | CPU only |

### Verify GPU Access

```bash
ujust jupyter shell "nvidia-smi"  # NVIDIA
ujust jupyter shell "rocm-smi"    # AMD
```

## Troubleshooting

### Instance Won't Start

**Symptom:** `ujust jupyter start 1` fails

**Check:**

```bash
# Check service status
systemctl --user status jupyter-1

# Check logs
ujust jupyter logs 1 50
```

**Common causes:**

- Port already in use
- GPU not available
- Image not pulled

### GPU Not Detected

**Symptom:** No GPU acceleration in notebooks

**Check:**

```bash
# Verify GPU config
ujust jupyter status 1

# Test inside container
ujust jupyter shell "nvidia-smi"
```

**Fix:**

```bash
# Reconfigure with explicit GPU type
ujust jupyter delete 1
ujust jupyter config 1 8888 nvidia
```

### Token Issues

**Symptom:** Can't access Jupyter, token required

**Fix:**

```bash
# Show current token
ujust jupyter token-show 1

# Or disable token for local use
ujust jupyter token-disable 1
```

### Port Conflict

**Symptom:** "Address already in use"

**Fix:**

```bash
# Find what's using the port
lsof -i :8888

# Use different port
ujust jupyter config 1 8889
```

## Cross-References

- **Related Skills:** `pod` (build images), `configure gpu` (GPU setup)
- **GPU Setup:** `ujust config gpu setup`
- **Documentation:** [Podman Quadlet Docs](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html)

## When to Use This Skill

Use when the user asks about:

- "install jupyter", "setup jupyterlab", "ML development"
- "start jupyter", "stop jupyter", "restart jupyter"
- "jupyter not working", "jupyter won't start"
- "jupyter token", "jupyter password", "jupyter authentication"
- "jupyter GPU", "jupyter nvidia", "jupyter cuda"
- "multiple jupyter", "second jupyter instance"
