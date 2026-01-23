# bazzite-ai Plugin

Claude Code plugin for using Bazzite AI OS features via `ujust` commands.

## Purpose

This plugin provides skills for **OS users** who want to manage and configure Bazzite AI services, containers, and features using the `ujust` command system.

## Available Skills (20)

| Skill | Command | Description |
|-------|---------|-------------|
| apptainer | `/bazzite-ai:apptainer` | Apptainer/Singularity HPC container management |
| bootc | `/bazzite-ai:bootc` | Bootable container testing and management |
| comfyui | `/bazzite-ai:comfyui` | ComfyUI AI image generation server |
| config | `/bazzite-ai:config` | System configuration (services, GPU, Docker, etc.) |
| deploy | `/bazzite-ai:deploy` | Helm deployments to k3d (JupyterHub, KubeAI) |
| fiftyone | `/bazzite-ai:fiftyone` | FiftyOne dataset visualization and management |
| install | `/bazzite-ai:install` | System package and Flatpak installation |
| jellyfin | `/bazzite-ai:jellyfin` | Jellyfin media server management |
| jupyter | `/bazzite-ai:jupyter` | JupyterLab server management |
| k3d | `/bazzite-ai:k3d` | Lightweight Kubernetes clusters in Podman |
| localai | `/bazzite-ai:localai` | LocalAI inference server |
| ollama | `/bazzite-ai:ollama` | Ollama LLM inference server |
| openwebui | `/bazzite-ai:openwebui` | Open WebUI chat interface for Ollama |
| pods | `/bazzite-ai:pods` | Pod container lifecycle management |
| portainer | `/bazzite-ai:portainer` | Portainer container management UI |
| record | `/bazzite-ai:record` | Terminal recording with asciinema |
| runners | `/bazzite-ai:runners` | GitHub Actions self-hosted runners |
| tailscale | `/bazzite-ai:tailscale` | Tailscale service exposure |
| test | `/bazzite-ai:test` | Testing and verification commands |
| vm | `/bazzite-ai:vm` | Virtual machine management |

## Usage Examples

```bash
# Ask Claude to help with Ollama
/bazzite-ai:ollama
# Claude will guide you through Ollama setup, model management, etc.

# Configure JupyterLab
/bazzite-ai:jupyter
# Claude will help with JupyterLab installation, configuration, and troubleshooting

# Set up GPU containers and system services
/bazzite-ai:config
# Claude will guide you through GPU passthrough and service configuration

# Deploy applications to Kubernetes
/bazzite-ai:deploy
# Claude will help deploy JupyterHub or KubeAI to k3d clusters
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
