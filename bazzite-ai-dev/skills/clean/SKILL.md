---
name: clean
description: |
  Development: Cleanup and maintenance for the development environment.
  Removes build artifacts, caches, containers, and recovers disk space.
  Run from repository root with 'just clean'. Use when developers need
  to free disk space or reset the build environment.
---

# Clean - Cleanup & Maintenance

## Overview

The `clean` development commands remove build artifacts, caches, containers, and other temporary files to recover disk space and reset the development environment.

**Key Concept:** This is a **development command** - run with `just` from the repository root, not `ujust`. It provides both interactive menu and non-interactive modes.

## Quick Reference

| Action | Command | Description |
|--------|---------|-------------|
| Interactive menu | `just clean` | Show cleanup options |
| Status report | `just clean status` | Show what would be cleaned |
| Safe cleanup | `just clean all` | Safe cleanup (preserves running containers) |
| Nuclear cleanup | `just clean nuke` | NUCLEAR: destroy everything (requires NUKE confirmation) |
| Podman prune | `just clean podman` | Full podman system prune |
| Images | `just clean images` | Dangling images only |
| All images | `just clean images all` | All unused images |
| Build cache | `just clean images build-cache` | Podman builder cache |
| Containers | `just clean containers` | Stopped containers |
| Runners | `just clean runners` | Stop/restart GitHub runners |
| VMs | `just clean vm` | VM images (libvirt + cache) |
| System | `just clean system` | Tmp files + journal |
| Logs | `just clean logs` | Remove *.log files |
| Docs | `just clean docs` | Remove site/ directory |
| Output | `just clean output` | Remove output/ contents |
| Cache menu | `just clean cache` | Cache cleanup submenu |
| Pixi cache | `just clean cache pixi` | .pixi/ + ~/.cache/rattler |
| Venv | `just clean cache venv` | venv/ directory |
| Chunkhound | `just clean cache chunkhound` | .chunkhound/ directory |
| Pip | `just clean cache pip` | ~/.cache/pip/ |
| Pre-commit | `just clean cache precommit` | ~/.cache/pre-commit/ |
| GitHub CLI | `just clean cache gh` | ~/.cache/gh/ |

## Safe vs Nuclear Cleanup

### Safe Cleanup (`just clean all`)

Safe cleanup that preserves running containers and configurations:

1. Stop GitHub runners
2. Remove runner containers
3. Remove stopped containers
4. Remove buildah working containers
5. Clean /var/tmp (buildah artifacts)
6. Podman system prune
7. Clean builder cache
8. Prune unused images
9. Remove build logs
10. Remove docs output
11. Remove build output
12. Clean all caches
13. Vacuum journal logs
14. Prune volumes
15. Restart GitHub runners

**Use when:** You want to free disk space but keep your pod configurations intact.

### Nuclear Cleanup (`just clean nuke`)

**DESTROYS EVERYTHING** - requires typing 'NUKE' to confirm:

- Removes ALL containers (running and stopped)
- Removes ALL images
- Removes ALL volumes
- Removes ALL pod configurations
- Removes ALL cached data
- Cleans system caches

**Use when:** You want a completely fresh start or are troubleshooting persistent issues.

**Warning:** This will delete:

