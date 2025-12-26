---
name: jellyfin
description: |
  Jellyfin media server management via Podman Quadlet. Supports multi-instance
  deployment, hardware transcoding (NVIDIA/AMD/Intel), and FUSE filesystem
  mounts. Use when users need to set up or manage Jellyfin media servers.
---

# Jellyfin - Media Server Management

## Overview

The `jellyfin` command manages Jellyfin media server instances using Podman Quadlet containers. It supports hardware transcoding and FUSE filesystem compatibility for network mounts.

**Key Concept:** Multi-instance support allows running multiple media libraries. FUSE compatibility enables rclone/sshfs mounts for cloud or remote storage.

## Quick Reference

| Action | Command | Description |
|--------|---------|-------------|
| Config | `ujust jellyfin config <CONFIG> <CACHE> <MEDIA> [N] [GPU] [IMAGE] [WORKSPACE]` | Configure instance |
| Start | `ujust jellyfin start [N\|all]` | Start instance(s) |
| Stop | `ujust jellyfin stop [N\|all]` | Stop instance(s) |
| Restart | `ujust jellyfin restart [N\|all]` | Restart instance(s) |
| Logs | `ujust jellyfin logs [N] [LINES]` | View logs |
| List | `ujust jellyfin list` | List all instances |
| Status | `ujust jellyfin status [N]` | Show instance status |
| URL | `ujust jellyfin url [N]` | Show access URL |
| Shell | `ujust jellyfin shell [CMD] [N]` | Open shell in container |
| Delete | `ujust jellyfin delete [N\|all]` | Remove instance(s) and images |

## Configuration

### Config Parameters

```bash
ujust jellyfin config <CONFIG> <CACHE> <MEDIA> [INSTANCE] [GPU] [IMAGE] [WORKSPACE]
```

| Parameter | Required | Description |
|-----------|----------|-------------|
| `CONFIG` | Yes | Configuration directory |
| `CACHE` | Yes | Cache directory (transcoding) |
| `MEDIA` | Yes | Media library path |
| `INSTANCE` | No | Instance number (default: 1) |
| `GPU` | No | GPU type: nvidia, amd, intel, auto |
| `IMAGE` | No | Container image or tag (default: stable) |
| `WORKSPACE` | No | Optional additional mount to /workspace |

### Configuration Examples

```bash
# Basic installation
ujust jellyfin config ~/jellyfin/config ~/jellyfin/cache ~/media 1

# With NVIDIA GPU for transcoding
ujust jellyfin config ~/jellyfin/config ~/jellyfin/cache ~/media 1 nvidia

# Second instance for different library
ujust jellyfin config ~/jellyfin2/config ~/jellyfin2/cache ~/videos 2

# With custom image and workspace
ujust jellyfin config ~/config ~/cache ~/media 1 auto "docker.io/jellyfin/jellyfin:10.8.13" /projects
```

### Update Existing Configuration

Running `config` when already configured will update the existing configuration, preserving values not explicitly changed.

### Shell Access

```bash
# Interactive bash shell
ujust jellyfin shell

# Run specific command
ujust jellyfin shell "df -h"

# Shell in specific instance
ujust jellyfin shell "ls /media" 2
```

## Lifecycle Commands

### Start/Stop

```bash
# Single instance
ujust jellyfin start 1
ujust jellyfin stop 1

# All instances
ujust jellyfin start all
ujust jellyfin stop all
```

### View Logs

```bash
# Follow logs
ujust jellyfin logs 1

# Last N lines
ujust jellyfin logs 1 100
```

### Get URL

```bash
ujust jellyfin url 1
# Output: http://localhost:8096
```

## Port Allocation

| Instance | Port |
|----------|------|
| 1 | 8096 |
| 2 | 8097 |
| 3 | 8098 |
| N | 8095+N |

## Hardware Transcoding

### GPU Types

| GPU | Flag | Transcoding |
|-----|------|-------------|
| NVIDIA | `nvidia` | NVENC/NVDEC |
| AMD | `amd` | VAAPI |
| Intel | `intel` | QuickSync |

