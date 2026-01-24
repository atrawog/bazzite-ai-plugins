# Bazzite AI Plugins

Claude Code plugin marketplace for Bazzite AI - an AI/ML-focused immutable Linux OS.

## Available Plugins

| Plugin | Description | Audience |
|--------|-------------|----------|
| **bazzite-ai** | OS features via `ujust` commands | Users of Bazzite AI |
| **bazzite-ai-dev** | Development tools and enforcement agents | Contributors |

## Installation

### Method 1: Marketplace (Recommended)

```bash
# Add the marketplace
/plugin marketplace add atrawog/bazzite-ai-plugins

# Install plugins
/plugin install bazzite-ai@bazzite-ai-plugins
/plugin install bazzite-ai-dev@bazzite-ai-plugins
```

### Method 2: Team Configuration

Add to your Claude Code settings (`.claude/settings.json`):

```json
{
  "extraKnownMarketplaces": {
    "bazzite-ai-plugins": {
      "source": {
        "source": "github",
        "repo": "atrawog/bazzite-ai-plugins"
      }
    }
  },
  "enabledPlugins": {
    "bazzite-ai@bazzite-ai-plugins": true,
    "bazzite-ai-dev@bazzite-ai-plugins": true
  }
}
```

### Method 3: Manual Loading

```bash
# Clone the repository
git clone https://github.com/atrawog/bazzite-ai-plugins.git

# Load plugins
claude --plugin-dir ./bazzite-ai-plugins/bazzite-ai
claude --plugin-dir ./bazzite-ai-plugins/bazzite-ai-dev
```

## Plugin Details

### bazzite-ai (OS Users)

Skills for using Bazzite AI OS features via `ujust` commands:

- **apptainer** - Apptainer/Singularity container management
- **bootc** - Bootable container testing and management
- **comfyui** - ComfyUI AI image generation server
- **config** - System configuration (services, GPU, shell, etc.)
- **deploy** - Helm deployments to k3d clusters
- **fiftyone** - FiftyOne dataset visualization
- **install** - System package and tool installation
- **jellyfin** - Jellyfin media server management
- **jupyter** - JupyterLab server management
- **k3d** - Lightweight Kubernetes clusters
- **localai** - LocalAI OpenAI-compatible inference
- **ollama** - Ollama LLM inference server
- **openwebui** - Open WebUI chat interface
- **pods** - Pod container management
- **portainer** - Portainer container management UI
- **record** - Terminal recording for documentation
- **runners** - GitHub Actions self-hosted runners
- **tailscale** - Tailscale mesh VPN service exposure
- **test** - Test suite commands
- **vm** - Virtual machine management

**Usage:**

```bash
/bazzite-ai:ollama     # Help with Ollama setup
/bazzite-ai:jupyter    # Help with JupyterLab
/bazzite-ai:config     # System configuration guidance
```

### bazzite-ai-dev (Developers)

Development tools and enforcement agents for Bazzite AI contributors:

**Skills:**

- **build** - OS image building with Podman
- **clean** - Cleanup build artifacts and caches
- **lfs** - Git LFS file management
- **overlay** - Overlay testing session management
- **record** - Terminal recording for documentation
- **test** - Test commands and validation

**Enforcement Agents:**

- **policy-enforcer** - Verifies all policy compliance
- **root-cause-analyzer** - Mandatory 8-step error analysis
- **testing-validator** - Confirms LOCAL testing completed
- **justfile-validator** - Validates non-interactive support
- **pre-commit-guardian** - Ensures 100% hook pass rate
- **documentation-validator** - Validates MyST syntax
- **config-integrity-enforcer** - Blocks editing output configs
- **pixi-lock-enforcer** - Blocks manual lock edits
- **sudo-usage-enforcer** - Blocks external sudo elevation
- **overlay-testing-enforcer** - Blocks direct justfile testing
- **architecture-advisor** - Explains immutable OS design
- **buildcache-validator** - Analyzes build cache impact
- **code-research** - Deep codebase analysis
- **github-actions** - Reports workflow status

**Usage:**

```bash
/bazzite-ai-dev:build  # Help with OS image building
/bazzite-ai-dev:test   # Set up overlay testing
/bazzite-ai-dev:clean  # Clean build artifacts
```

## Documentation

- **Full Documentation:** <https://bazzite.ai/>
- **Main Repository:** <https://github.com/atrawog/bazzite-ai>

## License

MIT
