---
name: localai
description: |
  LocalAI local inference API management via Podman Quadlet. Provides an
  OpenAI-compatible API for local model inference with GPU acceleration.
  Use when users need to configure, start, or manage the LocalAI service.
---

# LocalAI - Local AI Inference API

## Overview

The `localai` command manages the LocalAI service using Podman Quadlet containers. It provides an OpenAI-compatible API for running AI models locally with GPU acceleration.

**Key Features:**

- OpenAI-compatible API endpoints
- GPU-specific container images (auto-selected)
- Multiple GPU support (NVIDIA, AMD, Intel)
- Cross-pod DNS via `bazzite-ai` network

## Quick Reference

| Action | Command | Description |
|--------|---------|-------------|
| Config | `ujust localai config [--port=...] [--bind=...]` | Configure instance |
| Start | `ujust localai start [--instance=...]` | Start service |
| Stop | `ujust localai stop [--instance=...]` | Stop service |
| Restart | `ujust localai restart [--instance=...]` | Restart service |
| Logs | `ujust localai logs [--lines=...]` | View logs |
| Status | `ujust localai status [--instance=...]` | Show status |
| URL | `ujust localai url [--instance=...]` | Show API URL |
| List | `ujust localai list` | List instances |
| Shell | `ujust localai shell [-- CMD...]` | Container shell |
| Delete | `ujust localai delete [--instance=...]` | Remove service |

## Parameters

| Parameter | Long Flag | Short | Default | Description |
|-----------|-----------|-------|---------|-------------|
| Port | `--port` | `-p` | `8080` | Host port for API |
| Image | `--image` | `-i` | (auto by GPU) | Container image |
| Tag | `--tag` | `-t` | `latest` | Image tag |
| Bind | `--bind` | `-b` | `127.0.0.1` | Bind address |
| Config Dir | `--config-dir` | `-c` | `~/.config/localai/1` | Config/models directory |
| Workspace | `--workspace-dir` | `-w` | (empty) | Workspace mount |
| GPU Type | `--gpu-type` | `-g` | `auto` | GPU type |
| Instance | `--instance` | `-n` | `1` | Instance number or `all` |
| Lines | `--lines` | `-l` | `50` | Log lines to show |

## GPU-Specific Images

LocalAI uses different container images optimized for each GPU type:

| GPU Type | Image | Auto-Selected? |
|----------|-------|----------------|
| CPU (none) | `localai/localai:latest` | Yes |
| NVIDIA | `localai/localai:latest-gpu-nvidia-cuda-12` | Yes |
| AMD | `localai/localai:latest-gpu-hipblas` | Yes |
| Intel | `localai/localai:latest-gpu-intel` | Yes |

The appropriate image is automatically selected based on detected GPU hardware.

## Configuration

```bash
# Default configuration (auto-detects GPU, port 8080)
ujust localai config

# Custom port (long form)
ujust localai config --port=8081

# Custom port (short form)
ujust localai config -p 8081

# Network-wide access
ujust localai config --bind=0.0.0.0

# Force CPU image (ignore GPU)
ujust localai config --image=localai/localai:latest

# Combine parameters (long form)
ujust localai config --port=8081 --bind=0.0.0.0

# Combine parameters (short form)
ujust localai config -p 8081 -b 0.0.0.0
```

### Update Existing Configuration

Running `config` when already configured updates the existing settings:

```bash
# Change only the bind address
ujust localai config --bind=0.0.0.0

# Update port without affecting other settings
ujust localai config --port=8082
```

## Lifecycle Management

```bash
# Start LocalAI
ujust localai start

# Stop service
ujust localai stop

# Restart (apply config changes)
ujust localai restart

# View logs (default 50 lines)
ujust localai logs

# View more logs (long form)
ujust localai logs --lines=200

# View more logs (short form)
ujust localai logs -l 200

# Check status
ujust localai status

# Show API URL
ujust localai url
```

## Multi-Instance Support

```bash
# Start all instances (long form)
ujust localai start --instance=all

# Start all instances (short form)
ujust localai start -n all

# Stop specific instance
ujust localai stop --instance=2

# Delete all instances
ujust localai delete --instance=all
```

## Shell Access

```bash
# Interactive shell
ujust localai shell

# Run specific command (use -- separator)
ujust localai shell -- ls -la /models
ujust localai shell -- nvidia-smi
```

## Network Architecture

LocalAI uses the `bazzite-ai` bridge network for cross-container DNS:

