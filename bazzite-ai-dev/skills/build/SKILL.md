---
name: build
description: |
  Development: Unified build system for OS images, pods, VMs, and ISOs.
  Run from repository root with 'just build <subcommand>'. Includes smart
  cache strategy that matches GitHub Actions for optimal build times.
---

# Build - Unified Build System

## Overview

The `build` command provides a unified interface for all bazzite-ai build operations:

- OS container images
- Pod container variants
- VM images (QCOW2/RAW)
- Live ISO installers

**Smart Caching:** Automatically detects git branch and uses matching cache tag, ensuring local builds are compatible with GitHub Actions builds.

## Quick Reference

| Action | Command | Description |
|--------|---------|-------------|
| Build OS | `just build os` | Build OS container image |
| Build pod | `just build pod nvidia` | Build specific pod variant |
| Build all pods | `just build pod all` | Build all pod variants |
| Build ISO | `just build iso` | Build live ISO installer |
| Build QCOW2 | `just build qcow2` | Build QCOW2 VM image |
| Build RAW | `just build raw` | Build RAW VM image |
| Test pod | `just build test cuda` | Test CUDA functionality |
| Test all | `just build test all` | Test all pod variants |
| Generate lock | `just build pixi python` | Generate pixi.lock |
| Show status | `just build status` | Show cache/build status |

## Pod Variants

| Variant | Image Name | Description |
|---------|------------|-------------|
| `base` | `bazzite-ai-pod` | CPU-only development |
| `nvidia` | `bazzite-ai-pod-nvidia` | GPU compute with CUDA |
| `nvidia-python` | `bazzite-ai-pod-nvidia-python` | NVIDIA + ML packages |
| `jupyter` | `bazzite-ai-pod-jupyter` | JupyterLab + ML stack |
| `ollama` | `bazzite-ai-pod-ollama` | LLM inference |
| `devops` | `bazzite-ai-pod-devops` | AWS/kubectl/Helm tools |
| `githubrunner` | `bazzite-ai-pod-githubrunner` | CI/CD pipeline |

## Smart Cache Strategy

The build system automatically detects your git branch and uses the appropriate cache tag to maximize cache reuse between local and CI builds:

| Branch | Cache Tag | Build Tag |
|--------|-----------|-----------|
| `main` | `stable` | `stable` |
| `testing` | `testing` | `testing` |
| Other | `{branch}` | `{branch}` |

This ensures that when you build locally on the `testing` branch, you pull cache layers from the `:testing` images pushed by GitHub Actions.

## Common Workflows

### Build OS Image

```bash
# Build with branch-appropriate tag
just build os

# Build with custom tag
just build os custom-tag
```

### Build Pods

```bash
# Interactive selection
just build pod

# Specific variant
just build pod nvidia

# All variants
just build pod all
```

### Build VM/ISO

```bash
# Build QCOW2 VM image
just build qcow2

# Build live ISO
just build iso

# Build RAW image
just build raw
```

### Test Pods

```bash
# Test CUDA
just build test cuda

# Test DevOps tools
just build test devops

# All tests
just build test all
```

### Generate Pixi Locks

```bash
# Python variant
just build pixi python

# Jupyter variant
just build pixi jupyter

# All variants
just build pixi all
```

## Output Images

Images are tagged with the registry prefix:

```
ghcr.io/atrawog/bazzite-ai:{tag}           # OS image
ghcr.io/atrawog/bazzite-ai-pod:{tag}       # Base pod
ghcr.io/atrawog/bazzite-ai-pod-nvidia:{tag} # NVIDIA pod
```

## Requirements

- Podman installed and configured
- Git repository cloned
- Sufficient disk space (~10GB for OS, ~20GB for ISO)
- Network access (pulls base images)

## Troubleshooting

### Build Fails with Cache Error

**Symptom:** Cache layer not found

**Cause:** Remote image not yet pushed for this branch

**Fix:**

```bash
# Build without cache (first build on new branch)
# Or check status to see cache state
just build status
```

### Pod Build Fails with Base Image Missing

**Symptom:** Cannot find base pod image

**Cause:** Parent variant not built

**Fix:**

```bash
# Build in order (base -> nvidia -> jupyter)
just build pod base
just build pod nvidia
just build pod jupyter
```

### CUDA Test Fails

**Symptom:** nvidia-smi not found

**Cause:** No GPU available or CDI not configured

**Fix:**

```bash
# Verify GPU on host
nvidia-smi

# Check CDI configuration
ls /etc/cdi/
```

## Cross-References

- **Related Skills:** `clean` (cleanup build artifacts), `gh` (registry auth)
- **System Commands:** `ujust jupyter`, `ujust ollama` (use built pods)
- **Documentation:** See `Containerfile` for image layers

## When to Use This Skill

Use when the user asks about:

- "build os", "build image", "build container"
- "build pod", "build nvidia", "build jupyter"
- "build iso", "build qcow2", "build vm"
- "test cuda", "test pod", "test devops"
- "pixi lock", "generate lock"
- "just build" (any build command)
