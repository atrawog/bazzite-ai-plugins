---
name: vm
description: |
  QCOW2 virtual machine management using libvirt. Creates VMs from pre-built
  images downloaded from R2 CDN with cloud-init customization. Supports SSH,
  VNC, and virtiofs home directory sharing. Use when users need to create,
  manage, or connect to bazzite-ai VMs.
---

# VM - QCOW2 Virtual Machine Management

## Overview

The `vm` command manages bazzite-ai virtual machines using libvirt. VMs are created from pre-built QCOW2 images downloaded from R2 CDN, customized via cloud-init.

**Key Concept:** VMs run in user session (qemu:///session), not requiring root. Home directory is shared via virtiofs at `/workspace` in the VM.

## Quick Reference

| Action | Command | Description |
|--------|---------|-------------|
| Add VM | `ujust vm add [NAME] [PARAMS...]` | Download + create VM |
| Update VM | `ujust vm update [NAME] [WHAT=...]` | Update VM config |
| Delete VM | `ujust vm delete [NAME]` | Remove VM |
| Download | `ujust vm download [BRANCH]` | Download QCOW2 image |
| Seed | `ujust vm seed [NAME] [PARAMS...]` | Create cloud-init ISO |
| Create | `ujust vm create [NAME] [PARAMS...]` | Create VM from image |
| Start | `ujust vm start [NAME]` | Start VM |
| Stop | `ujust vm stop [NAME]` | Stop VM |
| SSH | `ujust vm ssh [NAME]` | SSH to VM |
| VNC | `ujust vm vnc [NAME]` | Open VNC viewer |
| Status | `ujust vm status [NAME]` | Show VM status |
| Help | `ujust vm help` | Show help |

## Parameters

### Command Pattern

```bash
ujust vm ACTION VM_NAME PARAM1=value PARAM2=value...

```

| Parameter | Default | Description |
|-----------|---------|-------------|
| `URL` | R2 CDN URL | QCOW2 image URL |
| `CPUS` | `4` | Number of CPUs |
| `RAM` | `8192` | Memory in MB |
| `DISK_SIZE` | `100G` | Disk size |
| `USERNAME` | `$USER` | VM username |
| `PASSWORD` | (empty) | VM password |
| `AUTOLOGIN` | `true` | Enable autologin |
| `SSH_PORT` | `4444` | SSH port forwarding |
| `VNC_PORT` | `5900` | VNC port |
| `SHARE_DIR` | `$HOME` | Directory to share |
| `BRANCH` | `stable` | Image branch (stable/testing) |

## Add VM (Full Workflow)

```bash
# Default: bazzite-ai VM with auto-detect settings
ujust vm add

# Named VM with custom config
ujust vm add myvm CPUS=8 RAM=16384 DISK_SIZE=200G

# Testing branch image
ujust vm add testing-vm BRANCH=testing

# Different SSH port
ujust vm add dev-vm SSH_PORT=4445

# No home sharing
ujust vm add isolated SHARE_DIR=''

```

The `add` command:

1. Downloads QCOW2 image (cached)
2. Creates cloud-init seed ISO
3. Creates libvirt VM
4. Configures port forwarding

## Individual Steps

### Download QCOW2

```bash
# Stable image
ujust vm download

# Testing branch
ujust vm download testing

# Custom URL
ujust vm download URL=[https://example.com/custom.qcow2]([https://example.com/custom.qcow2](https://example.com/custom.qcow2))
```

### Create Seed ISO

```bash
ujust vm seed myvm USERNAME=developer PASSWORD=secret

```

### Create VM

```bash
ujust vm create myvm CPUS=4 RAM=8192

```

## VM Lifecycle

### Start VM

```bash
ujust vm start              # Default VM
ujust vm start myvm         # Named VM

```

Auto-adds VM if it doesn't exist.

### Stop VM

```bash
ujust vm stop              # Graceful shutdown
ujust vm stop myvm FORCE=yes  # Force stop

```

### Delete VM

```bash
ujust vm delete myvm        # Remove VM and disk

```

## Connecting to VM

### SSH Connection

```bash
# Connect to VM
ujust vm ssh

# Named VM
ujust vm ssh myvm

# Different user
ujust vm ssh myvm SSH_USER=root

# Run command
ujust vm ssh myvm -- ls -la

```

Default SSH: `ssh -p 4444 localhost`

### VNC Connection

```bash
ujust vm vnc              # Opens VNC viewer
ujust vm vnc myvm

```

Default VNC: Port 5900

## Home Directory Sharing

By default, your home directory is shared to the VM at `/workspace` via virtiofs.

```bash
# Default: $HOME -> /workspace
ujust vm add

# Disable sharing
ujust vm add isolated SHARE_DIR=''

# Share specific directory
ujust vm add project SHARE_DIR=/path/to/project

```

Inside VM:

```bash
ls /workspace  # Your home directory

```

## Image Branches

| Branch | Tag | Description |
|--------|-----|-------------|
| `stable` | `:stable` | Production, tested |
| `testing` | `:testing` | Latest features |

```bash
ujust vm download stable
ujust vm download testing

```

## Storage Locations

| Item | Location |
|------|----------|
| Download cache | `~/.local/share/bazzite-ai/vm/cache/` |
| VM disks | `~/.local/share/libvirt/images/` |
| VM config | `~/.local/share/bazzite-ai/vm/<name>.conf` |
| Seed ISO | `~/.local/share/bazzite-ai/vm/<name>-seed.iso` |

## Common Workflows

### Quick Test VM

```bash
# Add and start default VM
ujust vm add
ujust vm start
ujust vm ssh

```

### Development Environment

```bash
# Create dev VM with more resources
ujust vm add dev CPUS=8 RAM=16384 DISK_SIZE=200G

# Start it
ujust vm start dev

# SSH in
ujust vm ssh dev

# Your home is at /workspace

```

### Testing Branch

```bash
# Test latest features
ujust vm add testing-vm BRANCH=testing
ujust vm start testing-vm
ujust vm ssh testing-vm

```

### Multiple VMs

```bash
# Create VMs on different ports
ujust vm add dev1 SSH_PORT=4444
ujust vm add dev2 SSH_PORT=4445
ujust vm add dev3 SSH_PORT=4446

# Start all (not a built-in command, use loop)
for vm in dev1 dev2 dev3; do ujust vm start $vm; done

```

## Troubleshooting

### VM Won't Start

**Check:**

```bash
ujust vm status myvm
virsh --connect qemu:///session list --all

```

**Common causes:**

- Disk image not found

- Port conflict

- Virtiofs path issue

**Fix:**

```bash
ujust vm delete myvm
ujust vm add myvm

```

### SSH Connection Refused

**Check:**

```bash
ssh -p 4444 localhost

```

**Common causes:**

- VM not fully booted

- Wrong SSH port

- SSH not started in VM

**Fix:**

```bash
# Wait longer after start
sleep 30
ujust vm ssh myvm

# Check VM console via VNC
ujust vm vnc myvm

```

### Virtiofs Not Working

**Symptom:** `/workspace` empty or not mounted

**Cause:** SHARE_DIR path issue (symlinks)

**Fix:**

```bash
# Delete and recreate with canonical path
ujust vm delete myvm
ujust vm add myvm SHARE_DIR=$(readlink -f $HOME)

```

### Out of Disk Space

**Check:**

```bash
qemu-img info ~/.local/share/libvirt/images/myvm.qcow2

```

**Fix:**

```bash
# Create new VM with larger disk
ujust vm delete myvm
ujust vm add myvm DISK_SIZE=200G

```

## Cross-References

- **Related Skills:** `bootc` (alternative: bootc-based VMs)

- **Prerequisites:** `ujust configure libvirtd enable`

- **bcvk alternative:** `ujust install bcvk` + `ujust bootc`

## When to Use This Skill

Use when the user asks about:

- "create VM", "add VM", "start VM"

- "ssh to VM", "connect to VM"

- "download qcow2", "VM image"

- "VM not starting", "VM connection failed"

- "share directory with VM", "virtiofs"
