# bazzite-ai Plugin

Claude Code plugin for using Bazzite AI OS features via `ujust` commands.

## Purpose

This plugin provides skills for **OS users** who want to manage and configure Bazzite AI services, containers, and features using the `ujust` command system.

## Available Skills

| Skill | Command | Description |
|-------|---------|-------------|
| apptainer | `/bazzite-ai:apptainer` | Apptainer/Singularity container management |
| bootc | `/bazzite-ai:bootc` | Bootable container testing and management |
| comfyui | `/bazzite-ai:comfyui` | ComfyUI AI image generation server |
| configure | `/bazzite-ai:configure` | System configuration (services, GPU, etc.) |
| install | `/bazzite-ai:install` | System package and tool installation |
| jellyfin | `/bazzite-ai:jellyfin` | Jellyfin media server management |
| jupyter | `/bazzite-ai:jupyter` | JupyterLab server management |
| mirror | `/bazzite-ai:mirror` | Repository mirroring |
| ollama | `/bazzite-ai:ollama` | Ollama LLM inference server |
| runners | `/bazzite-ai:runners` | GitHub Actions self-hosted runners |
| shell | `/bazzite-ai:shell` | Shell configuration and customization |
| vm | `/bazzite-ai:vm` | Virtual machine management |

## Usage Examples

```bash
# Ask Claude to help with Ollama
/bazzite-ai:ollama
# Claude will guide you through Ollama setup, model management, etc.

# Configure JupyterLab
/bazzite-ai:jupyter
# Claude will help with JupyterLab installation, configuration, and troubleshooting

# Set up GPU containers
/bazzite-ai:configure
# Claude will guide you through GPU passthrough and container configuration
```

## Installation

### Manual Loading

```bash
claude --plugin-dir /path/to/bazzite-ai-testing/plugins/bazzite-ai
```

### Permanent Configuration

Add to your Claude Code settings:

```json
{
  "plugins": [
    "/path/to/bazzite-ai-testing/plugins/bazzite-ai"
  ]
}
```

## Requirements

- Bazzite AI OS installed
- `ujust` command available at `/usr/share/ublue-os/justfile`

## Related

- **bazzite-ai-dev**: Development tools for contributors (separate plugin)
- **Documentation**: <https://bazzite.ai/>
