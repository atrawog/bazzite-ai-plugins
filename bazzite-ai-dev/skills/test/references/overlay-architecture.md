# Overlay Testing Architecture

## Overview

Bazzite-AI uses an overlay testing system that enables live development on immutable operating systems. This document explains how it works.

## The Problem

On immutable OSTree-based systems (Bazzite-AI, Fedora Silverblue):

- `/usr` is read-only by design

- Changes require rebuilding the OS image

- Development iteration is slow

## The Solution: Overlay Testing

### On Immutable Systems (OSTree)

1. **rpm-ostree usroverlay**: Temporarily unlocks `/usr` as a writable overlay
2. **Symlinks**: Point `/usr/share/bazzite-ai/just/` to repository files
3. **60-custom.just**: Auto-generated import file that loads all `.just` files

```

/usr/share/bazzite-ai/
└── just/
    ├── 60-custom.just          # Auto-generated imports
    └── bazzite-ai -> ~/repo/   # Symlink to repository

```

### On Traditional Systems

No overlay needed - just symlinks:

```

/usr/share/bazzite-ai/
└── just/
    └── bazzite-ai -> ~/repo/just/bazzite-ai/

```

## File Flow

```

Repository                    System
===========                   ======
just/bazzite-ai/*.just  -->  /usr/share/bazzite-ai/just/bazzite-ai/
                              (via symlink)
                                    |
                                    v
                             60-custom.just imports all
                                    |
                                    v
                             ujust finds commands

```

## Key Files

| File | Purpose |
|------|---------|
| `60-custom.just` | Auto-generated, imports all module `.just` files |
| `_entry.just` | Module entry point, imported by 60-custom.just |
| `lib/*.just` | Library files (private helpers) |
| `*.just` | User-facing recipe files |

## Persistence

| Item | Persists After Reboot? |
|------|------------------------|
| Git commits | Yes |
| Symlinks | No (overlay) / Yes (traditional) |
| Overlay mode | No (must re-enable) |
| User services | Yes (~/.config/systemd/user/) |

## Commands

```bash
# Enable overlay (creates symlinks + overlay)
just test overlay enable

# Check current status
just test overlay check

# Refresh after adding/removing files
just test overlay refresh

```

## Troubleshooting

### Overlay Resets on Reboot

This is by design on immutable systems. Run `just test overlay enable` after each reboot.

### Changes Not Visible

Run `just test overlay refresh` to regenerate 60-custom.just.

### sudo Required

Overlay activation requires sudo. Enable passwordless sudo for smoother workflow:

```bash
ujust config passwordless-sudo enable

```
