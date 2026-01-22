---
name: install
description: |
  Development tool installation dispatcher for bazzite-ai. Installs Claude Code,
  pixi, chunkhound, bcvk, linters, flatpaks, and more. Use when users need to
  install standalone developer tools (not services with lifecycle management).
---

# Install - Development Tool Installer

## Overview

The `install` command is a unified dispatcher for installing standalone development tools. For services with lifecycle management (start/stop/logs), use their dedicated commands.

**Key Concept:** This is for standalone tools only. Use `ujust jupyter install`, `ujust runners install`, or `ujust jellyfin install` for managed services.

## Quick Reference

| Target | Command | Description |
|--------|---------|-------------|
| Aider | `ujust install aider` | AI pair programming tool |
| AppImage Manager | `ujust install appimage-manager` | AppImage management tool |
| bcvk | `ujust install bcvk` | Bootc virtualization kit |
| ccstatusline | `ujust install ccstatusline` | Claude Code statusline plugin |
| Chrome DevTools MCP | `ujust install chrome-devtools-mcp` | Chrome DevTools MCP server |
| Chrome Extension Fix | `ujust install chrome-extension-fix` | Fix Chrome extension permissions |
| Chunkhound | `ujust install chunkhound` | Semantic code search MCP server |
| Claude Code | `ujust install claude-code-npm` | Claude Code AI assistant CLI |
| Dev Tools | `ujust install dev-tools` | Meta-installer for dev tools |
| Devcontainers CLI | `ujust install devcontainers-cli` | Dev Container CLI |
| Firebase CLI | `ujust install firebase-cli` | Firebase CLI |
| Flatpaks Communication | `ujust install flatpaks-communication` | Communication flatpaks |
| Flatpaks Dev | `ujust install flatpaks-dev` | Development flatpaks |
| Flatpaks Gaming | `ujust install flatpaks-gaming` | Gaming tools flatpaks |
| Flatpaks Media | `ujust install flatpaks-media` | Media & graphics flatpaks |
| Fonts | `ujust install fonts` | Extra fonts via Homebrew |
| Gemini CLI | `ujust install gemini-cli` | Gemini CLI (Google AI) |
| GitHub MCP | `ujust install github-mcp-server` | GitHub MCP server for Claude |
| Homebrew | `ujust install homebrew` | Homebrew package manager |
| Linters | `ujust install linters` | Code linting tools |
| Pixi | `ujust install pixi` | Conda-compatible package manager |
| TweakCC | `ujust install tweakcc` | Claude Code customization tool |
| Wrangler | `ujust install wrangler` | Cloudflare Workers CLI |

## Common Installations

### AI Development Setup

```bash
# Install Claude Code
ujust install claude-code-npm

# Install Chunkhound for code search
ujust install chunkhound

# Install GitHub MCP server
ujust install github-mcp-server

# Install Chrome DevTools MCP (for browser automation)
ujust install chrome-devtools-mcp

```

### Python/ML Development

```bash
# Install Pixi (Conda-compatible, faster)
ujust install pixi

# Install development flatpaks
ujust install flatpaks-dev

```

### VM Testing

```bash
# Install bcvk for bootc VM testing
ujust install bcvk

```

## Dev Tools Meta-Installer

Install groups of tools at once:

```bash
# Quick essentials
ujust install dev-tools quick

# Core development tools
ujust install dev-tools core

# Claude Code ecosystem
ujust install dev-tools claude

# Code quality tools
ujust install dev-tools quality

# Extra utilities
ujust install dev-tools extras

# Google tools (Gemini, Firebase)
ujust install dev-tools google

# Full development environment
ujust install dev-tools environment

```

### Component Groups

| Component | Includes |
|-----------|----------|
| `quick` | claude-code-npm, pixi |
| `core` | quick + homebrew, linters |
| `claude` | chunkhound, github-mcp, tweakcc, ccstatusline |
| `quality` | linters, devcontainers-cli |
| `extras` | bcvk, appimage-manager |
| `google` | gemini-cli, firebase-cli, wrangler |
| `environment` | All of the above |

## Services vs Install

| For This | Use This |
|----------|----------|
| JupyterLab | `ujust jupyter install` |
| GitHub Runners | `ujust runners install` |
| Jellyfin | `ujust jellyfin install` |
| Ollama | `ujust ollama install` |
| Standalone tools | `ujust install <tool>` |

Services have lifecycle commands (start/stop/logs). Standalone tools are just installed.

## Flatpak Details

### Development

```bash
ujust install flatpaks-dev
# Includes: VS Code, PyCharm, etc.

```

### Media

```bash
ujust install flatpaks-media
# Includes: GIMP, Inkscape, Kdenlive, etc.

```

### Gaming

```bash
ujust install flatpaks-gaming
# Includes: Lutris, Heroic, ProtonUp-Qt, etc.

```

### All Flatpaks

```bash
ujust install flatpaks-all
# Installs all categories

```

## Troubleshooting

### Installation Failed

**Check:**

```bash
# For npm-based tools
npm --version

# For Homebrew tools
brew --version

# For Flatpaks
flatpak --version

```

### Claude Code Not Found After Install

**Cause:** Shell not reloaded

**Fix:**

```bash
exec $SHELL
# Or
source ~/.bashrc

```

### Pixi Not Found

**Fix:**

```bash
# Add to PATH
export PATH="$HOME/.pixi/bin:$PATH"

# Or reload shell
exec $SHELL

```

### Flatpak Install Fails

**Check:**

```bash
# Verify Flathub remote
flatpak remote-list

```

**Fix:**

```bash
# Add Flathub if missing
flatpak remote-add --if-not-exists flathub [https://flathub.org/repo/flathub.flatpakrepo]([https://flathub.org/repo/flathub.flatpakrepo](https://flathub.org/repo/flathub.flatpakrepo))
```

## Cross-References

- **Services:** `jupyter`, `runners`, `jellyfin`, `ollama` (have lifecycle commands)

- **Configuration:** `configure` (for enabling system services)

- **VM Tools:** `vm`, `bootc` (after installing bcvk)

## When to Use This Skill

Use when the user asks about:

- "install claude code", "setup claude", "claude cli"

- "install pixi", "conda alternative"

- "install flatpaks", "flatpak applications"

- "install development tools", "dev environment"

- "install bcvk", "bootc tools"
