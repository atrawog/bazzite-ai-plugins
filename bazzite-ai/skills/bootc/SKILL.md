---
name: bootc
description: |
  bootc VM management via bcvk (bootc virtualization kit). Run bootable
  containers as VMs for testing. Supports ephemeral (quick test) and
  persistent modes. Use when users need to test bootable container images
  as virtual machines.
---

# Bootc - bootc-based VM Management

## Overview

The `bootc` command manages bootable container VMs using bcvk (bootc virtualization kit). It converts OCI container images into bootable VMs for testing.

**Key Concept:** Unlike traditional VMs, bootc VMs are created directly from container images. This enables testing bootable containers without building disk images first.

## Quick Reference

| Action | Command | Description |
|--------|---------|-------------|
| Test | `ujust bootc test [IMAGE]` | Ephemeral VM (deleted on exit) |
| Add | `ujust bootc add [NAME] [IMAGE]` | Create persistent VM |
| List | `ujust bootc list` | List all VMs |
| Status | `ujust bootc status [NAME]` | Show VM status |
| SSH | `ujust bootc ssh [NAME]` | Connect to VM |
| Start | `ujust bootc start [NAME]` | Start VM |
| Stop | `ujust bootc stop [NAME]` | Stop VM |
| Delete | `ujust bootc delete [NAME]` | Remove VM |
| Export | `ujust bootc export [IMAGE] [FORMAT]` | Export to disk image |
| Images | `ujust bootc images` | List available images |
| Help | `ujust bootc help` | Show help |

## Prerequisites

```bash
# Install bcvk
ujust install bcvk

# Verify installation
bcvk --version

```

## Parameters

### Common Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `IMAGE` | (varies) | Container image to boot |
| `VM_NAME` | `bazzite-bootc` | VM name |
| `CPUS` | `2` | Number of CPUs |
| `RAM` | `4096` | Memory in MB |
| `DISK_SIZE` | `20G` | Disk size |
| `SSH_PORT` | `2222` | SSH port |
| `SSH_USER` | `root` | SSH user |
| `FORMAT` | `qcow2` | Export format |

## Ephemeral Testing

Quick test that auto-deletes VM on exit:

```bash
# Test default bazzite-ai image
ujust bootc test

# Test specific image
ujust bootc test ghcr.io/org/image:tag

# Test with more resources
ujust bootc test IMAGE=myimage CPUS=4 RAM=8192

```

Ephemeral mode:

- Creates temporary VM

- Boots to console

- VM deleted when console exits

## Persistent VMs

Create VMs that persist across sessions:

```bash
# Create VM with default image
ujust bootc add dev

# Create with specific image
ujust bootc add testing IMAGE=ghcr.io/org/image:testing

# Custom resources
ujust bootc add heavy CPUS=8 RAM=16384 DISK_SIZE=100G

```

### Manage Persistent VMs

```bash
# Start VM
ujust bootc start dev

# Stop VM
ujust bootc stop dev

# Delete VM
ujust bootc delete dev

```

## Connecting to VMs

### SSH Connection

```bash
# Connect to VM
ujust bootc ssh dev

# Run command
ujust bootc ssh dev -- systemctl status

# Different user
ujust bootc ssh dev SSH_USER=admin

```

Default: `ssh -p 2222 root@localhost`

### List VMs

```bash
ujust bootc list

```

Output:

```

NAME         STATE    IMAGE
dev          running  ghcr.io/org/image:latest
testing      stopped  ghcr.io/org/image:testing

```

### Check Status

```bash
ujust bootc status dev

```

## Export Disk Images

Convert bootable container to disk image:

```bash
# Export to QCOW2
ujust bootc export ghcr.io/org/image:tag

# Export to raw
ujust bootc export ghcr.io/org/image:tag FORMAT=raw

# Export to ISO
ujust bootc export ghcr.io/org/image:tag FORMAT=iso

```

Supported formats:

- `qcow2` - QEMU disk image

- `raw` - Raw disk image

- `iso` - Bootable ISO

## Common Workflows

### Quick Test New Image

```bash
# Test ephemeral (no cleanup needed)
ujust bootc test ghcr.io/myorg/myimage:dev
# Exit console to destroy VM

```

### Development Environment

```bash
# Create persistent VM
ujust bootc add dev IMAGE=ghcr.io/myorg/myimage:latest

# Start it
ujust bootc start dev

# SSH in
ujust bootc ssh dev

# Make changes, test...

# Stop when done
ujust bootc stop dev

```

### Test Before Release

```bash
# Test testing branch
ujust bootc test ghcr.io/myorg/myimage:testing

# If good, test stable
ujust bootc test ghcr.io/myorg/myimage:stable

```

### Create Installation Media

```bash
# Export to ISO for USB boot
ujust bootc export ghcr.io/myorg/myimage:stable FORMAT=iso

# Export to QCOW2 for cloud
ujust bootc export ghcr.io/myorg/myimage:stable FORMAT=qcow2

```

## bcvk vs vm Command

| Feature | `ujust bootc` (bcvk) | `ujust vm` (libvirt) |
|---------|----------------------|----------------------|
| Image source | Container images | QCOW2 files |
| Ephemeral mode | Yes | No |
| Export formats | qcow2/raw/iso | N/A |
| SSH port | 2222 (fixed) | 4444 (configurable) |
| Home sharing | No | Yes (virtiofs) |
| Boot time | Faster | Slower |
| Use case | Testing containers | Full VMs |

**Use `bootc` when:**

- Testing bootable container images

- Quick ephemeral tests

- Building disk images from containers

**Use `vm` when:**

- Need persistent VMs with home sharing

- Need configurable ports

- Need full libvirt features

## Troubleshooting

### bcvk Not Found

**Fix:**

```bash
ujust install bcvk

```

### VM Won't Start

**Check:**

```bash
ujust bootc status dev
ujust bootc list

```

**Common causes:**

- Image not pulled

- Resource conflict

- Disk full

**Fix:**

```bash
ujust bootc delete dev
ujust bootc add dev

```

### SSH Connection Failed

**Check:**

```bash
ssh -p 2222 root@localhost

```

**Common causes:**

- VM still booting

- Port conflict (2222 used)

- SSH not started

**Fix:**

```bash
# Wait for boot
sleep 30
ujust bootc ssh dev

# Or check console
ujust bootc test  # Watch boot process

```

### Image Pull Failed

**Check:**

```bash
podman pull ghcr.io/org/image:tag

```

**Common causes:**

- Network issue

- Auth required

- Image doesn't exist

**Fix:**

```bash
# Login to registry
podman login ghcr.io

# Pull manually
podman pull ghcr.io/org/image:tag

# Retry
ujust bootc add dev IMAGE=ghcr.io/org/image:tag

```

## Cross-References

- **Related Skills:** `vm` (traditional VMs), `install` (bcvk installation)

- **Installation:** `ujust install bcvk`
- **bcvk Docs:** [https://github.com/containers/bcvk](https://github.com/containers/bcvk)

## When to Use This Skill

Use when the user asks about:

- "bootc VM", "bootable container", "test container as VM"

- "bcvk", "bootc virtualization"

- "ephemeral VM", "quick test VM"

- "export to qcow2", "create ISO from container"
