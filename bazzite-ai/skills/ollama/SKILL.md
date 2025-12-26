---
name: ollama
description: |
  Ollama LLM inference server management via Podman Quadlet. Single-instance
  design with GPU acceleration for running local LLMs. Use when users need
  to configure Ollama, pull models, run inference, or manage the Ollama server.
---

# Ollama - Local LLM Inference Server

## Overview

The `ollama` command manages the Ollama LLM inference server using Podman Quadlet containers. It provides a single-instance server for running local LLMs with GPU acceleration.

**Key Concept:** Unlike Jupyter, Ollama uses a single-instance design because GPU memory is shared across all loaded models. The API is accessible at port 11434.

## Quick Reference

| Action | Command | Description |
|--------|---------|-------------|
| Config | `ujust ollama config [PORT] [GPU] [IMAGE] [WORKSPACE]` | Configure server |
| Start | `ujust ollama start` | Start server |
| Stop | `ujust ollama stop` | Stop server |
| Restart | `ujust ollama restart` | Restart server |
| Logs | `ujust ollama logs [LINES]` | View logs |
| Status | `ujust ollama status` | Show server status |
| Pull | `ujust ollama pull <MODEL>` | Download a model |
| List | `ujust ollama list` | List installed models |
| Run | `ujust ollama run <MODEL> [PROMPT]` | Run model |
| Shell | `ujust ollama shell [CMD]` | Open container shell |
| Delete | `ujust ollama delete` | Remove server and images |

## Parameters

### Config Parameters

```bash
ujust ollama config [PORT] [GPU_TYPE] [IMAGE] [WORKSPACE]
```

| Parameter | Default | Description |
|-----------|---------|-------------|
| `PORT` | `11434` | API port |
| `GPU_TYPE` | `auto` | GPU type: `nvidia`, `amd`, `intel`, `none`, `auto` |
| `IMAGE` | `stable` | Container image or tag |
| `WORKSPACE` | (empty) | Optional additional mount to /workspace |

## Configuration

```bash
# Default: Port 11434, auto-detect GPU
ujust ollama config

# Custom port with NVIDIA GPU
ujust ollama config 11435 nvidia

# CPU only
ujust ollama config 11434 none

# With workspace mount
ujust ollama config 11434 nvidia stable /home/user/projects

# Custom image
ujust ollama config 11434 nvidia "ghcr.io/custom/ollama:v1" /projects
```

### Update Existing Configuration

Running `config` when already configured will update the existing configuration, preserving values not explicitly changed.

### Shell Access

```bash
# Interactive bash shell
ujust ollama shell

# Run specific command
ujust ollama shell "nvidia-smi"
ujust ollama shell "df -h"
```

## Model Management

### Pull Models

```bash
# Download popular models
ujust ollama pull llama3.2
ujust ollama pull codellama
ujust ollama pull mistral
ujust ollama pull phi3

# Specific versions
ujust ollama pull llama3.2:7b
ujust ollama pull llama3.2:70b
```

### List Models

```bash
ujust ollama list
```

Output:

```
NAME              SIZE      MODIFIED
llama3.2:latest   4.7 GB    2 hours ago
codellama:latest  3.8 GB    1 day ago
```

### Run Models

```bash
# Interactive chat
ujust ollama run llama3.2

# Single prompt
ujust ollama run llama3.2 "Explain quantum computing"

# Code generation
ujust ollama run codellama "Write a Python function to sort a list"
```

## API Access

### Default Endpoint

```
http://localhost:11434
```

### API Examples

```bash
# Generate completion
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2",
  "prompt": "Hello, how are you?"
}'

# Chat
curl http://localhost:11434/api/chat -d '{
  "model": "llama3.2",
  "messages": [{"role": "user", "content": "Hello!"}]
}'

# List models
curl http://localhost:11434/api/tags
```

### Integration with Tools

```bash
# Claude Code with Ollama
export OLLAMA_HOST=http://localhost:11434

# LangChain
from langchain_community.llms import Ollama
llm = Ollama(model="llama3.2", base_url="http://localhost:11434")
```

## Volume Mounts

| Container Path | Host Path | Purpose |
|----------------|-----------|---------|
| `/root/.ollama` | `~/.ollama` | Model storage |

Models are persisted in `~/.ollama` and survive container restarts.

## Common Workflows

### Initial Setup

```bash
# 1. Configure Ollama with GPU
ujust ollama config 11434 nvidia

# 2. Start the server
ujust ollama start

# 3. Pull a model
ujust ollama pull llama3.2

# 4. Test it
ujust ollama run llama3.2 "Hello!"
```

### Development with Local LLM

```bash
# Start Ollama
ujust ollama start

# In your code, use:
# OLLAMA_HOST=http://localhost:11434
```

### Model Comparison

```bash
# Pull multiple models
ujust ollama pull llama3.2
ujust ollama pull mistral
ujust ollama pull phi3

# Compare responses
ujust ollama run llama3.2 "Explain REST APIs"
ujust ollama run mistral "Explain REST APIs"
ujust ollama run phi3 "Explain REST APIs"
```

## GPU Support

### Automatic Detection

```bash
ujust ollama config  # Auto-detects GPU
```

### Manual Selection

| GPU Type | Flag | VRAM Usage |
|----------|------|------------|
| NVIDIA | `nvidia` | Full GPU acceleration |
| AMD | `amd` | ROCm acceleration |
| Intel | `intel` | oneAPI acceleration |
| None | `none` | CPU only (slower) |

### Check GPU Status

```bash
ujust ollama shell "nvidia-smi"  # NVIDIA
ujust ollama shell "rocm-smi"    # AMD
```

## Model Size Guide

| Model | Parameters | VRAM Needed | Quality |
|-------|------------|-------------|---------|
| phi3 | 3B | 4GB | Fast, basic |
| llama3.2 | 8B | 8GB | Balanced |
| mistral | 7B | 8GB | Good coding |
| codellama | 7B | 8GB | Code-focused |
| llama3.2:70b | 70B | 48GB+ | Best quality |

## Troubleshooting

### Server Won't Start

**Check:**

```bash
systemctl --user status ollama
ujust ollama logs 50
```

**Common causes:**

- Port 11434 already in use
- GPU driver issues
- Image not pulled

### Model Loading Fails

**Symptom:** "out of memory" or slow loading

**Cause:** Model too large for GPU VRAM

**Fix:**

```bash
# Use smaller model
ujust ollama pull phi3  # Only 4GB VRAM

# Or use quantized version
ujust ollama pull llama3.2:7b-q4_0
```

### GPU Not Used

**Symptom:** Inference very slow

**Check:**

```bash
ujust ollama status
ujust ollama shell "nvidia-smi"
```

**Fix:**

```bash
# Reconfigure with explicit GPU
ujust ollama delete
ujust ollama config 11434 nvidia
```

### API Not Responding

**Symptom:** `curl localhost:11434` fails

**Check:**

```bash
ujust ollama status
ujust ollama logs
```

**Fix:**

```bash
ujust ollama restart
```

## Cross-References

- **Related Skills:** `configure gpu-containers` (GPU setup), `jupyter` (ML development)
- **API Docs:** [https://ollama.ai/docs](https://ollama.ai/docs)
- **Model Library:** [https://ollama.ai/library](https://ollama.ai/library)

## When to Use This Skill

Use when the user asks about:

- "install ollama", "setup local LLM", "run LLM locally"
- "pull model", "download llama", "get mistral"
- "ollama not working", "model won't load"
- "ollama GPU", "ollama cuda", "ollama slow"
- "ollama API", "integrate with ollama"
