---
name: gpu
description: |
  GPU driver configuration for Bazzite. NVIDIA proprietary drivers, Optimus laptops,
  NVK (open-source NVIDIA), GPU switching, Broadcom WiFi, and Mesa testing builds.
  Use when users need to configure graphics drivers.
---

# GPU - Bazzite GPU Configuration

## Overview

Bazzite supports NVIDIA, AMD, and Intel GPUs. This skill covers NVIDIA driver configuration, Optimus laptops, GPU switching, and related drivers.

## Quick Reference

| Command | Description |
|---------|-------------|
| `ujust config-nvidia` | Configure NVIDIA drivers |
| `ujust nvidia` | Alias for configure-nvidia |
| `ujust toggle-nvk` | Switch between NVIDIA/NVK images |
| `ujust config-nvidia-optimus` | Configure Optimus power management |
| `ujust config-broadcom-wl` | Enable/disable Broadcom WiFi driver |
| `ujust enable-supergfxctl` | Enable GPU switcher for hybrid laptops |
| `ujust _mesa-git` | Mesa testing builds |

## NVIDIA Configuration

### Configure NVIDIA

```bash
# Interactive NVIDIA configuration
ujust config-nvidia

# Same command
ujust nvidia
```

**Options:**
- `kargs` - Set kernel arguments
- `test-cuda` - Test CUDA functionality
- `firefox-vaapi` - Enable Firefox hardware acceleration

### Kernel Arguments

```bash
ujust config-nvidia kargs
```

Sets recommended kernel parameters for NVIDIA:
- `nvidia_drm.modeset=1`
- `nvidia_drm.fbdev=1`

### Test CUDA

```bash
ujust config-nvidia test-cuda
```

Runs CUDA sample to verify GPU compute.

### Firefox VA-API

```bash
ujust config-nvidia firefox-vaapi
```

Enables hardware video acceleration in Firefox.

## NVK (Open-Source)

### Toggle NVK

```bash
# Switch between NVIDIA proprietary and NVK
ujust toggle-nvk
```

**NVK:**
- Mesa's open-source Vulkan driver for NVIDIA
- Requires newer GPUs (Turing+)
- Part of nvidia-open images

**NVIDIA:**
- Proprietary drivers
- CUDA support
- Better compatibility for older GPUs

**Reboot required after switching.**

## Optimus Laptops

### Configure Optimus

```bash
# Configure NVIDIA Optimus power management
ujust config-nvidia-optimus
```

**Options:**
- `power-management` - Power state management

### Enable GPU Switcher

```bash
# Enable supergfxctl for GPU switching
ujust enable-supergfxctl
```

**supergfxctl** allows:
- Switching between iGPU and dGPU
- Power management modes
- Profile selection

**Modes:**
- Integrated - Intel/AMD iGPU only (power saving)
- Hybrid - Both GPUs, NVIDIA on-demand
- Dedicated - NVIDIA only (performance)

## Broadcom WiFi

### Configure Broadcom

```bash
# Enable/disable Broadcom WL driver
ujust config-broadcom-wl
```

Required for certain Broadcom wireless chips that don't work with open-source drivers.

**Options:**
- `enable` - Enable Broadcom WL driver
- `disable` - Disable and use open-source

## Mesa Testing

### Mesa Git Builds

```bash
# Manage Mesa Git builds
ujust _mesa-git
```

**Options:**
- Download latest Mesa Git
- Install for testing
- Cleanup old builds

**Warning:** For testing only. May cause instability.

## Common Workflows

### Fresh NVIDIA Setup

```bash
# Configure kernel args
ujust config-nvidia kargs

# Reboot
systemctl reboot

# Test CUDA
ujust config-nvidia test-cuda

# Enable Firefox HW accel
ujust config-nvidia firefox-vaapi
```

### Laptop Power Saving

```bash
# Enable GPU switcher
ujust enable-supergfxctl

# Use supergfxctl to select mode
supergfxctl -m integrated
```

### Try NVK Driver

```bash
# Switch to NVK
ujust toggle-nvk

# Reboot
systemctl reboot

# Verify
vulkaninfo | grep driverName
```

## Verification

### Check NVIDIA Driver

```bash
# Driver version
nvidia-smi

# Module loaded
lsmod | grep nvidia

# Vulkan info
vulkaninfo | head -20
```

### Check GPU in Use

```bash
# Current GPU
glxinfo | grep "OpenGL renderer"

# For Vulkan
vulkaninfo | grep deviceName
```

### Check Power Mode

```bash
# With supergfxctl
supergfxctl -g

# NVIDIA power state
cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status
```

## Troubleshooting

### NVIDIA Driver Not Loading

**Check secure boot:**

```bash
# If secure boot enabled, enroll key
ujust enroll-secure-boot-key
```

**Check kernel args:**

```bash
rpm-ostree kargs
```

**Reinstall:**

```bash
ujust config-nvidia kargs
systemctl reboot
```

### Black Screen After NVK Switch

**Boot to previous deployment:**
1. At GRUB, select previous boot entry
2. Once booted:

```bash
ujust toggle-nvk
systemctl reboot
```

### Optimus Not Switching

**Check supergfxctl:**

```bash
systemctl status supergfxd
supergfxctl -g
```

**Manual switch:**

```bash
supergfxctl -m <mode>
# hybrid, integrated, or dedicated
```

### CUDA Not Working

**Check installation:**

```bash
nvidia-smi
ujust config-nvidia test-cuda
```

**Reinstall CUDA toolkit if needed.**

## Cross-References

- **bazzite:boot** - Secure boot key enrollment
- **bazzite:gaming** - Gaming performance
- **bazzite-ai:configure** - GPU containers

## When to Use This Skill

Use when the user asks about:
- "NVIDIA driver", "configure nvidia", "nvidia setup"
- "NVK", "nouveau", "open source nvidia"
- "Optimus", "laptop GPU", "hybrid graphics"
- "GPU switching", "supergfxctl", "dedicated GPU"
- "Broadcom WiFi", "wireless driver"
- "CUDA not working", "nvidia-smi", "GPU compute"
- "Firefox video", "hardware acceleration", "VA-API"
