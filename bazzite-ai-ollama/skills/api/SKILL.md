---
name: api
description: |
  Direct REST API operations for Ollama using the requests library.
  Covers all /api/* endpoints for model management, text generation,
  chat completion, embeddings, and streaming responses.
---

# Ollama REST API

## Overview

The Ollama REST API provides direct HTTP access to all Ollama functionality. Use the `requests` library for maximum control over API interactions.

**Default Endpoint:** `http://localhost:11434` (or `http://ollama:11434` in containers)

## Quick Reference

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/tags` | GET | List available models |
| `/api/show` | POST | Show model details |
| `/api/ps` | GET | List running models |
| `/api/generate` | POST | Generate text |
| `/api/chat` | POST | Chat completion |
| `/api/embed` | POST | Generate embeddings |
| `/api/copy` | POST | Copy a model |
| `/api/delete` | DELETE | Delete a model |

## Setup

```python
import os
import requests
import json

OLLAMA_HOST = os.getenv("OLLAMA_HOST", "http://localhost:11434")
```

## List Models

```python
response = requests.get(f"{OLLAMA_HOST}/api/tags")
models = response.json()

for model in models.get("models", []):
    size_gb = model.get("size", 0) / (1024**3)
    print(f"  - {model['name']} ({size_gb:.2f} GB)")
```

## Show Model Details

```python
response = requests.post(
    f"{OLLAMA_HOST}/api/show",
    json={"model": "llama3.2:latest"}
)
model_info = response.json()

details = model_info.get("details", {})
print(f"Family: {details.get('family', 'N/A')}")
print(f"Parameter Size: {details.get('parameter_size', 'N/A')}")
print(f"Quantization: {details.get('quantization_level', 'N/A')}")
```

## List Running Models

```python
response = requests.get(f"{OLLAMA_HOST}/api/ps")
running = response.json()

for model in running.get("models", []):
    name = model.get("name", "Unknown")
    size = model.get("size", 0) / (1024**3)
    vram = model.get("size_vram", 0) / (1024**3)
    print(f"  - {name}: {size:.2f} GB (VRAM: {vram:.2f} GB)")
```

## Generate Text

### Non-Streaming

```python
response = requests.post(
    f"{OLLAMA_HOST}/api/generate",
    json={
        "model": "llama3.2:latest",
        "prompt": "Why is the sky blue?",
        "stream": False
    }
)
result = response.json()
print(result["response"])
```

### Streaming

```python
response = requests.post(
    f"{OLLAMA_HOST}/api/generate",
    json={
        "model": "llama3.2:latest",
        "prompt": "Count from 1 to 5.",
        "stream": True
    },
    stream=True
)

for line in response.iter_lines():
    if line:
        chunk = json.loads(line)
        print(chunk.get("response", ""), end="", flush=True)
        if chunk.get("done"):
            break
```

## Chat Completion

```python
response = requests.post(
    f"{OLLAMA_HOST}/api/chat",
    json={
        "model": "llama3.2:latest",
        "messages": [
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": "What is Python?"}
        ],
        "stream": False
    }
)
result = response.json()
print(result["message"]["content"])
```

## Generate Embeddings

```python
response = requests.post(
    f"{OLLAMA_HOST}/api/embed",
    json={
        "model": "llama3.2:latest",
        "input": "Ollama makes running LLMs locally easy."
    }
)
result = response.json()
embeddings = result.get("embeddings", [[]])[0]
print(f"Dimensions: {len(embeddings)}")
```

## Copy Model

```python
response = requests.post(
    f"{OLLAMA_HOST}/api/copy",
    json={
        "source": "llama3.2:latest",
        "destination": "llama3.2-backup:latest"
    }
)
if response.status_code == 200:
    print("Copy successful!")
```

## Delete Model

```python
response = requests.delete(
    f"{OLLAMA_HOST}/api/delete",
    json={"model": "llama3.2-backup:latest"}
)
if response.status_code == 200:
    print("Delete successful!")
```

## Error Handling

```python
try:
    response = requests.post(
        f"{OLLAMA_HOST}/api/generate",
        json={"model": "nonexistent", "prompt": "Hello"},
        timeout=30
    )
    if response.status_code != 200:
        print(f"Error: {response.status_code} - {response.text}")
    else:
        result = response.json()
        if "error" in result:
            print(f"API Error: {result['error']}")
except requests.exceptions.ConnectionError:
    print("Cannot connect to Ollama. Ensure server is running at OLLAMA_HOST")
except requests.exceptions.Timeout:
    print("Request timed out")
```

## Connection Health Check

```python
def check_ollama_health(model="llama3.2:latest"):
    """Check if Ollama server is running and model is available."""
    try:
        response = requests.get(f"{OLLAMA_HOST}/api/tags", timeout=5)
        if response.status_code == 200:
            models = response.json()
            model_names = [m.get("name", "") for m in models.get("models", [])]
            return True, model in model_names
        return False, False
    except requests.exceptions.RequestException:
        return False, False

server_ok, model_ok = check_ollama_health()
```

## Response Metrics

The generate endpoint returns useful metrics:

```python
result = response.json()
print(f"Prompt eval count: {result.get('prompt_eval_count', 'N/A')}")
print(f"Prompt eval duration: {result.get('prompt_eval_duration', 0) / 1e9:.3f}s")
print(f"Eval count (tokens): {result.get('eval_count', 'N/A')}")
print(f"Eval duration: {result.get('eval_duration', 0) / 1e9:.3f}s")
print(f"Total duration: {result.get('total_duration', 0) / 1e9:.3f}s")

if result.get('eval_count') and result.get('eval_duration'):
    tokens_per_sec = result['eval_count'] / (result['eval_duration'] / 1e9)
    print(f"Tokens/second: {tokens_per_sec:.1f}")
```

## When to Use This Skill

Use when:
- You need direct control over HTTP requests
- Debugging API interactions
- Building custom integrations
- Working with streaming responses
- Checking raw API responses

## Cross-References

- `bazzite-ai-ollama:python` - Higher-level Python library
- `bazzite-ai-ollama:openai` - OpenAI-compatible interface
