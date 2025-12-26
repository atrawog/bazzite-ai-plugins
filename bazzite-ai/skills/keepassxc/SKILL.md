---
name: keepassxc
description: |
  KeePassXC password manager integration. Configure autostart, SSH agent,
  and FdoSecrets (replaces KWallet). Use when users need to set up password
  management, SSH key integration, or secret service configuration.
---

# KeePassXC - Password Management Integration

## Overview

The `keepassxc` command configures KeePassXC integration features. KeePassXC can provide SSH keys and act as a secret service for the desktop.

**Key Concept:** KeePassXC can replace KWallet as the system secret provider, and serve SSH keys from your password database.

## Quick Reference

| Feature | Command | Description |
|---------|---------|-------------|
| Autostart enable | `ujust keepassxc autostart enable` | Start on login |
| Autostart disable | `ujust keepassxc autostart disable` | Don't start on login |
| SSH enable | `ujust keepassxc ssh enable` | Enable SSH agent |
| SSH disable | `ujust keepassxc ssh disable` | Disable SSH agent |
| Secrets enable | `ujust keepassxc secrets enable` | Enable FdoSecrets |
| Secrets disable | `ujust keepassxc secrets disable` | Disable FdoSecrets |
| All enable | `ujust keepassxc all enable` | Enable all features |
| All disable | `ujust keepassxc all disable` | Disable all features |
| Status | `ujust keepassxc status` | Show all feature status |
| Help | `ujust keepassxc help` | Show help |

## Features

### Autostart

Automatically start KeePassXC on login.

```bash
# Enable
ujust keepassxc autostart enable

# Disable
ujust keepassxc autostart disable

# Check
ujust keepassxc autostart status

```

### SSH Agent

Use SSH keys stored in KeePassXC database.

```bash
# Enable
ujust keepassxc ssh enable

# Disable
ujust keepassxc ssh disable

```

**Requirements:**

- SSH keys stored in database entries

- Key attached to entry's "Advanced" section

- KeePassXC running with database unlocked

### Secret Service (FdoSecrets)

KeePassXC as system secret provider (replaces KWallet).

```bash
# Enable
ujust keepassxc secrets enable

# Disable
ujust keepassxc secrets disable

```

**Note:** FdoSecrets and KWallet are mutually exclusive. Enabling one disables the other.

### All Features

Enable or disable all features at once.

```bash
# Enable autostart + SSH + secrets
ujust keepassxc all enable

# Disable all
ujust keepassxc all disable

```

## Status Check

```bash
ujust keepassxc status

```

Shows:

- Installation status

- Running state

- Autostart configuration

- SSH agent status

- FdoSecrets status

## Configuration Files

| File | Purpose |
|------|---------|
| `~/.config/keepassxc/keepassxc.ini` | Main configuration |
| `~/.config/autostart/org.keepassxc.KeePassXC.desktop` | Autostart entry |

## Common Workflows

### Full Desktop Integration

```bash
# Enable all features
ujust keepassxc all enable

# Verify
ujust keepassxc status

```

Now KeePassXC will:

1. Start on login
2. Provide SSH keys
3. Act as secret service

### SSH Key Management

```bash
# 1. Enable SSH agent
ujust keepassxc ssh enable

# 2. In KeePassXC:
#    - Open entry with SSH key
#    - Go to Advanced
#    - Add SSH key attachment
#    - Enable "Use for SSH agent"

# 3. Unlock database, keys available
ssh-add -l  # Shows keys from KeePassXC

```

### Replace KWallet

```bash
# Enable FdoSecrets (replaces KWallet)
ujust keepassxc secrets enable

# Desktop apps now use KeePassXC for secrets
# (Browser password prompts, email clients, etc.)

```

## SSH Agent Details

### How It Works

1. KeePassXC acts as SSH agent
2. Keys stored in database
3. Agent provides keys when needed
4. Works with `git`, `ssh`, etc.

### Store SSH Key in KeePassXC

1. Create new entry (or edit existing)
2. Go to "Advanced" tab
3. Click "Add" in Attachments
4. Select your SSH private key
5. Enable "Expose SSH key to agent"

### Verify SSH Agent

```bash
# List keys from KeePassXC agent
SSH_AUTH_SOCK=/run/user/$UID/keyring/ssh ssh-add -l

# Or if KeePassXC is the only agent
ssh-add -l

```

## FdoSecrets Details

### What It Does

- Provides D-Bus Secret Service API

- Apps store/retrieve secrets via KeePassXC

- Compatible with libsecret-based apps

### Supported Apps

- GNOME Keyring users

- Evolution (email)

- Chrome/Firefox (if configured)

- Many CLI tools

### Conflict with KWallet

FdoSecrets and KWallet both provide D-Bus Secret Service. Only one can be active:

```bash
# Enable FdoSecrets (disables KWallet)
ujust keepassxc secrets enable

# Or use KWallet (disable FdoSecrets)
ujust keepassxc secrets disable

```

## Troubleshooting

### KeePassXC Not Found

**Error:** "KeePassXC not found"

**Fix:** KeePassXC should be pre-installed. File a bug if missing.

### SSH Agent Not Working

**Check:**

```bash
ujust keepassxc ssh status
echo $SSH_AUTH_SOCK

```

**Ensure:**

- KeePassXC is running

- Database is unlocked

- Key has "Expose SSH key to agent" enabled

### FdoSecrets Not Working

**Check:**

```bash
ujust keepassxc secrets status

```

**Ensure:**

- KeePassXC is running

- Database is unlocked

- No other secret service running (KWallet)

### Autostart Not Working

**Check:**

```bash
ls ~/.config/autostart/org.keepassxc.KeePassXC.desktop

```

**Fix:**

```bash
ujust keepassxc autostart enable
# Log out and back in

```

## Cross-References

- **Related Skills:** `configure passwordless-sudo` (security)
- **KeePassXC Docs:** [https://keepassxc.org/docs/](https://keepassxc.org/docs/)

## When to Use This Skill

Use when the user asks about:

- "keepassxc", "password manager", "secrets"

- "SSH agent", "SSH keys", "git SSH"

- "kwallet", "secret service", "fdosecrets"

- "autostart keepassxc", "keepassxc on login"
