---
name: test
description: |
  Runtime verification tests for bazzite-ai installations. Validates GPU access,
  CUDA/PyTorch, service health, pod lifecycles, k3d clusters, and network connectivity.
  Run with 'ujust test' on installed systems. Use when developers need to verify
  their bazzite-ai installation is working correctly.
---

# Test - Runtime Verification

## Overview

The `test` command provides runtime verification tests for bazzite-ai installations. It validates that GPU access, services, containers, and network connectivity are working correctly.

**Key Concept:** These are runtime tests that run on an installed bazzite-ai system using `ujust test`. For development overlay management, see the `/bazzite-ai-dev:overlay` skill.

## Quick Reference

### Quick Tests

| Action | Command | Description |
|--------|---------|-------------|
| Quick | `ujust test quick` | GPU + service status (~30s) |
| All | `ujust test all` | Full test suite (~2min) |
| Info | `ujust test info` | Show system information |

### Individual Tests

| Action | Command | Description |
|--------|---------|-------------|
| GPU | `ujust test gpu` | GPU detection and CDI check |
| CUDA | `ujust test cuda` | CUDA tests in nvidia container |
| PyTorch | `ujust test pytorch` | PyTorch tests in jupyter container |
| Ollama | `ujust test ollama` | Ollama health + quick inference |
| Jupyter | `ujust test jupyter` | Jupyter service health |
| ComfyUI | `ujust test comfyui` | ComfyUI service health |
| OpenWebUI | `ujust test openwebui` | Open WebUI service health |
| Services | `ujust test services` | All installed services status |
| Config | `ujust test config` | Config validation |
| Network | `ujust test network` | Registry connectivity |

### Pod Testing (default INSTANCE=90)

| Action | Command | Description |
|--------|---------|-------------|
| Config | `ujust test pods config` | Configure all test pods |
| Start | `ujust test pods start` | Start all test pods |
| Status | `ujust test pods status` | Check test pod status |
| Stop | `ujust test pods stop` | Stop all test pods |
| Delete | `ujust test pods delete` | Delete test pod configs |
| All | `ujust test pods all` | Full lifecycle test |

### K3d Cluster Testing (default INSTANCE=90)

| Action | Command | Description |
|--------|---------|-------------|
| Config | `ujust test k3d config` | Create k3d cluster |
| Start | `ujust test k3d start` | Start k3d cluster |
| Status | `ujust test k3d status` | Check cluster health |
| GPU | `ujust test k3d gpu` | Setup NVIDIA GPU support |
| Network | `ujust test k3d network` | Test K8s → bazzite-ai network |
| Ollama | `ujust test k3d ollama` | Test ollama from k8s |
| Stop | `ujust test k3d stop` | Stop k3d cluster |
| Delete | `ujust test k3d delete` | Delete k3d cluster |
| All | `ujust test k3d all` | Full k3d lifecycle |

### Portainer + K3d Testing (default INSTANCE=91)

| Action | Command | Description |
|--------|---------|-------------|
| Config | `ujust test portainer config` | Configure k3d + Portainer |
| Start | `ujust test portainer start` | Start both services |
| Status | `ujust test portainer status` | Check both services |
| Health | `ujust test portainer health` | Test Portainer HTTPS API |
| K3d | `ujust test portainer k3d` | Test Portainer sees k3d |
| Stop | `ujust test portainer stop` | Stop both services |
| Delete | `ujust test portainer delete` | Delete both configs |
| All | `ujust test portainer all` | Full Portainer + k3d lifecycle |

### VM & Install Testing

| Action | Command | Description |
|--------|---------|-------------|
| VM | `ujust test vm` | VM testing menu |
| VM Add | `ujust test vm add` | Add test VM |
| VM Start | `ujust test vm start` | Start test VM |
| Install | `ujust test install` | Install command testing |
| Install All | `ujust test install all` | Test all install commands |

## Parameters

```bash
ujust test ACTION [SUBACTION] [OPTIONS...]
```

