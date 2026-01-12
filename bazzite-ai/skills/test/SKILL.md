---
name: test
description: |
  Runtime verification tests for bazzite-ai installation. Tests GPU detection,
  CUDA, PyTorch, service health, network connectivity, and pod lifecycles.
  Use when users need to verify their bazzite-ai installation works correctly.
---

# Test - Runtime Verification

## Overview

The `test` command provides comprehensive runtime verification for bazzite-ai installations. It tests GPU detection, CUDA/PyTorch functionality, service health, network connectivity, and pod container lifecycles.

**Key Concept:** Tests run on the LOCAL system to verify actual functionality, not just syntax.

## Quick Reference

| Action | Command | Description |
|--------|---------|-------------|
| Quick test | `ujust test quick` | GPU + service status (~30s) |
| GPU test | `ujust test gpu` | GPU detection and CDI check |
| CUDA test | `ujust test cuda` | CUDA tests in nvidia container |
| PyTorch test | `ujust test pytorch` | PyTorch GPU access test |
| All tests | `ujust test all` | Full test suite (~2min) |
| Help | `ujust test help` | Show all options |

## Parameters

### ACTION Parameter

```bash
ujust test ACTION=""
```

| Parameter | Values | Description |
|-----------|--------|-------------|
| `ACTION` | See actions below | Test to run |

Without `ACTION`, shows interactive menu (requires TTY).

### Test Options

```bash
ujust test [ACTION] [--instance=N] [--image=IMAGE] [--cpus=N] [--ram=MB] [--ssh-port=PORT]
```

| Parameter | Default | Description |
|-----------|---------|-------------|
| `--instance, -n` | `90` | Pod instance number for test pods |
| `--image, -i` | (default) | Container image for bootc testing |
| `--cpus` | `4` | CPUs for bootc VM |
| `--ram` | `8192` | RAM in MB for bootc VM |
| `--ssh-port` | `2222` | SSH port for bootc VM |

## Available Tests

### Quick Tests

```bash
ujust test quick      # GPU + service status (~30s)
ujust test status     # Test status summary
```

### GPU Tests

```bash
ujust test gpu        # GPU detection and CDI check
ujust test cuda       # CUDA tests in nvidia container
ujust test pytorch    # PyTorch GPU access test
```

### Service Tests

```bash
ujust test ollama     # Ollama health + quick inference
ujust test jupyter    # Jupyter service health
ujust test comfyui    # ComfyUI service health
ujust test openwebui  # Open WebUI service health
ujust test services   # All installed services status
```

### Infrastructure Tests

```bash
ujust test config     # Configuration dispatcher test
ujust test network    # Registry connectivity test
ujust test apptainer  # Apptainer GPU detection
```

### VM Tests

```bash
ujust test bootc                    # Ephemeral bootc VM (auto-cleanup)
ujust test bootc --image=stable     # Test specific image
```

### Pod Lifecycle Tests

```bash
ujust test pods config --instance=91   # Configure test pods
ujust test pods start --instance=91    # Start test pods
ujust test pods status --instance=91   # Check test pods status
ujust test pods stop --instance=91     # Stop test pods
ujust test pods delete --instance=91   # Delete test pod configs
ujust test pods all --instance=91      # Full lifecycle test
```

## Common Workflows

### Verify New Installation

```bash
# Quick verification
ujust test quick

# If issues found, run full suite
ujust test all
```

### Verify GPU Support

```bash
# Check GPU detection
ujust test gpu

# Test CUDA if NVIDIA
ujust test cuda

# Test PyTorch GPU access
ujust test pytorch
```

### Verify Services

```bash
# Test all services
ujust test services

# Or individual services
ujust test ollama
ujust test jupyter
```

### Test Pod Lifecycle

```bash
# Full lifecycle test with isolated instance
ujust test pods all --instance=91
```

## Non-Interactive Usage

All tests work without TTY:

```bash
# CI/automation-friendly
ujust test quick
ujust test gpu
ujust test all
```

## Troubleshooting

### GPU Not Detected

**Symptom:** `ujust test gpu` shows no GPU

**Cause:** GPU drivers not loaded or CDI not configured

**Fix:**

```bash
# Check NVIDIA driver
nvidia-smi

# Check CDI
ls /etc/cdi/

# Setup GPU container support
ujust config gpu setup
```

### CUDA Test Fails

**Symptom:** `ujust test cuda` fails

**Cause:** NVIDIA container toolkit not configured

**Fix:**

```bash
ujust config gpu setup
# May require reboot
```

### Service Test Fails

**Symptom:** Service test shows unhealthy

**Cause:** Service not running or misconfigured

**Fix:**

```bash
# Check specific service
ujust <service> status

# View logs
ujust <service> logs

# Restart service
ujust <service> restart
```

## Cross-References

- **GPU Setup:** `config` skill (ujust config gpu setup)
- **Service Management:** Individual service skills (ollama, jupyter, etc.)
- **Pod Management:** `pods` skill for aggregate operations

## When to Use This Skill

Use when the user asks about:

- "verify installation", "test bazzite-ai", "check if working"
- "GPU test", "CUDA test", "PyTorch test"
- "service health", "check services"
- "network connectivity", "registry access"
- "test pods", "lifecycle test"
