# bazzite-ai-ollama

Ollama API operations for LLM inference, embeddings, and model management.

## Overview

This plugin provides skills for **API-level Ollama operations** - using Python libraries and REST APIs to interact with Ollama for inference, embeddings, and model management.

This plugin is designed to work with the `bazzite-ai-pod-ollama` container or any Ollama server.

## Skills

| Skill | Description |
|-------|-------------|
| `api` | Direct REST API operations using requests library |
| `python` | Official `ollama` Python library usage |
| `openai` | OpenAI compatibility layer for migration |
| `gpu` | GPU monitoring, VRAM usage, and inference metrics |
| `huggingface` | Import GGUF models from HuggingFace |

## Prerequisites

- Ollama server running (default: `http://localhost:11434` or `OLLAMA_HOST` env var)
- Model available (pull via API: `POST /api/pull` with `{"name": "llama3.2:latest"}`)

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

## Related Plugins

- `bazzite-ai-jupyter` - ML/AI development workflows (if running bazzite-ai-pod-jupyter)
