---
name: tailscale
description: |
  Tailscale Serve management for exposing local services to your tailnet.
  Auto-detects running bazzite-ai services and creates persistent HTTPS
  endpoints. Use when users need to expose Jupyter, Ollama, ComfyUI or
  other services to their Tailscale network.
---

# Tailscale - Service Exposure via Tailnet

## Overview

The `tailscale` command manages Tailscale Serve to expose local bazzite-ai services to your tailnet. It provides HTTPS endpoints with auto-provisioned certificates.

**Key Concept:** Tailscale Serve exposes local services only to your tailnet (not the public internet). HTTPS certificates are automatically provisioned and managed by Tailscale.

## Quick Reference

| Action | Command | Description |
|--------|---------|-------------|
| List | `ujust tailscale list` | List available bazzite-ai services |
| Serve | `ujust tailscale serve SERVICE [--port=N]` | Expose service to tailnet via HTTPS |
| Status | `ujust tailscale status` | Show current serve configuration |

## Prerequisites

```bash
# Tailscale must be installed and logged in
sudo dnf install tailscale
sudo systemctl enable --now tailscaled
tailscale up
```

## Parameters

| Parameter | Long Flag | Short | Default | Description |
|-----------|-----------|-------|---------|-------------|
| action | (positional) | - | required | Action: serve, unserve, status, list |
| service | `--service` | `-s` | `""` | Service name or port number |
| port | `--port` | `-p` | `""` | Tailscale HTTPS port to expose on |

## Known Services

| Service | Default Port | Description |
|---------|--------------|-------------|
| `jupyter` | 8888 | JupyterLab notebooks |
| `ollama` | 11434 | Ollama LLM API |
| `comfyui` | 8188 | ComfyUI Stable Diffusion |
| `openwebui` | 3000 | Open WebUI chat interface |
| `fiftyone` | 5151 | FiftyOne dataset visualization |

## Serve Commands

### Serve by Service Name

```bash
# Auto-detect port for known services (long form)
ujust tailscale serve --service=jupyter

# Auto-detect port for known services (short form)
ujust tailscale serve -s jupyter

# Serve ollama
ujust tailscale serve -s ollama

# Serve comfyui
ujust tailscale serve -s comfyui

# Serve openwebui
ujust tailscale serve -s openwebui
```

### Serve by Port Number

```bash
# Serve arbitrary port (long form)
ujust tailscale serve --service=8080

# Serve arbitrary port (short form)
ujust tailscale serve -s 8080

# Or just the port
ujust tailscale serve 8080
```

### Serve with Custom Tailscale Port

```bash
# Expose jupyter on tailscale port 443 (long form)
ujust tailscale serve --service=jupyter --port=443

# Expose jupyter on tailscale port 443 (short form)
ujust tailscale serve -s jupyter -p 443

# Expose on multiple tailscale ports
ujust tailscale serve -s jupyter -p 8888
ujust tailscale serve -s ollama -p 11434
```

## Unserve Commands

```bash
# Stop serving a specific service (long form)
ujust tailscale unserve --service=jupyter

# Stop serving a specific service (short form)
ujust tailscale unserve -s jupyter

# Stop serving by port
ujust tailscale unserve -s 8888

# Stop all serves
ujust tailscale unserve all
```

## Status Commands

```bash
# Show current serve configuration
ujust tailscale status

# List available bazzite-ai services
ujust tailscale list
```

## Common Workflows

### Expose JupyterLab

```bash
# 1. Ensure Jupyter is running
ujust jupyter start

# 2. Expose to tailnet
ujust tailscale serve -s jupyter

# 3. Access from any tailnet device
# https://<hostname>.<tailnet-name>.ts.net:8888
```

### Expose Multiple Services

```bash
# Start services
ujust jupyter start
ujust ollama start
ujust comfyui start

# Expose all
ujust tailscale serve -s jupyter
ujust tailscale serve -s ollama
ujust tailscale serve -s comfyui

# Check status
ujust tailscale status
```

### Remote AI Development

```bash
# On your server
ujust jupyter config --bind=127.0.0.1  # Only localhost
ujust jupyter start
ujust tailscale serve -s jupyter

# On your laptop (connected to same tailnet)
# Access: https://<server>.<tailnet>.ts.net:8888
```

### Clean Up All Serves

```bash
# Stop all tailscale serves
ujust tailscale unserve all

# Verify
ujust tailscale status
```

## Features

### Auto-Detection

When you serve a known service, the command auto-detects:

- Whether the service is running
- The correct local port
- Appropriate HTTPS configuration

### Persistent Serves

Serves persist across reboots. Tailscale remembers your configuration.

### HTTPS Certificates

Tailscale automatically:

- Provisions certificates
- Handles renewals
- Terminates TLS at edge

### Tailnet-Only

Unlike Tailscale Funnel, Serve only exposes to your tailnet:

- No public internet exposure
- Access limited to your devices
- Requires Tailscale authentication

## Troubleshooting

### Service Not Found

**Symptom:** "Service not found" error

**Check:**

```bash
# Verify service is running
ujust jupyter status
systemctl --user status jupyter-1
```

**Fix:**

```bash
# Start the service first
ujust jupyter start
# Then serve
ujust tailscale serve -s jupyter
```

### Tailscale Not Running

**Symptom:** "Tailscale not running or not logged in"

**Fix:**

```bash
# Start tailscaled
sudo systemctl start tailscaled

# Login to Tailscale
tailscale up
```

### Cannot Access from Other Device

**Check:**

```bash
# Verify serve is active
ujust tailscale status

# Check Tailscale connection
tailscale status
```

**Common causes:**

- Not on same tailnet
- Firewall blocking
- Service not bound to localhost

**Fix:**

```bash
# Ensure service binds to localhost (required for Serve)
ujust jupyter config --bind=127.0.0.1
ujust jupyter restart
ujust tailscale serve -s jupyter
```

### Port Conflict

**Symptom:** "Port already in use on tailscale"

**Fix:**

```bash
# Use different tailscale port
ujust tailscale serve -s jupyter -p 8889
```

## Security Considerations

**Tailscale Serve is secure by design:**

- Only accessible from your tailnet
- Requires Tailscale authentication
- Uses WireGuard encryption
- HTTPS with auto-managed certificates

**Best practices:**

1. Keep services bound to localhost (`127.0.0.1`)
2. Use strong Tailscale ACLs
3. Review serves periodically with `status`
4. Remove unused serves with `unserve`

## Cross-References

- **Related Skills:** `jupyter`, `ollama`, `comfyui`, `openwebui`
- **Prerequisites:** `ujust config tailscale enable`
- **Tailscale Docs:** <https://tailscale.com/kb/1242/tailscale-serve>

## When to Use This Skill

Use when the user asks about:

- "expose to tailnet", "tailscale serve"
- "access jupyter remotely", "remote access"
- "share service with tailscale"
- "tailscale status", "stop tailscale serve"