| Parameter | Values | Description |
|-----------|--------|-------------|
| `ACTION` | See quick reference | Test category |
| `SUBACTION` | Varies by action | Specific test within category |
| `INSTANCE` | Number | Instance number for isolated testing (default: 90) |

## Quick Tests

### Quick Test (~30s)

```bash
ujust test quick
```

Runs essential checks:

1. GPU detection
2. CDI configuration
3. Running services status

**Use when:** Quick sanity check after installation or reboot.

### Full Test Suite (~2min)

```bash
ujust test all
```

Runs comprehensive tests:

1. GPU and CUDA validation
2. PyTorch in container
3. All service health checks
4. Network connectivity

**Use when:** Full validation after major changes.

## GPU Testing

### GPU Detection

```bash
ujust test gpu
```

Checks:

- GPU vendor detection (NVIDIA, AMD, Intel)
- Driver loaded
- CDI configuration present

### CUDA Test

```bash
ujust test cuda
```

Runs CUDA tests inside nvidia container:

- nvidia-smi output
- CUDA version
- GPU memory info

### PyTorch Test

```bash
ujust test pytorch
```

Runs PyTorch GPU tests inside jupyter container:

- torch.cuda.is_available()
- GPU tensor operations
- Memory allocation

## Pod Lifecycle Testing

Test pods use isolated instances (default: 90) to avoid interfering with user configurations.

### Full Pod Lifecycle

```bash
ujust test pods all
```

Runs complete lifecycle:

1. **config** - Configure test pods
2. **start** - Start all pods
3. **status** - Verify running
4. **stop** - Stop all pods
5. **delete** - Clean up configs

### Custom Instance

```bash
# Use different instance number
ujust test pods all INSTANCE=50
```

## K3d Cluster Testing

Tests k3d Kubernetes cluster functionality.

### Full K3d Lifecycle

```bash
ujust test k3d all
```

Tests:

1. Cluster creation on bazzite-ai network
2. Node health
3. GPU support (if NVIDIA)
4. Network connectivity to other pods
5. Ollama inference from k8s
6. Cleanup

### Network Connectivity

```bash
ujust test k3d network
```

Verifies k8s pods can reach bazzite-ai network services (ollama, jupyter, etc.)

## Common Workflows

### After Installation

```bash
# Quick sanity check
ujust test quick

# If issues, run full suite
ujust test all
```

### GPU Troubleshooting

```bash
# Check GPU detection
ujust test gpu

# Test CUDA
ujust test cuda

# Test PyTorch
ujust test pytorch
```

### Service Validation

```bash
# Check all services
ujust test services

# Individual service
ujust test ollama
ujust test jupyter
```

### Before Development

```bash
# Full validation
ujust test all

# Enable overlay mode for development
just overlay refresh
```

## Troubleshooting

### GPU Test Fails

**Symptom:** `ujust test gpu` reports no GPU

**Check:**

```bash
# Host GPU
nvidia-smi  # or lspci | grep -i vga

# CDI configuration
ls /etc/cdi/
```

**Fix:**

```bash
# Regenerate CDI
ujust config gpu setup
```

### CUDA Test Fails

**Symptom:** CUDA not available in container

**Cause:** CDI not configured or driver mismatch

**Fix:**

```bash
# Rebuild CDI spec
sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
```

### Service Test Fails

**Symptom:** Service reports unhealthy

**Check:**

```bash
# Service status
systemctl --user status <service>

# Logs
journalctl --user -u <service> -n 50
```

### Pod Test Cleanup Failed

**Symptom:** Test pods still exist after failure

**Fix:**

```bash
# Manual cleanup
ujust test pods delete INSTANCE=90
```

## Cross-References

- **Overlay Development:** `/bazzite-ai-dev:overlay` skill for development mode
- **GPU Setup:** `ujust config gpu setup` for GPU configuration
- **Services:** Individual service skills for detailed management

## When to Use This Skill

Use when the user asks about:

- "test installation", "verify bazzite-ai"
- "test gpu", "test cuda", "test pytorch"
- "test services", "service health"
- "ujust test" (any test command)
- "test pods", "test k3d", "lifecycle test"