- All pod configurations (you'll need to reconfigure)
- All downloaded container images (will need to re-pull)
- All model data if stored in containers
- All runner configurations

## Parameters

```bash
just clean [ACTION] [SUBOPTION]
```

| Parameter | Values | Description |
|-----------|--------|-------------|
| `ACTION` | See quick reference | Cleanup action |
| `SUBOPTION` | Varies by action | Sub-action for nested menus |

## Cleanup Actions

### status

Show what would be cleaned (dry-run):

```bash
just clean status
```

**Reports:**

- Podman images/containers
- System files (/var/tmp, journal)
- Build artifacts (logs, docs, output)
- Caches (pixi, venv, pip, etc.)

### all

Safe cleanup (15 steps):

```bash
just clean all
```

### nuke

Nuclear option (requires NUKE confirmation):

```bash
just clean nuke
# Type 'NUKE' when prompted to confirm
```

### podman

Full podman system prune:

```bash
just clean podman
```

**Removes:**

- All unused images
- Stopped containers
- Unused volumes
- Builder cache

### images

Clean podman images:

```bash
just clean images              # Dangling only
just clean images all          # All unused
just clean images build-cache  # Builder cache
```

### containers

Remove stopped containers:

```bash
just clean containers
```

### runners

Manage GitHub runners:

```bash
just clean runners stop   # Stop runners
just clean runners start  # Start runners
```

### vm

Clean VM images:

```bash
just clean vm            # Interactive
just clean vm libvirt    # Libvirt VMs
just clean vm cache      # VM cache
```

### system

System cleanup:

```bash
just clean system        # Interactive
just clean system tmp    # Clean /var/tmp
just clean system journal # Vacuum journal logs
```

### cache

Clean development caches:

```bash
just clean cache          # Interactive
just clean cache pixi     # .pixi/ + ~/.cache/rattler
just clean cache venv     # venv/
just clean cache chunkhound # .chunkhound/
just clean cache pip      # ~/.cache/pip/
just clean cache precommit # ~/.cache/pre-commit/
just clean cache gh       # ~/.cache/gh/
```

## Common Workflows

### Check Before Cleanup

```bash
# See what would be cleaned
just clean status

# Then decide what to clean
just clean podman
```

### Recover Disk Space

```bash
# Safe cleanup
just clean all

# Or targeted cleanup
just clean images all
just clean cache pixi
just clean output
```

### Reset Build Environment

```bash
# Clean all caches and build artifacts
just clean cache all
just clean output
just clean docs

# Reinstall dependencies
just docs-install
```

### Before Major Rebuild

```bash
# Clean containers and images
just clean podman

# Then rebuild
just build os
```

### Complete Fresh Start

```bash
# Nuclear option - destroys everything
just clean nuke
# Type 'NUKE' to confirm

# Reconfigure everything from scratch
ujust jupyter config
ujust ollama config
```

## Disk Space Targets

| Target | Typical Size | Command |
|--------|--------------|---------|
| Podman images | 10-50GB | `clean podman` |
| Builder cache | 1-10GB | `clean images build-cache` |
| /var/tmp | 1-5GB | `clean system tmp` |
| Journal logs | 100MB-1GB | `clean system journal` |
| Pixi cache | 1-5GB | `clean cache pixi` |
| Output/ | 1-20GB | `clean output` |

## Troubleshooting

### Cleanup Fails with Permission Error

**Symptom:** Cannot remove files in output/ or /var/tmp

**Fix:**

```bash
# Fix permissions
sudo chown -R $USER:$USER output/

# For /var/tmp
sudo rm -rf /var/tmp/buildah*
```

### Podman Prune Doesn't Free Space

**Symptom:** Images still present after prune

**Cause:** Containers referencing images

**Fix:**

```bash
# Stop and remove all containers first
just clean containers
just clean runners stop

# Then prune
just clean podman
```

### GitHub Runners Won't Restart

**Symptom:** Runners fail to start after cleanup

**Cause:** Configuration lost or token expired

**Fix:**

```bash
# Re-authenticate
just gh-login

# Reconfigure runners
ujust runners config <REPO_URL> 1
```

## Cross-References

- **Related Skills:** `pods` (build pods), `vms` (build VMs), `docs` (build docs)
- **GitHub Runners:** `ujust runners` (runner management)
- **Disk Analysis:** `just clean status`

## When to Use This Skill

Use when the user asks about:

- "clean up", "cleanup", "free disk space"
- "remove containers", "prune images"
- "clean cache", "clear cache"
- "just clean", "clean podman"
- "disk full", "out of space"
- "reset environment", "fresh start"
- "nuclear cleanup", "destroy everything"
