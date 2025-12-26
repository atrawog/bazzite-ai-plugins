---
name: runners
description: |
  Self-hosted GitHub Actions runner management via Podman Quadlet. Supports
  multi-instance pools with ephemeral storage, automatic token generation,
  and rolling updates. Use when users need to set up CI/CD runners for
  their GitHub repositories.
---

# Runners - GitHub Actions Self-Hosted Runners

## Overview

The `runners` command manages self-hosted GitHub Actions runners using Podman Quadlet containers. It supports multi-instance pools with ephemeral storage for clean builds.

**Key Concept:** Each runner instance connects to a GitHub repository and picks up workflow jobs. Ephemeral storage ensures each job starts with a clean state.

## Quick Reference

| Action | Command | Description |
|--------|---------|-------------|
| Config | `ujust runners config <REPO_URL> <N> [IMAGE] [WORKSPACE]` | Configure runner N for repo |
| Start | `ujust runners start [N\|all]` | Start runner(s) |
| Stop | `ujust runners stop [N\|all]` | Stop runner(s) |
| Restart | `ujust runners restart [N\|all]` | Restart runner(s) |
| Update | `ujust runners update [N\|all]` | Update to latest image |
| Rolling update | `ujust runners rolling-update` | Update with zero downtime |
| Sync | `ujust runners sync [N]` | Sync config from source |
| Logs | `ujust runners logs [N] [LINES]` | View logs |
| List | `ujust runners list` | List all runners |
| Shell | `ujust runners shell [CMD] [N]` | Open shell in container |
| Delete | `ujust runners delete [N\|all]` | Remove runner(s) and images |

## Prerequisites

```bash
# 1. Authenticate GitHub CLI
gh auth login

# 2. Verify authentication
gh auth status
```

## Configuration

### Config Parameters

```bash
ujust runners config <REPO_URL> <INSTANCE> [IMAGE] [WORKSPACE]
```

| Parameter | Required | Description |
|-----------|----------|-------------|
| `REPO_URL` | Yes | GitHub repository URL |
| `INSTANCE` | Yes | Instance number (1, 2, 3...) |
| `IMAGE` | No | Container image or tag (default: stable) |
| `WORKSPACE` | No | Optional additional mount to /workspace |

### Configuration Examples

```bash
# Basic runner
ujust runners config https://github.com/owner/repo 1

# Runner with testing tag
ujust runners config https://github.com/owner/repo 1 testing

# Runner with workspace mount
ujust runners config https://github.com/owner/repo 1 latest /home/user

# Custom image with workspace
ujust runners config https://github.com/owner/repo 1 "ghcr.io/custom/runner:v1" /projects
```

### Install Multiple Runners

```bash
# Runner pool for a repository
ujust runners config https://github.com/owner/repo 1
ujust runners config https://github.com/owner/repo 2
ujust runners config https://github.com/owner/repo 3

# Start all
ujust runners start all
```

### Update Existing Configuration

Running `config` when already configured will update the existing configuration, preserving values not explicitly changed.

### Shell Access

```bash
# Interactive bash shell
ujust runners shell

# Run specific command
ujust runners shell "df -h"

# Shell in specific instance
ujust runners shell "cat /config/runner.env" 2
```

## Lifecycle Commands

### Start/Stop

```bash
# Single runner
ujust runners start 1
ujust runners stop 1

# All runners
ujust runners start all
ujust runners stop all
```

### Updates

```bash
# Fast update (stops runner briefly)
ujust runners update 1

# Rolling update (zero-downtime)
ujust runners rolling-update
```

Rolling update:

1. Stops runner 1
2. Updates runner 1
3. Starts runner 1
4. Waits for healthy state
5. Repeats for runner 2, 3, ...

### View Logs

```bash
# Follow logs
ujust runners logs 1

# Last N lines
ujust runners logs 1 100
```

## Token Management

Tokens are **automatically generated** via GitHub API - no manual copying required!

### How It Works

1. Config command calls GitHub API
2. Generates registration token
3. Configures runner with token
4. Token auto-refreshes on restart

### Requirements

- GitHub CLI authenticated (`gh auth login`)
- Admin access to repository

## Architecture

### Ephemeral Storage

Each runner has ephemeral storage:

- Clean state on every restart
- No stale artifacts between jobs
- Prevents cache bloat

### Host Image Cache

Runners access host container cache (read-only):

- Fast container image pulls
- Shared cache across runners
- No duplicate downloads

### Podman Mirror Integration

If configured, runners use local registry mirror:

- Transparent caching
- Faster pulls
- Reduced bandwidth

## Configuration Files

| File | Purpose | Location |
|------|---------|----------|
| Quadlet unit | Service definition | `~/.config/containers/systemd/github-runner-1.container` |
| Runner config | Per-runner settings | `~/.config/github-runner/runner-1.env` |

## Common Workflows

### Setup CI for Repository

```bash
# 1. Authenticate GitHub
gh auth login

# 2. Configure runner
ujust runners config https://github.com/myorg/myrepo 1

# 3. Start runner
ujust runners start 1

# 4. Verify in GitHub
# Settings → Actions → Runners
```

### Scale Up Runner Pool

```bash
# Add more runners
ujust runners config https://github.com/myorg/myrepo 2
ujust runners config https://github.com/myorg/myrepo 3

# Start all
ujust runners start all

# List pool
ujust runners list
```

### Update All Runners

```bash
# Option 1: Fast update (brief downtime)
ujust runners stop all
ujust runners update all
ujust runners start all

# Option 2: Rolling update (zero downtime)
ujust runners rolling-update
```

### Clean Reinstall

```bash
# Delete runner
ujust runners delete 1

# Reconfigure
ujust runners config https://github.com/myorg/myrepo 1
ujust runners start 1
```

## Workflow Labels

Runners automatically get these labels:

- `self-hosted`
- `linux`
- `x64`
- `bazzite-ai`

Use in workflow:

```yaml
runs-on: [self-hosted, bazzite-ai]
```

## Troubleshooting

### Runner Not Appearing in GitHub

**Check:**

```bash
ujust runners status 1
ujust runners logs 1 50
```

**Common causes:**

- GitHub CLI not authenticated
- Token generation failed
- Network issues

**Fix:**

```bash
# Re-authenticate
gh auth login

# Reconfigure runner
ujust runners delete 1
ujust runners config https://github.com/owner/repo 1
```

### Jobs Not Running

**Symptom:** Runner shows "Idle" but jobs queue

**Check:**

```bash
ujust runners logs 1
```

**Common causes:**

- Labels don't match workflow
- Runner offline
- Repository permissions

### Runner Keeps Restarting

**Check:**

```bash
systemctl --user status github-runner-1
ujust runners logs 1 100
```

**Common causes:**

- Token expired (auto-fixes on restart)
- Image issues
- Resource exhaustion

### Slow Builds

**Optimize:**

```bash
# Setup local registry mirror
ujust mirror config

# Runners auto-use mirror if configured
```

## Cross-References

- **Related Skills:** `mirror` (registry caching), `pod` (build images)
- **GitHub Docs:** Actions → Self-hosted runners
- **Authentication:** `gh auth login`

## When to Use This Skill

Use when the user asks about:

- "setup github runner", "self-hosted runner", "CI runner"
- "install runner", "add runner", "more runners"
- "runner not working", "runner offline"
- "update runner", "rolling update"
- "runner logs", "runner status"
