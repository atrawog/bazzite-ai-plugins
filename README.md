# Bazzite AI Plugins

Claude Code plugin marketplace for [Bazzite AI](https://github.com/atrawog/bazzite-ai) - an AI/ML-focused immutable Linux OS.

## Which Plugins Do I Need?

| You are... | Install these plugins |
|------------|----------------------|
| **Bazzite OS user** | `bazzite` - Base OS features (gaming, GPU, storage, etc.) |
| **Bazzite AI user** | `bazzite` + `bazzite-ai` - AI/ML services (Ollama, JupyterLab, etc.) |
| **Using bazzite-ai-jupyter pod** | `bazzite-ai` + `bazzite-ai-jupyter` - ML workflows in Jupyter notebooks |
| **Contributing to Bazzite AI** | All plugins including `bazzite-ai-dev` - Development tools & enforcement |

## Available Plugins

| Plugin | Description | Skills | Agents | MCP | Audience |
|--------|-------------|--------|--------|-----|----------|
| **bazzite** | Base Bazzite OS features | 12 | - | - | All Bazzite users |
| **bazzite-ai** | AI/ML service management via ujust | 20 | - | - | Bazzite AI users |
| **bazzite-ai-jupyter** | ML workflows for Jupyter notebooks | 20 | - | Jupyter | Data scientists using jupyter pod |
| **bazzite-ai-dev** | Development tools & enforcement | 6 | 14 | GitHub | Contributors |

## Installation

### Method 1: Marketplace (Recommended)

```bash
# Add the marketplace
/plugin marketplace add atrawog/bazzite-ai-plugins

# Install plugins (choose what you need)
/plugin install bazzite@bazzite-ai-plugins           # Base OS features
/plugin install bazzite-ai@bazzite-ai-plugins        # AI/ML services
/plugin install bazzite-ai-jupyter@bazzite-ai-plugins # ML workflows
/plugin install bazzite-ai-dev@bazzite-ai-plugins    # Development tools
```

### Method 2: Team Configuration

Add to your Claude Code settings (`.claude/settings.json`):

```json
{
  "extraKnownMarketplaces": {
    "bazzite-ai-plugins": {
      "source": { "source": "github", "repo": "atrawog/bazzite-ai-plugins" }
    }
  },
  "enabledPlugins": {
    "bazzite@bazzite-ai-plugins": true,
    "bazzite-ai@bazzite-ai-plugins": true,
    "bazzite-ai-jupyter@bazzite-ai-plugins": true,
    "bazzite-ai-dev@bazzite-ai-plugins": true
  }
}
```

### Method 3: Manual Loading

```bash
# Clone the repository
git clone https://github.com/atrawog/bazzite-ai-plugins.git

# Load plugins
claude --plugin-dir ./bazzite-ai-plugins/bazzite
claude --plugin-dir ./bazzite-ai-plugins/bazzite-ai
claude --plugin-dir ./bazzite-ai-plugins/bazzite-ai-jupyter
claude --plugin-dir ./bazzite-ai-plugins/bazzite-ai-dev
```

## Plugin Details

### bazzite (Base OS)

Skills for base Bazzite OS configuration and management:

| Skill | Description |
|-------|-------------|
| **apps** | Third-party apps (CoolerControl, JetBrains, OpenRazer, DisplayLink, scrcpy) |
| **audio** | Audio configuration (virtual channels, surround sound, PipeWire) |
| **boot** | Boot configuration (BIOS/UEFI, GRUB, secure boot, dual-boot) |
| **desktop** | Desktop customization (GTK themes, terminal transparency) |
| **distrobox** | Container management (manifests, DaVinci Resolve) |
| **gaming** | Gaming ecosystem (Steam, Proton, EmuDeck, Decky, Sunshine) |
| **gpu** | GPU drivers (NVIDIA proprietary, Optimus, NVK, Mesa) |
| **network** | Network configuration (iwd WiFi, Wake-on-LAN, Tailscale) |
| **security** | Security (LUKS/TPM auto-unlock, secure boot, FIDO2) |
| **storage** | Storage management (automount, BTRFS deduplication, snapshots) |
| **system** | System maintenance (updates, cleanup, logs, diagnostics) |
| **virtualization** | GPU passthrough (KVM, VFIO, Looking Glass, USB hotplug) |

**Usage:**

```bash
/bazzite:gaming    # Gaming setup help
/bazzite:gpu       # GPU driver guidance
/bazzite:storage   # Storage management
```

### bazzite-ai (AI/ML Services)

Skills for managing AI/ML services via `ujust` commands:

| Skill | Description |
|-------|-------------|
| **apptainer** | Apptainer/Singularity HPC container management |
| **bootc** | Bootable container testing via bcvk |
| **comfyui** | ComfyUI node-based Stable Diffusion interface |
| **config** | System configuration dispatcher (services, GPU, desktop) |
| **deploy** | Helm deployments to k3d (JupyterHub, KubeAI) |
| **fiftyone** | FiftyOne dataset visualization with MongoDB sidecar |
| **install** | Development tool installation (Claude Code, pixi, etc.) |
| **jellyfin** | Jellyfin media server with hardware transcoding |
| **jupyter** | JupyterLab ML/AI development environment |
| **k3d** | Lightweight k3s Kubernetes clusters in Podman |
| **localai** | LocalAI OpenAI-compatible inference API |
| **ollama** | Ollama LLM inference server with GPU acceleration |
| **openwebui** | Open WebUI chat interface for Ollama |
| **pods** | Aggregate pod service management |
| **portainer** | Portainer CE container management UI |
| **record** | Terminal recording with asciinema |
| **runners** | Self-hosted GitHub Actions runners with GPU |
| **tailscale** | Tailscale Serve for service exposure |
| **test** | Runtime verification tests (GPU, CUDA, PyTorch) |
| **vm** | QCOW2 virtual machine management via libvirt |

**Usage:**

```bash
/bazzite-ai:ollama   # Ollama setup and management
/bazzite-ai:jupyter  # JupyterLab configuration
/bazzite-ai:k3d      # Kubernetes cluster help
```

### bazzite-ai-dev (Development)

Development tools and enforcement agents for contributors.

**Skills (6):**

| Skill | Description |
|-------|-------------|
| **build** | Unified build system for OS images, pods, VMs, ISOs |
| **clean** | Cleanup build artifacts, caches, and temporary files |
| **lfs** | Git LFS file management (checkout, status, locking) |
| **overlay** | Overlay session management for live justfile editing |
| **record** | Batch recording system for documentation |
| **test** | Runtime verification tests for installations |

**Enforcement Agents (14):**

*BLOCKING (must pass before proceeding):*

| Agent | Trigger | Function |
|-------|---------|----------|
| **policy-enforcer** | Before Edit/Write, commits | Verifies all 11 policy rules |
| **root-cause-analyzer** | Any error in output | Mandatory 8-step error investigation |
| **testing-validator** | Claiming "working" | Confirms LOCAL system testing done |
| **justfile-validator** | Editing .just files | Validates non-interactive support, <30K |
| **pre-commit-guardian** | Before git commit | Ensures 100% hook pass rate |
| **documentation-validator** | Editing docs/*.md | Validates MyST syntax, myst.yml |
| **config-integrity-enforcer** | Editing ~/.config/* | Blocks - edit source code instead |
| **pixi-lock-enforcer** | Editing pixi.lock | Blocks - run `pixi install` instead |
| **sudo-usage-enforcer** | `sudo ujust` detected | Blocks external sudo elevation |
| **overlay-testing-enforcer** | `just -f` for testing | Blocks - use overlay method |

*ADVISORY (guidance only):*

| Agent | Trigger | Function |
|-------|---------|----------|
| **architecture-advisor** | "Why?" questions | Explains immutable OS design decisions |
| **buildcache-validator** | Build file changes | Analyzes build cache performance impact |
| **code-research** | Architectural "how" | Deep codebase analysis |
| **github-actions** | CI status queries | Reports workflow status and failures |

**MCP Server: GitHub**

Provides 22 tools via `mcp__github__*` for GitHub integration:

| Category | Tools |
|----------|-------|
| Issues | `issue_read`, `issue_write`, `add_issue_comment`, `list_issues`, `search_issues`, `list_issue_types`, `sub_issue_write` |
| Pull Requests | `pull_request_read`, `list_pull_requests`, `search_pull_requests` |
| Workflows | `list_workflows`, `list_workflow_runs`, `get_workflow_run`, `list_workflow_jobs`, `get_job_logs` |
| Repository | `get_file_contents`, `list_commits`, `get_commit`, `list_branches`, `get_me` |
| Labels | `get_label`, `list_label`, `label_write` |

**Usage:**

```bash
/bazzite-ai-dev:build   # OS image building
/bazzite-ai-dev:test    # Set up overlay testing
/bazzite-ai-dev:clean   # Clean build artifacts
```

### bazzite-ai-jupyter (ML Workflows)

Skills for machine learning workflows in Jupyter notebooks.

**MCP Server: Jupyter**

Provides 14 tools via `mcp__jupyter__*` for direct notebook interaction:

| Tool | Function |
|------|----------|
| `list_files` | List files in Jupyter server filesystem |
| `list_kernels` | List available kernels |
| `use_notebook` | Activate notebook for operations |
| `list_notebooks` | List activated notebooks |
| `read_notebook` | Read notebook cells and structure |
| `read_cell` | Read specific cell details |
| `insert_cell` | Insert new cells |
| `overwrite_cell_source` | Modify cell contents |
| `delete_cell` | Delete cells |
| `execute_cell` | Execute notebook cells |
| `insert_execute_code_cell` | Insert and execute combined |
| `execute_code` | Execute code directly in kernel |
| `restart_notebook` | Restart notebook kernel |
| `unuse_notebook` | Release notebook resources |

**Skills (20):**

*Ollama Integration:*

| Skill | Description |
|-------|-------------|
| **chat** | Direct REST API operations using requests library |
| **ollama** | Official ollama Python library for LLM inference |
| **openai** | OpenAI compatibility layer for Ollama |
| **gpu** | GPU monitoring, VRAM usage, inference metrics |
| **huggingface** | Import GGUF models from HuggingFace |

*ML/AI Development:*

| Skill | Description |
|-------|-------------|
| **langchain** | LangChain framework - prompts, chains, model wrappers |
| **rag** | Retrieval-Augmented Generation with vector stores |
| **evaluation** | LLM evaluation with Evidently.ai |
| **transformers** | Transformer architecture concepts |
| **finetuning** | Fine-tuning with PyTorch and HuggingFace Trainer |

*Training & Optimization:*

| Skill | Description |
|-------|-------------|
| **quantization** | Model quantization (GPTQ, AWQ, INT8) |
| **peft** | Parameter-efficient fine-tuning (LoRA, Unsloth) |
| **sft** | Supervised Fine-Tuning with SFTTrainer |
| **qlora** | Advanced QLoRA experiments |

*RLHF:*

| Skill | Description |
|-------|-------------|
| **dpo** | Direct Preference Optimization |
| **grpo** | Group Relative Policy Optimization |
| **rloo** | Reinforcement Learning with Leave-One-Out |
| **reward** | Reward model training for RLHF pipelines |

*Inference & Vision:*

| Skill | Description |
|-------|-------------|
| **inference** | Fast inference with vLLM, thinking model parsing |
| **vision** | Vision model fine-tuning with FastVisionModel |

**Usage:**

```bash
/bazzite-ai-jupyter:sft     # Supervised fine-tuning guide
/bazzite-ai-jupyter:qlora   # QLoRA training help
/bazzite-ai-jupyter:rag     # RAG implementation
```

## Documentation

- **Main Repository:** <https://github.com/atrawog/bazzite-ai>
- **Full Documentation:** <https://bazzite.ai/>

## Summary

### Component Totals

| Component | Count |
|-----------|-------|
| **Plugins** | 4 |
| **Skills** | 58 |
| **Agents** | 14 (10 blocking + 4 advisory) |
| **MCP Servers** | 2 |
| **MCP Tools** | 36 (GitHub: 22, Jupyter: 14) |

### Skills by Plugin

| Plugin | Skills | Description |
|--------|--------|-------------|
| bazzite | 12 | Base OS features |
| bazzite-ai | 20 | AI/ML service management |
| bazzite-ai-jupyter | 20 | ML workflows in Jupyter |
| bazzite-ai-dev | 6 | Development tools |
| **Total** | **58** | |

### Quick Reference

| Task | Plugin | Skill |
|------|--------|-------|
| Gaming setup | bazzite | `/bazzite:gaming` |
| GPU drivers | bazzite | `/bazzite:gpu` |
| Ollama server | bazzite-ai | `/bazzite-ai:ollama` |
| JupyterLab | bazzite-ai | `/bazzite-ai:jupyter` |
| Fine-tuning | bazzite-ai-jupyter | `/bazzite-ai-jupyter:sft` |
| Build OS image | bazzite-ai-dev | `/bazzite-ai-dev:build` |

## License

MIT
