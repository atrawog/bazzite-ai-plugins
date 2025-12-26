---
name: vms
description: |
  Development: VM image (QCOW2/RAW) and live ISO building. Creates bootable
  images from the OS container using bootc-image-builder and Titanoboa.
  Run from repository root with 'just build-qcow2' or 'just build-iso'.
  Use when developers need to create deployable VM or installer images.
---

# VMs - Virtual Machine & ISO Building

## Overview

The `vms` development commands create bootable images from the bazzite-ai OS container. It supports QCOW2/RAW VM images via bootc-image-builder and live ISOs via Titanoboa.

**Key Concept:** This is a **development command** - run with `just` from the repository root, not `ujust`. These commands create images for deployment, not for running VMs (use `ujust vm` for that).

## Quick Reference

| Action | Command | Description |
|--------|---------|-------------|
| Build QCOW2 | `just build-qcow2` | Create QCOW2 VM image |
| Build RAW | `just build-raw` | Create RAW VM image |
| Build ISO | `just build-iso` | Create live ISO (Titanoboa) |
| Build NVIDIA ISO | `just build-iso-nvidia` | Create NVIDIA live ISO |
| Build all ISOs | `just build-iso-all` | Create standard + NVIDIA ISOs |
| Rebuild QCOW2 | `just rebuild-qcow2` | Build OS then QCOW2 |
| Rebuild ISO | `just rebuild-iso` | Build OS then ISO |
| Cloud-init seed | `just create-cloud-seed` | Create seed.iso for VMs |

## Aliases

| Alias | Target |
|-------|--------|
| `just build-vm` | `just build-qcow2` |
| `just rebuild-vm` | `just rebuild-qcow2` |

## Parameters

### VM Image Commands

```bash
just build-qcow2 [target_image] [tag]
just build-raw [target_image] [tag]
```

| Parameter | Default | Description |
|-----------|---------|-------------|
| `target_image` | `localhost/bazzite-ai` | Source container image |
| `tag` | `43` | Image tag |

### ISO Commands

```bash
just build-iso [target_image] [tag]
just build-iso-nvidia [target_image] [tag]
```

| Parameter | Default | Description |
|-----------|---------|-------------|
| `target_image` | `localhost/bazzite-ai` | Source container image |
| `tag` | `43` | Image tag |

### Cloud-Init Seed

```bash
just create-cloud-seed [output_dir] [hostname] [autologin]
```

| Parameter | Default | Description |
|-----------|---------|-------------|
| `output_dir` | `./output` | Output directory |
| `hostname` | `bazzite-ai-vm` | VM hostname |
| `autologin` | `true` | Enable autologin |

## Build Tools

| Tool | Purpose | Output |
|------|---------|--------|
| **bootc-image-builder** | QCOW2/RAW VM images | `output/qcow2/` or `output/raw/` |
| **Titanoboa** | Live ISO with desktop | `output/bootiso/` |

## Output Locations

| Image Type | Location |
|------------|----------|
| QCOW2 | `output/qcow2/` |
| RAW | `output/raw/` |
| ISO | `output/bootiso/bazzite-ai-*.iso` |
| Cloud-init | `output/seed.iso` |

## Common Workflows

### Create VM Image

```bash
# 1. Build OS image first
just build

# 2. Create QCOW2
just build-qcow2

# 3. Create cloud-init seed
just create-cloud-seed

# 4. Launch with QEMU
qemu-system-x86_64 -enable-kvm -m 8G -cpu host \
  -drive file=output/qcow2/disk.qcow2,format=qcow2 \
  -cdrom output/seed.iso
```

### Create Live ISO

```bash
# 1. Build OS image
just build

# 2. Create standard ISO
just build-iso

# 3. Or create NVIDIA variant
just build-iso-nvidia

# 4. Write to USB
sudo dd if=output/bootiso/bazzite-ai-43.iso of=/dev/sdX bs=4M status=progress
```

### One-Step Rebuild

```bash
# Build OS + create QCOW2 in one step
just rebuild-qcow2

# Build OS + create all ISOs
just rebuild-iso-all
```

## ISO Variants

| Variant | Filename | Description |
|---------|----------|-------------|
| Standard | `bazzite-ai-<tag>.iso` | Default ISO |
| NVIDIA | `bazzite-ai-nvidia-<tag>.iso` | NVIDIA drivers included |

## Cloud-Init Configuration

The `create-cloud-seed` command generates:

**user-data:**

```yaml
#cloud-config
ssh_authorized_keys:
  - <your SSH public key>
runcmd:
  - /usr/libexec/bazzite-ai/cloud-init-autologin  # if autologin=true
```

**meta-data:**

```yaml
instance-id: <hostname>-<timestamp>
local-hostname: <hostname>
```

## Requirements

- Podman installed
- Root access (uses sudo internally)
- OS image already built (`just build`)
- Sufficient disk space (~20GB for ISO)
- `cloud-localds` for seed ISO

## Troubleshooting

### Build Fails with Image Not Found

**Symptom:** Cannot find source image

**Cause:** OS image not built or wrong tag

**Fix:**

```bash
# Build OS image first
just build

# Then build VM
just build-qcow2
```

### Permission Denied

**Symptom:** Cannot access output directory

**Cause:** Previous build left root-owned files

**Fix:**

```bash
# Fix permissions
sudo chown -R $USER:$USER output/

# Or clean and rebuild
just clean output
just rebuild-qcow2
```

### ISO Build Fails with Titanoboa

**Symptom:** Titanoboa container fails

**Cause:** Missing hooks or flatpak list

**Fix:**

```bash
# Verify hook scripts exist
ls installer/titanoboa_hook_*.sh

# Verify flatpak list exists
ls installer/kde_flatpaks/flatpaks
```

### No SSH Key Found

**Symptom:** create-cloud-seed fails

**Cause:** No SSH public key in ~/.ssh/

**Fix:**

```bash
# Generate SSH key
ssh-keygen -t ed25519

# Then create seed
just create-cloud-seed
```

## Cross-References

- **Related Skills:** `build` (OS image), `clean` (cleanup output)
- **System Command:** `ujust vm` (run VMs), `ujust bootc` (bootc VMs)
- **Configuration:** `image.toml` (bootc-image-builder config)

## When to Use This Skill

Use when the user asks about:

- "build vm", "build qcow2", "build raw image"
- "build iso", "build live iso", "titanoboa"
- "create installer", "bootable usb"
- "cloud-init", "seed iso", "ssh key"
- "just build-qcow2", "just build-iso"