```
+-------------------+     DNS      +-------------------+
|   Open WebUI      | -----------> |     LocalAI       |
|   (openwebui)     |              |    (localai)      |
|   Port 3000       |              |   Port 8080       |
+-------------------+              +-------------------+
         |                                  |
         +------ bazzite-ai network --------+
                         |
+-------------------+    |    +-------------------+
|     Ollama        |----+----+     Jupyter       |
|    (ollama)       |         |    (jupyter)      |
|   Port 11434      |         |   Port 8888       |
+-------------------+         +-------------------+
```

**Cross-Pod DNS:**

- LocalAI accessible as `http://localai:8080` from other containers
- Can replace Ollama as backend for OpenWebUI

## API Endpoints (OpenAI-Compatible)

| Endpoint | Description |
|----------|-------------|
| `/v1/models` | List available models |
| `/v1/chat/completions` | Chat completions |
| `/v1/completions` | Text completions |
| `/v1/embeddings` | Generate embeddings |
| `/v1/images/generations` | Image generation |
| `/v1/audio/transcriptions` | Speech-to-text |

### Example API Usage

```bash
# List models
curl http://localhost:8080/v1/models

# Chat completion
curl http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

## Model Storage

| Path | Description |
|------|-------------|
| `~/.config/localai/<INSTANCE>/models` | Model files |

Models persist across container restarts. Each instance has isolated storage.

### Loading Models

Place model files (GGUF, GGML) in the models directory:

```bash
# Copy a model
cp my-model.gguf ~/.config/localai/1/models/

# Or download directly
curl -L -o ~/.config/localai/1/models/model.gguf \
  https://huggingface.co/.../model.gguf
```

## Common Workflows

### Initial Setup

```bash
# 1. Configure LocalAI (auto-detects GPU)
ujust localai config

# 2. Start the service
ujust localai start

# 3. Check the API
ujust localai url
# Output: http://127.0.0.1:8080

# 4. Test the API
curl http://localhost:8080/v1/models
```

### Use with OpenWebUI

OpenWebUI can use LocalAI as an OpenAI-compatible backend:

```bash
# Start LocalAI
ujust localai start

# In OpenWebUI settings, add connection:
# URL: http://localai:8080/v1  (cross-pod DNS)
# Or: http://host.containers.internal:8080/v1  (from host)
```

### Remote Access Setup

```bash
# Configure for network access
ujust localai config --bind=0.0.0.0

# Start the service
ujust localai start

# Or use Tailscale for secure access
ujust tailscale serve --service=localai
```

## GPU Support

GPU is automatically detected and the appropriate image is selected:

| GPU Type | Detection | Device Passthrough |
|----------|-----------|-------------------|
| NVIDIA | `nvidia-smi` | CDI (`nvidia.com/gpu=all`) |
| AMD | lspci | `/dev/dri` + `/dev/kfd` |
| Intel | lspci | `/dev/dri` |

### Check GPU in Container

```bash
# NVIDIA
ujust localai shell -- nvidia-smi

# Check GPU environment
ujust localai shell -- env | grep -i gpu
```

## Troubleshooting

### Service Won't Start

```bash
# Check status
ujust localai status

# View logs
ujust localai logs --lines=100

# Check image was pulled
podman images | grep localai
```

**Common causes:**

- Port 8080 already in use
- Container image not pulled
- GPU driver issues

### GPU Not Detected

**NVIDIA:**

```bash
# Check CDI configuration
nvidia-ctk cdi list

# Regenerate CDI spec
sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
```

**AMD:**

```bash
# Check /dev/kfd exists
ls -la /dev/kfd

# Check ROCm
rocminfo
```

### API Errors

```bash
# Test API endpoint
curl http://localhost:8080/v1/models

# Check logs for errors
ujust localai logs --lines=100
```

### Clear Data and Start Fresh

```bash
# Delete everything
ujust localai delete --instance=all

# Reconfigure
ujust localai config
ujust localai start
```

## Cross-References

- **Network peers:** ollama, openwebui, jupyter, comfyui (all use bazzite-ai network)
- **Alternative:** `ollama` (simpler model management, different API)
- **Client:** `openwebui` (can use LocalAI as backend)
- **Docs:** [LocalAI Documentation](https://localai.io/)

## When to Use This Skill

Use when the user asks about:

- "install localai", "setup local inference", "openai-compatible api"
- "configure localai", "change port", "gpu acceleration"
- "localai not working", "api error", "model loading"
- "localai logs", "debug localai"
- "delete localai", "uninstall"