### Enable GPU

```bash
ujust jellyfin config ~/config ~/cache ~/media 1 nvidia
```

### Verify GPU

```bash
# Check inside container
ujust jellyfin shell
nvidia-smi  # or vainfo for AMD/Intel
```

## FUSE Filesystem Support

Jellyfin containers support FUSE mounts (rclone, sshfs) for remote storage.

### Mount Before Starting

```bash
# Mount cloud storage
rclone mount gdrive:media ~/media --daemon

# Then start Jellyfin
ujust jellyfin start 1
```

### Why Host Networking?

Jellyfin uses host networking for:

- DLNA discovery
- mDNS/Bonjour
- Chromecast

## Configuration Files

| File | Purpose | Location |
|------|---------|----------|
| Quadlet unit | Service definition | `~/.config/containers/systemd/jellyfin-1.container` |
| Instance config | Settings | `~/.config/jellyfin/instance-1.env` |
| Jellyfin data | Libraries, users | `<CONFIG>/` |
| Transcoding cache | Temp files | `<CACHE>/` |

## Common Workflows

### Initial Setup

```bash
# 1. Create directories
mkdir -p ~/jellyfin/{config,cache}

# 2. Configure Jellyfin
ujust jellyfin config ~/jellyfin/config ~/jellyfin/cache ~/media 1 nvidia

# 3. Start it
ujust jellyfin start 1

# 4. Access web UI
ujust jellyfin url 1
# Open http://localhost:8096
```

### Multiple Libraries

```bash
# Movies library
ujust jellyfin config ~/jellyfin-movies/config ~/jellyfin-movies/cache ~/movies 1

# TV library
ujust jellyfin config ~/jellyfin-tv/config ~/jellyfin-tv/cache ~/tv 2

# Start both
ujust jellyfin start all
```

### Cloud Storage

```bash
# 1. Mount cloud storage
rclone mount gdrive:media ~/cloud-media --daemon --vfs-cache-mode writes

# 2. Configure Jellyfin pointing to mount
ujust jellyfin config ~/jellyfin/config ~/jellyfin/cache ~/cloud-media 1

# 3. Start
ujust jellyfin start 1
```

## Initial Configuration

First-time setup via web UI:

1. Open `http://localhost:8096`
2. Create admin user
3. Add media libraries
4. Configure transcoding (if GPU)
5. Set up remote access

## Troubleshooting

### Jellyfin Won't Start

**Check:**

```bash
ujust jellyfin status 1
ujust jellyfin logs 1 50
```

**Common causes:**

- Port conflict (8096 in use)
- Invalid paths
- GPU driver issues

### Transcoding Fails

**Check:**

```bash
# View logs for transcoding errors
ujust jellyfin logs 1 | grep -i transcode
```

**Common causes:**

- GPU not passed through
- Missing codec support

**Fix:**

```bash
# Reconfigure with GPU
ujust jellyfin delete 1
ujust jellyfin config ~/config ~/cache ~/media 1 nvidia
```

### Media Not Found

**Check:**

- Media directory exists
- Correct path in config
- Permissions

**Fix:**

```bash
# Verify path
ls ~/media

# Reconfigure with correct path
ujust jellyfin delete 1
ujust jellyfin config ~/config ~/cache /correct/path 1
```

### DLNA Not Working

**Cause:** Network isolation

Jellyfin uses host networking, but ensure:

- Firewall allows mDNS (5353/udp)
- Same network as clients

## Cross-References

- **Related Skills:** `configure gpu-containers` (GPU setup)
- **Jellyfin Docs:** <https://jellyfin.org/docs/>
- **Web UI:** [http://localhost:8096](http://localhost:8096)

## When to Use This Skill

Use when the user asks about:

- "install jellyfin", "setup media server"
- "jellyfin not working", "jellyfin transcoding"
- "jellyfin GPU", "hardware transcoding"
- "multiple jellyfin", "jellyfin instances"
