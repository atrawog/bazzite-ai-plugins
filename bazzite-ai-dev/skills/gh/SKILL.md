---
name: gh
description: |
  Development: GitHub CLI authentication for GHCR access and runner registration.
  Authenticates with GitHub and logs into the container registry. Run from
  repository root with 'just gh-login'. Use when developers need to push
  images or set up GitHub runners.
---

# GH - GitHub Authentication

## Overview

The `gh` development command authenticates with GitHub for container registry access and runner registration. It uses the GitHub CLI device code flow and logs into GHCR (GitHub Container Registry).

**Key Concept:** This is a **development command** - run with `just` from the repository root, not `ujust`. Authentication persists until you run `gh auth logout`.

## Quick Reference

| Action | Command | Description |
|--------|---------|-------------|
| Login | `just gh-login` | Authenticate with GitHub |

## Command

### gh-login

Authenticates with GitHub and logs into GHCR:

```bash
just gh-login
```

**Flow:**

1. Check if already authenticated
2. Validate required scopes
3. Prompt for authentication (web or device code)
4. Log into ghcr.io container registry

## Required Scopes

| Scope | Purpose |
|-------|---------|
| `read:packages` | Pull images from GHCR |
| `write:packages` | Push images to GHCR |
| `repo` | Generate runner registration tokens |

## Authentication Methods

### Web Browser (Default)

If a browser is available:

1. Browser opens GitHub login page
2. Authorize the application
3. Return to terminal

### Device Code

If no browser (SSH, headless):

1. Copy the code shown in terminal
2. Visit `github.com/login/device`
3. Enter the code
4. Authorize the application

## Common Workflows

### First-Time Setup

```bash
# 1. Run gh-login
just gh-login

# 2. Follow prompts to authenticate
# 3. Verify authentication
gh auth status
```

### Push Images to GHCR

```bash
# 1. Authenticate
just gh-login

# 2. Build image
just build-pod nvidia

# 3. Push to registry
podman push ghcr.io/atrawog/bazzite-ai-pod-nvidia:latest
```

### Set Up GitHub Runners

```bash
# 1. Authenticate (need repo scope)
just gh-login

# 2. Install runners
ujust runners install https://github.com/atrawog/bazzite-ai
```

## Token Persistence

The GitHub token is stored by `gh` CLI and persists across sessions:

- **Location:** `~/.config/gh/hosts.yml`
- **Expires:** Never (until revoked)
- **Logout:** `gh auth logout`

The container registry login is stored by Podman:

- **Location:** `~/.local/share/containers/auth.json`
- **Logout:** `podman logout ghcr.io`

## Troubleshooting

### gh CLI Not Found

**Symptom:** `gh: command not found`

**Fix:**

```bash
# On Fedora/Bazzite (should be pre-installed)
rpm-ostree install gh

# Or download from GitHub
# https://github.com/cli/cli#installation
```

### Missing Scopes

**Symptom:** `Missing scopes: repo`

**Fix:**

```bash
# The command auto-refreshes scopes
just gh-login

# Or manually refresh
gh auth refresh --scopes "read:packages,write:packages,repo"
```

### Container Registry Login Fails

**Symptom:** `Error: unauthorized`

**Cause:** Token expired or revoked

**Fix:**

```bash
# Re-authenticate
gh auth logout
just gh-login
```

### Device Code Flow Issues

**Symptom:** Device code not accepted

**Cause:** Code expired (15 minute limit)

**Fix:**

```bash
# Try again with fresh code
just gh-login
```

### Push to Registry Fails

**Symptom:** `denied: permission_denied`

**Cause:** Missing write:packages scope or wrong repository

**Fix:**

```bash
# Check current scopes
gh auth status

# Refresh with correct scopes
just gh-login
```

## Registry URL

Images are pushed to:

```
ghcr.io/<organization>/<image-name>:<tag>
```

Default organization: `atrawog`

## Cross-References

- **Related Skills:** `pods` (build and push pods), `clean` (logout)
- **GitHub Runners:** `ujust runners install`
- **GitHub CLI:** <https://cli.github.com/>
- **GHCR Docs:** <https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry>

## When to Use This Skill

Use when the user asks about:

- "github login", "gh login", "authenticate github"
- "push to ghcr", "container registry login"
- "github token", "ghcr access"
- "just gh-login"
- "permission denied ghcr", "unauthorized"
