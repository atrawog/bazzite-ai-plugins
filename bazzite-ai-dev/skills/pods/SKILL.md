---
name: pods
description: |
  Development: Pod container variant building and testing. Builds GPU-enabled
  development containers (base, nvidia, jupyter, ollama, devops, githubrunner).
  Run from repository root with 'just build-pod'. Use when developers need to
  build or test container pods locally.
---

# Pods - Pod Container Building

## Overview

The `pods` development commands build and test bazzite-ai pod container variants. Each variant provides a specialized development environment with GPU support, ML frameworks, or DevOps tools.

**Key Concept:** This is a **development command** - run with `just` from the repository root, not `ujust`. Built pods are used by system commands like `ujust jupyter` and `ujust ollama`.

## Quick Reference

| Action | Command | Description |
|--------|---------|-------------|
| Build variant | `just build-pod nvidia` | Build specific variant |
| Build interactive | `just build-pod` | Interactive variant selection |
| Rebuild all | `just rebuild-pod` | Rebuild all variants |
| Test CUDA | `just test-cuda-pod` | Test NVIDIA GPU access |
| Test DevOps | `just test-devops-pod` | Test DevOps tools |
| Test Runner | `just test-githubrunner-pod` | Test GitHub runner |
| Build all | `just build-pods-all` | Build all variants |
| Test all | `just test-pods-all` | Test all variants |
| Full workflow | `just build-and-test-pods` | Build + test all |
| Generate lock | `just generate-pixi-lock python` | Generate pixi.lock |

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

## Parameters

### build-pod

```bash
just build-pod [variant] [tag]
```

| Parameter | Default | Description |
|-----------|---------|-------------|
| `variant` | (interactive) | Pod variant to build |
| `tag` | `43` | Image tag |

### test-*-pod

```bash
just test-cuda-pod [tag]
just test-devops-pod [tag]
just test-githubrunner-pod [tag]
```

| Parameter | Default | Description |
|-----------|---------|-------------|
| `tag` | `43` | Image tag to test |

## Build Commands

### Single Variant

```bash
# Interactive selection
just build-pod

# Specific variant
just build-pod nvidia
just build-pod jupyter testing
```

### All Variants

```bash
# Build all variants
just build-pods-all

# Build all with custom tag
just build-pods-all testing
```

## Test Commands

### CUDA Test

```bash
# Test NVIDIA GPU access
just test-cuda-pod

# Output: nvidia-smi information
```

### DevOps Test

```bash
# Test DevOps tools
just test-devops-pod

# Verifies: aws, kubectl, helm, scw, gh
```

### GitHub Runner Test

```bash
# Test runner installation
just test-githubrunner-pod

# Verifies: run.sh, entrypoint, healthcheck
```

## Common Workflows

### Build and Test Single Variant

```bash
# 1. Build NVIDIA variant
just build-pod nvidia testing

# 2. Test GPU access
just test-cuda-pod testing

# 3. Run interactively
podman run -it --rm \
  --device nvidia.com/gpu=all \
  bazzite-ai-pod-nvidia:testing bash
```

### Full Build Pipeline

```bash
# Build and test all variants
just build-and-test-pods testing

# This runs:
# 1. build-pods-all
# 2. test-pods-all
```

### Generate Pixi Lock Files

```bash
# Generate lock for python variant
just generate-pixi-lock python

# Generate lock for jupyter variant
just generate-pixi-lock jupyter

# Generate all locks
just generate-pixi-locks
```

## Pod Inheritance

```
base (CPU-only)
├── nvidia (CUDA)
│   ├── nvidia-python (PyTorch/ML)
│   │   └── jupyter (JupyterLab)
│   └── ollama (LLM inference)
├── devops (Cloud tools)
└── githubrunner (CI/CD)
```

## Output Images

Images are built with the registry prefix:

```
ghcr.io/atrawog/bazzite-ai-pod-<variant>:<tag>
```

## Troubleshooting

### Build Fails with Base Image Missing

**Symptom:** Cannot find base image

**Cause:** Parent variant not built

**Fix:**

```bash
# Build in order (base → nvidia → jupyter)
just build-pod base
just build-pod nvidia
just build-pod jupyter
```

### CUDA Test Fails

**Symptom:** nvidia-smi not found or GPU not detected

**Cause:** NVIDIA drivers not installed or GPU not passed through

**Fix:**

```bash
# Verify GPU on host
nvidia-smi

# Check CDI configuration
ls /etc/cdi/

# Rebuild with correct NVIDIA support
just build-pod nvidia
```

### Pixi Lock Generation Fails

**Symptom:** generate-pixi-lock script not found

**Cause:** Missing script or wrong directory

**Fix:**

```bash
# Verify script exists
ls scripts/generate-pixi-lock.sh

# Run from repo root
cd /path/to/bazzite-ai
just generate-pixi-lock python
```

## Cross-References

- **Related Skills:** `build` (OS image), `clean` (cleanup build artifacts)
- **System Commands:** `ujust jupyter`, `ujust ollama` (use built pods)
- **Containerfiles:** `pods/*/Containerfile`

## When to Use This Skill

Use when the user asks about:

- "build pod", "build container", "build nvidia pod"
- "test cuda", "test gpu", "test devops pod"
- "pod variants", "jupyter container", "ollama container"
- "just build-pod", "just test-cuda-pod"
- "generate pixi lock", "pixi.lock"
