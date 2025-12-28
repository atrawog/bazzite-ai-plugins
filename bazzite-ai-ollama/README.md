# bazzite-ai-ollama

Ollama API operations for LLM inference, embeddings, and model management.

## Overview

This plugin provides skills for **API-level Ollama operations** - using Python libraries and REST APIs to interact with Ollama for inference, embeddings, and model management.

**Note:** For server management (start/stop/config), see `bazzite-ai:ollama`.

## Skills

| Skill | Description |
|-------|-------------|
| `api` | Direct REST API operations using requests library |
| `python` | Official `ollama` Python library usage |
| `openai` | OpenAI compatibility layer for migration |
| `gpu` | GPU monitoring, VRAM usage, and inference metrics |
| `huggingface` | Import GGUF models from HuggingFace |

## Prerequisites

- Ollama server running: `ujust ollama start`
- Model pulled: `ujust ollama pull llama3.2`

## Quick Start

```python
import ollama

# Generate text
result = ollama.generate(model="llama3.2:latest", prompt="Hello!")
print(result["response"])

# Chat completion
response = ollama.chat(
    model="llama3.2:latest",
    messages=[{"role": "user", "content": "What is Python?"}]
)
print(response["message"]["content"])
```

## Related Skills

- `bazzite-ai:ollama` - Server management via ujust commands
- `bazzite-ai:jupyter` - ML development environment
- `bazzite-ai:configure` - GPU container setup
