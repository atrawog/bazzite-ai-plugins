---
name: security
description: |
  Security configuration for Bazzite. LUKS disk encryption with TPM auto-unlock,
  secure boot key management, and sudo password feedback. Use when users need
  to configure security features.
---

# Security - Bazzite Security Configuration

## Overview

Bazzite security features including LUKS disk encryption with TPM auto-unlock, and sudo password visibility settings.

## Quick Reference

| Command | Description |
|---------|-------------|
| `ujust setup-luks-tpm-unlock` | Enable TPM auto-unlock for LUKS |
| `ujust remove-luks-tpm-unlock` | Remove TPM auto-unlock |
| `ujust toggle-password-feedback` | Toggle sudo asterisk feedback |

## LUKS TPM Unlock

### Setup TPM Auto-Unlock

```bash
# Enable automatic LUKS unlock via TPM
ujust setup-luks-tpm-unlock
```

**What it does:**
- Binds LUKS encryption to TPM 2.0
- System unlocks automatically at boot
- No password prompt needed

**Requirements:**
- TPM 2.0 chip
- LUKS-encrypted root partition
- Secure Boot recommended

**Process:**
1. Verifies TPM availability
2. Creates TPM binding
3. Updates initramfs
4. Tests unlock

### Remove TPM Unlock

```bash
# Remove TPM auto-unlock
ujust remove-luks-tpm-unlock
```

Returns to password-based unlock at boot.

**Use when:**
- Selling/giving away machine
- Security concerns
- TPM issues

## Sudo Password Feedback

### Toggle Asterisks

```bash
# Toggle sudo password asterisk feedback
ujust toggle-password-feedback
```

**With feedback:**
```
[sudo] password for user: ****
```

**Without feedback (default):**
```
[sudo] password for user:
```

**Security note:** Asterisks reveal password length. Default (no feedback) is more secure.

## Common Workflows

### Secure Boot Setup

```bash
# 1. Enroll secure boot key (for NVIDIA)
ujust enroll-secure-boot-key

# 2. Setup TPM unlock
ujust setup-luks-tpm-unlock

# Reboot to test
systemctl reboot
```

### Disable Before Selling

```bash
# Remove TPM binding
ujust remove-luks-tpm-unlock

# Clear TPM (in BIOS/UEFI)
# Factory reset recommended
```

## TPM Status

### Check TPM Availability

```bash
# TPM version and status
tpm2_getcap properties-fixed | head -20

# TPM PCR values
tpm2_pcrread
```

### Check LUKS Binding

```bash
# List LUKS tokens
cryptsetup luksDump /dev/<device> | grep Token

# Check systemd-cryptenroll
systemd-cryptenroll --tpm2-device=list
```

## Troubleshooting

### TPM Unlock Fails

**Common causes:**
- BIOS update changed PCR values
- Secure Boot state changed
- Hardware change detected

**Fix:**

```bash
# Re-enroll TPM
ujust remove-luks-tpm-unlock
ujust setup-luks-tpm-unlock
```

### TPM Not Found

**Check:**

```bash
# Verify TPM device
ls /dev/tpm*

# TPM status
tpm2_getcap properties-fixed
```

**Enable in BIOS:**
- Find TPM/Security settings
- Enable TPM 2.0

### After BIOS Update

TPM PCR values change after BIOS updates, breaking auto-unlock.

**Fix:**

```bash
# Boot with password
# Then re-enroll
ujust remove-luks-tpm-unlock
ujust setup-luks-tpm-unlock
```

### Sudo Password Not Showing

**If you want asterisks:**

```bash
ujust toggle-password-feedback
```

**Manual fix:**

```bash
# Edit sudoers
sudo visudo

# Add line:
# Defaults pwfeedback
```

## Security Best Practices

### For TPM Unlock

1. **Enable Secure Boot** - Prevents boot tampering
2. **Set BIOS password** - Prevents Secure Boot changes
3. **Keep backup passphrase** - For recovery
4. **Re-enroll after BIOS updates**

### For General Security

1. **Use strong passwords**
2. **Enable automatic updates** (`ujust toggle-updates`)
3. **Consider password feedback OFF** (hides length)
4. **Check SSH settings** (`ujust configure sshd status`)

## Cross-References

- **bazzite:boot** - Secure boot key enrollment
- **bazzite:storage** - LUKS volume management
- **bazzite-ai:configure** - SSH and service security

## When to Use This Skill

Use when the user asks about:
- "LUKS unlock", "disk encryption", "TPM unlock"
- "auto unlock", "boot without password", "encrypted boot"
- "remove TPM", "disable auto unlock"
- "sudo password", "asterisks", "password feedback"
- "security settings", "secure boot", "TPM"
