---
name: record
description: |
  Development: Batch recording system for generating documentation recordings.
  Creates asciinema recordings of ujust commands organized by category (pods, k8s,
  vm, tools, config, install, test). Run from repository root with 'just record'.
  Use when developers need to regenerate documentation recordings for the website.
---

# Record - Documentation Recording System

## Overview

The `record` command generates asciinema recordings of ujust commands for documentation. It automates the recording of command lifecycles (config, start, status, logs, stop, delete) across all services and tools.

**Key Concept:** This is a batch recording system for documentation generation. For recording individual commands, see the user-facing `/bazzite-ai:record` skill which uses `ujust record`.

**This is a development command** - run with `just` from the repository root, not `ujust`.

## Quick Reference

| Action | Command | Description |
|--------|---------|-------------|
| Interactive | `just record` | Show recording menu |
| All | `just record all` | Record everything |
| Pods | `just record pods` | Record all pod services |
| K8s | `just record k8s` | Record k3d/deploy commands |
| VM | `just record vm` | Record VM commands |
| Tools | `just record tools` | Record tool commands |
| Config | `just record config` | Record config commands |
| Install | `just record install` | Record install commands |
| Test | `just record test` | Record test commands |
| Status | `just record status` | Show recording status |
| Generate | `just record generate-docs` | Generate gallery pages |

### Individual Services

| Service | Command | Description |
|---------|---------|-------------|
| Ollama | `just record ollama` | Record ollama lifecycle |
| Jupyter | `just record jupyter` | Record jupyter lifecycle |
| OpenWebUI | `just record openwebui` | Record openwebui lifecycle |
| ComfyUI | `just record comfyui` | Record comfyui lifecycle |
| FiftyOne | `just record fiftyone` | Record fiftyone lifecycle |
| Jellyfin | `just record jellyfin` | Record jellyfin lifecycle |
| Portainer | `just record portainer` | Record portainer lifecycle |
| Runners | `just record runners` | Record runners lifecycle |
| k3d | `just record k3d` | Record k3d lifecycle |

## Parameters

```bash
just record ACTION
```

| Parameter | Values | Description |
|-----------|--------|-------------|
| `ACTION` | See quick reference | Recording action or service name |

## Recording Categories

### All Recordings

```bash
just record all
```

Records everything in order:

1. Pod services (ollama, jupyter, etc.)
2. Kubernetes (k3d, deploy)
3. VM commands
4. Tools
5. Config
6. Install
7. Test

**Use when:** Regenerating all documentation recordings.

### Pod Services

```bash
just record pods
```

Records lifecycle for all pod-based services:

- ollama, jupyter, openwebui, comfyui
- fiftyone, jellyfin, portainer, runners

Each service records: config, start, status, logs, stop, delete

### Kubernetes Commands

```bash
just record k8s
```

Records k3d cluster and deploy commands:

- Cluster creation and management
- Helm deployments (JupyterHub, KubeAI)

### VM Commands

```bash
just record vm
```

Records virtual machine commands:

- VM add, start, status, ssh, stop, delete
- Image download and management

### Individual Service

```bash
just record ollama
just record jupyter
just record comfyui
# etc.
```

Records the complete lifecycle for a specific service.

## Output Structure

Recordings are saved to:

```
docs/recordings/
├── ollama/
│   ├── config.cast
│   ├── start.cast
│   ├── status.cast
│   ├── logs.cast
│   ├── stop.cast
│   └── delete.cast
├── jupyter/
│   └── ...
├── k3d/
│   └── ...
└── vm/
    └── ...
```

## Documentation Generation

### Generate Gallery Pages

```bash
just record generate-docs
```

Generates markdown pages with embedded asciinema players for the documentation site.

### Check Recording Status

```bash
just record status
```

Shows which recordings exist and which are missing.

## Common Workflows

### Full Documentation Regeneration

```bash
# Record everything
just record all

# Generate gallery pages
just record generate-docs

# Build documentation
just docs-build
```

### Update Specific Service

```bash
# Record just ollama
just record ollama

# Regenerate docs
just record generate-docs
```

### Before Release

```bash
# Check what's recorded
just record status

# Record missing items
just record pods
just record k8s

# Generate and verify
just record generate-docs
just docs-serve
```

## Error Handling

| Behavior | Description |
|----------|-------------|
| Failed command | Recording fails and is not kept |
| Category failure | Propagates to `all` (reported at end) |
| Partial success | Successful recordings are kept |

If a command fails during recording, the recording is discarded. This ensures only working commands appear in documentation.

## Requirements

| Tool | Purpose |
|------|---------|
| `asciinema` | Terminal recording |
| `jq` | Metadata injection |

Both are pre-installed in Bazzite AI.

## Troubleshooting

### Recording Fails Immediately

**Symptom:** Recording starts but immediately fails

**Cause:** The ujust command itself is failing

**Fix:**

```bash
# Test the command manually first
ujust ollama start

# Fix any issues, then record
just record ollama
```

### Missing Recordings in Status

**Symptom:** `just record status` shows missing files

**Cause:** Recordings not generated or failed

**Fix:**

```bash
# Record the missing category
just record pods  # or specific service
```

### Gallery Not Updated

**Symptom:** Documentation doesn't show new recordings

**Cause:** Gallery pages not regenerated

**Fix:**

```bash
just record generate-docs
just docs-build
```

## Cross-References

- **User Recording:** `/bazzite-ai:record` skill for individual command recording
- **Documentation:** `/bazzite-ai-dev:build` for building docs after recording
- **Services:** See individual service skills for command details

## When to Use This Skill

Use when the user asks about:

- "record all", "regenerate recordings"
- "documentation recordings", "asciinema batch"
- "just record" (batch recording)
- "record pods", "record k8s", "record vm"
- "generate documentation gallery"
