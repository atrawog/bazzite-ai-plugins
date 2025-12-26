---
name: mirror
description: |
  Local Podman registry mirror management. Cache container images locally for
  faster pulls. Supports any registry (ghcr.io, docker.io, private). Use when
  users need to set up registry mirrors for faster container operations.
---

# Mirror - Podman Registry Mirror

## Overview

The `mirror` command manages local registry mirrors using Podman Quadlet containers. Mirrors cache container images locally for faster pulls.

**Key Concept:** Transparent caching - Podman is auto-configured to use mirrors. Pulls go through the local cache; cache misses fetch from upstream.

## Quick Reference

| Action | Command | Description |
|--------|---------|-------------|
| Install | `ujust mirror install <REGISTRY> [PORT] [AUTH]` | Install mirror |
| Remove | `ujust mirror remove <REGISTRY> [DELETE_CACHE]` | Remove mirror |
| List | `ujust mirror list` | List all mirrors |
| Status | `ujust mirror status <REGISTRY>` | Show mirror status |
| Enable | `ujust mirror enable <REGISTRY>` | Enable (start) mirror |
| Disable | `ujust mirror disable <REGISTRY>` | Disable (stop) mirror |
| Logs | `ujust mirror logs <REGISTRY> [LINES]` | View logs |

## Installation

### Common Registries

```bash
# GitHub Container Registry
ujust mirror install ghcr.io

# Docker Hub
ujust mirror install docker.io

# Quay.io
ujust mirror install quay.io

# NVIDIA NGC
ujust mirror install nvcr.io

```

### With Authentication

```bash
# Private registry with auth
ujust mirror install registry.company.com 5000 user:password

```

### Custom Port

```bash
# Custom port
ujust mirror install docker.io 5001

```

## Port Allocation

Each registry gets a unique port:

| Registry | Default Port |
|----------|--------------|
| ghcr.io | 5000 |
| docker.io | 5001 |
| quay.io | 5002 |
| Custom | Specified |

## Mirror Lifecycle

### Enable/Disable

```bash
# Stop without removing
ujust mirror disable ghcr.io

# Start again
ujust mirror enable ghcr.io

```

### View Logs

```bash
ujust mirror logs ghcr.io
ujust mirror logs docker.io 100

```

### Check Status

```bash
# Single mirror
ujust mirror status ghcr.io

# List all
ujust mirror list

```

## Podman Configuration

Mirrors auto-configure Podman registries.conf. After install:

```bash
# Podman transparently uses mirror
podman pull ghcr.io/org/image:tag
# Actually pulls from localhost:5000 (cached)

```

## Cache Storage

| Item | Location |
|------|----------|
| Cache data | `~/.local/share/containers/mirror/<registry>/` |
| Config | `~/.config/containers/registries.conf.d/` |
| Quadlet | `~/.config/containers/systemd/` |

## Common Workflows

### Setup for Development

```bash
# Install mirrors for common registries
ujust mirror install ghcr.io
ujust mirror install docker.io

# Verify
ujust mirror list

# Now pulls are cached
podman pull ghcr.io/org/image:tag  # First: slow (cache miss)
podman pull ghcr.io/org/image:tag  # Second: fast (cache hit)

```

### CI/CD Optimization

```bash
# For GitHub runners
ujust mirror install ghcr.io

# Runners use cached images
# Significantly faster for repeated pulls

```

### Private Registry

```bash
# With authentication
ujust mirror install registry.mycompany.com 5010 myuser:mypassword

# Verify
ujust mirror status registry.mycompany.com

```

### Remove Mirror

```bash
# Remove but keep cache
ujust mirror remove ghcr.io

# Remove with cache cleanup
ujust mirror remove ghcr.io yes

```

## How It Works

1. **Install**: Creates Quadlet container running registry:2 in mirror mode
2. **Configure**: Updates Podman registries.conf to use mirror
3. **Pull**: Podman checks mirror first
4. **Cache hit**: Serves from local cache
5. **Cache miss**: Fetches from upstream, caches for next time

## Bandwidth Savings

Mirrors are especially useful for:

- Large images (AI/ML containers)

- Frequent rebuilds

- Multiple developers

- CI/CD pipelines

## Troubleshooting

### Mirror Not Working

**Check:**

```bash
ujust mirror status ghcr.io
ujust mirror logs ghcr.io

```

**Verify Podman config:**

```bash
cat ~/.config/containers/registries.conf.d/ghcr.io-mirror.conf

```

### Port Conflict

**Symptom:** "Address already in use"

**Fix:**

```bash
# Use different port
ujust mirror remove ghcr.io
ujust mirror install ghcr.io 5100

```

### Authentication Fails

**Symptom:** 401 errors in logs

**Fix:**

```bash
# Reinstall with correct credentials
ujust mirror remove registry.company.com
ujust mirror install registry.company.com 5000 correct:password

```

### Cache Too Large

**Check:**

```bash
du -sh ~/.local/share/containers/mirror/

```

**Fix:**

```bash
# Remove and reinstall (clears cache)
ujust mirror remove ghcr.io yes
ujust mirror install ghcr.io

```

## Integration with Runners

GitHub runners automatically use mirrors if configured:

```bash
# 1. Install mirror
ujust mirror install ghcr.io

# 2. Install runners
ujust runners install [https://github.com/org/repo](https://github.com/org/repo) 1

# Runners pull through mirror automatically

```

## Cross-References

- **Related Skills:** `runners` (uses mirrors), `pod` (image building)

- **Registry docs:** [https://docs.docker.com/registry/](https://docs.docker.com/registry/)

## When to Use This Skill

Use when the user asks about:

- "registry mirror", "cache container images"

- "faster pulls", "slow container downloads"

- "mirror ghcr", "mirror docker hub"

- "CI optimization", "build faster"
