---
name: build
description: |
  Development: OS container image building with Podman. Builds the bazzite-ai
  OCI image from Containerfile. Run from repository root with 'just build'.
  Use when developers need to build or rebuild the OS image locally.
---

# Build - OS Image Building

## Overview

The `build` command builds the bazzite-ai OS container image using Podman. It creates an OCI-compliant image from the Containerfile that can be deployed via rpm-ostree rebase or converted to VM/ISO formats.

**Key Concept:** This is a **development command** - run with `just` from the repository root, not `ujust`. It requires the bazzite-ai repository to be cloned.

## Quick Reference

| Action | Command | Description |
|--------|---------|-------------|
| Build default | `just build` | Build with default name and tag |
| Build with tag | `just build bazzite-ai testing` | Build with custom tag |
| Build and VM | `just rebuild-qcow2` | Build OS then create QCOW2 |
| Build and ISO | `just rebuild-iso` | Build OS then create live ISO |

## Parameters

```bash
just build [target_image] [tag]
```

| Parameter | Default | Description |
|-----------|---------|-------------|
| `target_image` | `bazzite-ai` | Image name |
| `tag` | `43` | Image tag (Fedora version) |

## Build Process

The build command:

1. Sets version string: `${tag}-$(date +%Y%m%d)`
2. Configures build arguments:
   - `BASE_IMAGE`: `ghcr.io/ublue-os/bazzite-nvidia-open:stable`
   - `IMAGE_NAME`: Target image name
   - `IMAGE_VENDOR`: Repository organization
   - `SHA_HEAD_SHORT`: Git commit SHA (if clean tree)
3. Builds with Podman using `--pull=newer`

## Build Arguments

| Argument | Value | Description |
|----------|-------|-------------|
| `BASE_IMAGE` | `ghcr.io/ublue-os/bazzite-nvidia-open:stable` | Upstream Bazzite base |
| `IMAGE_NAME` | `bazzite-ai` | Target image name |
| `IMAGE_VENDOR` | `atrawog` | GitHub organization |
| `SHA_HEAD_SHORT` | Git SHA | Only set if tree is clean |

## Common Workflows

### Local Development Build

```bash
# 1. Clone repository
git clone https://github.com/atrawog/bazzite-ai.git
cd bazzite-ai

# 2. Build OS image
just build

# 3. Verify build
podman images | grep bazzite-ai
```

### Build with Custom Tag

```bash
# Build testing version
just build bazzite-ai testing

# Build specific version
just build bazzite-ai 1.0.0
```

### Full Build Pipeline

```bash
# Build OS + create QCOW2 VM
just rebuild-qcow2

# Build OS + create live ISO
just rebuild-iso

# Build OS + create all ISO variants
just rebuild-iso-all
```

## Output

The build creates a local container image:

```
localhost/bazzite-ai:43
```

View with:

```bash
podman images | grep bazzite-ai
```

## Requirements

- Podman installed and configured
- Git repository cloned
- Sufficient disk space (~10GB for build)
- Network access (pulls base image)

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `GITHUB_REPOSITORY_OWNER` | `atrawog` | Override organization |
| `IMAGE_NAME` | `bazzite-ai` | Override image name |
| `DEFAULT_TAG` | `43` | Override default tag |

## Troubleshooting

### Build Fails with Pull Error

**Symptom:** Cannot pull base image

**Cause:** Network issues or registry authentication

**Fix:**

```bash
# Check network
curl -I https://ghcr.io

# Re-authenticate if needed
just gh-login
```

### Build Fails with Disk Space

**Symptom:** No space left on device

**Cause:** Build cache or old images consuming space

**Fix:**

```bash
# Clean up build artifacts
just clean podman

# Or full cleanup
just clean all
```

### Image Not Tagged Correctly

**Symptom:** Image has wrong tag or name

**Cause:** Environment variables overriding defaults

**Fix:**

```bash
# Check environment
echo $IMAGE_NAME $DEFAULT_TAG

# Build with explicit values
just build bazzite-ai 43
```

## Cross-References

- **Related Skills:** `vms` (VM/ISO from built image), `pods` (container pods)
- **Next Steps:** `just build-qcow2` (VM image), `just build-iso` (live ISO)
- **Documentation:** See `Containerfile` for image layers

## When to Use This Skill

Use when the user asks about:

- "build os image", "build bazzite-ai", "build container image"
- "rebuild image", "local build", "development build"
- "containerfile", "podman build", "oci image"
- "just build" (specifically the development command)
