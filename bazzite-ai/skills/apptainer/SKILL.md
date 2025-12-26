---
name: apptainer
description: |
  Apptainer (Singularity) container management for HPC workloads. Build SIF
  images, run containers with GPU passthrough. Use when users need HPC-compatible
  containerization or need to pull/run Apptainer images.
---

# Apptainer - HPC Container Management

## Overview

The `apptainer` command manages Apptainer (formerly Singularity) containers for HPC-compatible workloads. It provides SIF image management with automatic GPU detection.

**Key Concept:** Apptainer is the HPC standard. Unlike Docker/Podman, containers run as the user (no root). SIF files are single-file images.

## Quick Reference

| Action | Command | Description |
|--------|---------|-------------|
| Pull | `ujust apptainer pull [IMAGE] [TAG]` | Download image to SIF |
| Run | `ujust apptainer run [SIF] [COMMAND]` | Run container |
| Shell | `ujust apptainer shell [SIF]` | Interactive shell |
| Exec | `ujust apptainer exec [SIF] [COMMAND]` | Execute command |
| Build | `ujust apptainer build [DEF] [OUTPUT]` | Build from definition |
| Inspect | `ujust apptainer inspect [SIF]` | Show metadata |
| GPU | `ujust apptainer gpu` | Test GPU support |
| Cache | `ujust apptainer cache [clean\|list]` | Manage cache |
| Help | `ujust apptainer help` | Show help |

## Pull Images

### bazzite-ai Pod Images

```bash
# Pull nvidia-python
ujust apptainer pull nvidia-python

# Pull with tag
ujust apptainer pull nvidia-python testing

# Pull jupyter
ujust apptainer pull jupyter stable

```

### External Images

```bash
# Docker Hub
ujust apptainer pull docker://ubuntu:22.04

# NVIDIA NGC
ujust apptainer pull docker://nvcr.io/nvidia/pytorch:latest

# Sylabs Cloud
ujust apptainer pull library://sylabsed/examples/lolcow

```

### Pull Output

Images are saved as SIF files:

```

~/.local/share/apptainer/bazzite-ai-pod-nvidia-python.sif

```

## Run Containers

### Run with Default Command

```bash
# Run nvidia-python
ujust apptainer run nvidia-python

# Run specific SIF
ujust apptainer run ./my-container.sif

```

### Run with Command

```bash
# Run Python in container
ujust apptainer run nvidia-python python

# Run script
ujust apptainer run nvidia-python python script.py

```

### GPU Auto-Detection

GPU flags are auto-detected:

- NVIDIA: Adds `--nv`

- AMD: Adds `--rocm`

```bash
# GPU is automatically enabled
ujust apptainer run nvidia-python python -c "import torch; print(torch.cuda.is_available())"

```

## Interactive Shell

```bash
# Shell into container
ujust apptainer shell nvidia-python

# Now inside container
python --version
nvidia-smi
exit

```

## Execute Commands

```bash
# Execute single command
ujust apptainer exec nvidia-python "pip list"

# Execute Python one-liner
ujust apptainer exec nvidia-python "python -c 'print(1+1)'"

```

## Build from Definition

### Definition File Example

```def
Bootstrap: docker
From: ubuntu:22.04

%post
    apt-get update
    apt-get install -y python3 python3-pip

%runscript
    python3 "$@"

```

### Build

```bash
# Build SIF from definition
ujust apptainer build mydef.def myimage.sif

# Build to default location
ujust apptainer build mydef.def

```

## GPU Support

### Test GPU

```bash
# Detect and test GPU
ujust apptainer gpu

```

### GPU Flags

| GPU | Flag | Auto-Detection |
|-----|------|----------------|
| NVIDIA | `--nv` | Yes |
| AMD | `--rocm` | Yes |
| Intel | (none yet) | No |

### Manual GPU Override

```bash
# Direct apptainer command with GPU
apptainer run --nv nvidia-python.sif nvidia-smi

```

## Cache Management

### List Cache

```bash
ujust apptainer cache list

```

### Clean Cache

```bash
ujust apptainer cache clean

```

Cache is stored in `~/.apptainer/cache/`.

## Common Workflows

### HPC Development

```bash
# Pull HPC-ready image
ujust apptainer pull nvidia-python

# Test GPU
ujust apptainer gpu

# Development shell
ujust apptainer shell nvidia-python

# Run production workload
ujust apptainer run nvidia-python python train.py

```

### Use NGC Images

```bash
# Pull NVIDIA PyTorch
ujust apptainer pull docker://nvcr.io/nvidia/pytorch:23.10-py3

# Run training
ujust apptainer run pytorch_23.10-py3.sif python train.py

```

### Build Custom Image

```bash
# Create definition file
cat > myenv.def << 'EOF'
Bootstrap: docker
From: python:3.11

%post
    pip install numpy pandas scikit-learn

%runscript
    python "$@"
EOF

# Build
ujust apptainer build myenv.def myenv.sif

# Test
ujust apptainer run myenv.sif python -c "import numpy; print(numpy.__version__)"

```

## Apptainer vs Docker/Podman

| Feature | Apptainer | Docker/Podman |
|---------|-----------|---------------|
| Root required | No | Sometimes |
| Single file | Yes (SIF) | No (layers) |
| HPC compatible | Yes | Limited |
| GPU support | --nv, --rocm | nvidia-docker |
| Security model | User namespace | Container namespace |

**Use Apptainer when:**

- Running on HPC clusters

- Need single-file portability

- Can't run as root

- Need reproducibility

## Troubleshooting

### Pull Failed

**Check:**

```bash
# Test network
curl -I [https://ghcr.io]([https://ghcr.io](https://ghcr.io))
# Check registry auth
apptainer remote list

```

**Fix:**

```bash
# Login to registry
apptainer remote login docker://ghcr.io

```

### GPU Not Available

**Check:**

```bash
ujust apptainer gpu
nvidia-smi  # or rocm-smi

```

**Fix:**

```bash
# Ensure drivers installed
# For NVIDIA:
nvidia-smi
# For AMD:
rocm-smi

```

### SIF File Corrupted

**Fix:**

```bash
# Remove and re-pull
rm ~/.local/share/apptainer/*.sif
ujust apptainer pull nvidia-python

```

### Cache Too Large

**Check:**

```bash
du -sh ~/.apptainer/cache/

```

**Fix:**

```bash
ujust apptainer cache clean

```

## Cross-References

- **Related Skills:** `pod` (build OCI images), `jupyter` (uses containers)

- **GPU Setup:** `ujust configure gpu-containers setup`
- **Apptainer Docs:** [https://apptainer.org/docs/](https://apptainer.org/docs/)

## When to Use This Skill

Use when the user asks about:

- "apptainer", "singularity", "HPC container"

- "SIF file", "pull image", "build container"

- "apptainer GPU", "run with GPU"

- "HPC workload", "cluster container"
