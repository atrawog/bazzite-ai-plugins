# Bazzite Plugin

Claude Code skills for default Bazzite OS features via ujust commands.

## Overview

This plugin provides skills for the standard Bazzite ujust commands - gaming, system management, hardware configuration, and more. For AI/ML-focused features, see the `bazzite-ai` plugin.

## Skills (12)

| Skill | Description |
|-------|-------------|
| **system** | Updates, cleanup, logs, diagnostics, benchmarks |
| **boot** | BIOS/UEFI, GRUB, secure boot, dual-boot Windows |
| **distrobox** | Container management, DaVinci Resolve |
| **gaming** | Steam, EmuDeck, Decky, Sunshine, frame generation |
| **audio** | Virtual channels, surround sound, Bluetooth, PipeWire |
| **gpu** | NVIDIA drivers, Optimus, NVK, Mesa, Broadcom WiFi |
| **storage** | Automount, deduplication, snapshots |
| **network** | iwd WiFi, Wake-on-LAN, Tailscale |
| **security** | LUKS/TPM unlock, secure boot keys |
| **virtualization** | VFIO, KVM, Looking Glass, USB hotplug |
| **desktop** | GTK themes, terminal transparency |
| **apps** | CoolerControl, OpenRazer, DisplayLink, scrcpy |

## Usage

Invoke skills using the `/bazzite:` prefix:

```bash
/bazzite:gaming    # Gaming ecosystem help
/bazzite:gpu       # GPU driver configuration
/bazzite:system    # System maintenance
```

## Related Plugins

- **bazzite-ai**: AI/ML-focused features (Jupyter, Ollama, ComfyUI, GPU containers)
- **bazzite-ai-dev**: Development tools and enforcement agents

## Quick Reference

### System Maintenance

```bash
ujust update              # Update system
ujust changelogs          # View release notes
ujust clean-system        # Cleanup podman/flatpaks
ujust logs-this-boot      # View current boot logs
```

### Gaming

```bash
ujust setup-sunshine      # Game streaming server
ujust setup-decky         # Decky Loader
ujust install-emudeck     # EmuDeck for emulation
ujust fix-proton-hang     # Kill hung Proton processes
```

### GPU

```bash
ujust configure-nvidia    # NVIDIA driver config
ujust toggle-nvk          # Switch NVIDIA/NVK images
ujust enable-supergfxctl  # GPU switcher for laptops
```

### Audio

```bash
ujust setup-virtual-channels   # Game/Voice/Browser sinks
ujust setup-virtual-surround   # 7.1 for headphones
ujust restart-pipewire         # Restart audio service
```

### Virtualization

```bash
ujust setup-virtualization virt-on    # Enable KVM
ujust setup-virtualization vfio-on    # Enable VFIO
ujust setup-virtualization kvmfr      # Looking Glass setup
```

## License

MIT
