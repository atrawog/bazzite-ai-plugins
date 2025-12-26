# Managed Shell Configurations

## Overview

Bazzite-AI provides modern shell configurations in `/etc/skel` that are copied to user homes. The `ujust shell` command manages synchronization with these defaults.

## Configuration Files

### ~/.bashrc

Modern bash configuration with:

- Starship prompt integration

- fzf keybindings and completion

- zoxide (smart cd) integration

- Aliases for modern tools (eza, bat, ripgrep)

- History improvements (size, dedup, timestamps)

### ~/.zshrc

Zsh configuration with:

- Starship prompt integration

- Plugin manager setup

- fzf integration

- zoxide integration

- Modern tool aliases

- Completion improvements

### ~/.config/starship.toml

Starship cross-shell prompt with:

- Git status integration

- Language version display (Python, Node, Rust, Go)

- Container/distrobox awareness

- Custom bazzite-ai theme

### ~/.config/ghostty/

Ghostty terminal emulator config:

- Font settings

- Color scheme

- Keybindings

- Window behavior

## Modern CLI Tools

The shell configs integrate these tools (installed by default):

| Tool | Replaces | Purpose |
|------|----------|---------|
| `eza` | `ls` | Modern ls with git integration |
| `bat` | `cat` | Syntax-highlighted cat |
| `ripgrep` | `grep` | Fast recursive search |
| `fd` | `find` | User-friendly find |
| `fzf` | - | Fuzzy finder |
| `zoxide` | `cd` | Smart directory jumping |
| `starship` | PS1 | Cross-shell prompt |

## Aliases Defined

```bash
# Common aliases in bashrc/zshrc
alias ls='eza'
alias ll='eza -la'
alias la='eza -a'
alias tree='eza --tree'
alias cat='bat --paging=never'
alias grep='rg'
alias find='fd'

```

## Skeleton Location

Default configs are stored in:

```

/etc/skel/
├── .bashrc
├── .zshrc
└── .config/
    ├── starship.toml
    └── ghostty/
        └── config

```

## Customization Strategy

1. **Start with defaults**: `ujust shell update`
2. **Check what's customized**: `ujust shell status`
3. **Make changes to your copy**: Edit `~/.bashrc` etc.
4. **Backup before updates**: Automatic with `ujust shell update`

## Reverting Customizations

```bash
# Update creates automatic backup
ujust shell update

# Find your backup
ls ~/.config-backup-shell-*

# Restore specific file
cp ~/.config-backup-shell-TIMESTAMP/.bashrc ~/.bashrc

```
