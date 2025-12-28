---
name: python
description: |
  Official ollama Python library for LLM inference. Provides a clean,
  Pythonic interface for text generation, chat completion, embeddings,
  model management, and streaming responses.
---

# Ollama Python Library

## Overview

The official `ollama` Python library provides a clean, Pythonic interface to all Ollama functionality. It automatically connects to the Ollama server and handles serialization.

## Quick Reference

| Function | Purpose |
|----------|---------|
| `ollama.list()` | List available models |
| `ollama.show()` | Show model details |
| `ollama.ps()` | List running models |
| `ollama.generate()` | Generate text |
| `ollama.chat()` | Chat completion |
| `ollama.embed()` | Generate embeddings |
| `ollama.copy()` | Copy a model |
| `ollama.delete()` | Delete a model |
| `ollama.pull()` | Pull a model |

## Setup

```python
import ollama

# The library automatically uses OLLAMA_HOST environment variable
# Default: http://localhost:11434
```

## List Models

```python
models = ollama.list()

for model in models.get("models", []):
    size_gb = model.get("size", 0) / (1024**3)
    print(f"  - {model['model']} ({size_gb:.2f} GB)")
```

## Show Model Details

```python
model_info = ollama.show("llama3.2:latest")

details = model_info.get("details", {})
print(f"Family: {details.get('family', 'N/A')}")
print(f"Parameter Size: {details.get('parameter_size', 'N/A')}")
print(f"Quantization: {details.get('quantization_level', 'N/A')}")
```

## List Running Models

```python
running = ollama.ps()

for model in running.get("models", []):
    name = model.get("name", "Unknown")
    size = model.get("size", 0) / (1024**3)
    vram = model.get("size_vram", 0) / (1024**3)
    print(f"  - {name}: {size:.2f} GB (VRAM: {vram:.2f} GB)")
```

## Generate Text

### Non-Streaming

```python
result = ollama.generate(
    model="llama3.2:latest",
    prompt="Why is the sky blue? Answer in one sentence."
)
print(result["response"])
```

### Streaming

```python
stream = ollama.generate(
    model="llama3.2:latest",
    prompt="Count from 1 to 5.",
    stream=True
)

for chunk in stream:
    print(chunk["response"], end="", flush=True)
```

## Chat Completion

### Single Turn

```python
response = ollama.chat(
    model="llama3.2:latest",
    messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "What is Python?"}
    ]
)
print(response["message"]["content"])
```

### Multi-Turn Conversation

```python
messages = [
    {"role": "user", "content": "What is 2 + 2?"}
]

# First turn
response = ollama.chat(model="llama3.2:latest", messages=messages)
print(f"User: What is 2 + 2?")
print(f"Assistant: {response['message']['content']}")

# Continue conversation
messages.append(response["message"])
messages.append({"role": "user", "content": "And what is that multiplied by 3?"})

response = ollama.chat(model="llama3.2:latest", messages=messages)
print(f"User: And what is that multiplied by 3?")
print(f"Assistant: {response['message']['content']}")
```

### Streaming Chat

```python
stream = ollama.chat(
    model="llama3.2:latest",
    messages=[{"role": "user", "content": "Tell me a joke."}],
    stream=True
)

for chunk in stream:
    print(chunk["message"]["content"], end="", flush=True)
```

## Generate Embeddings

```python
result = ollama.embed(
    model="llama3.2:latest",
    input="Ollama makes running LLMs locally easy."
)

embeddings = result.get("embeddings", [[]])[0]
print(f"Dimensions: {len(embeddings)}")
print(f"First 5 values: {embeddings[:5]}")
```

## Model Management

### Copy Model

```python
ollama.copy(source="llama3.2:latest", destination="llama3.2-backup:latest")
print("Copy successful!")
```

### Delete Model

```python
ollama.delete("llama3.2-backup:latest")
print("Delete successful!")
```

### Pull Model

```python
# Non-streaming
ollama.pull("llama3.2:latest")

# With progress
for progress in ollama.pull("llama3.2:latest", stream=True):
    status = progress.get("status", "")
    print(status)
```

## Error Handling

```python
try:
    result = ollama.generate(
        model="nonexistent-model",
        prompt="Hello"
    )
except Exception as e:
    print(f"Error: {type(e).__name__}: {e}")

# Connection check
try:
    models = ollama.list()
    print("Ollama server is running!")
except Exception as e:
    print("Cannot connect to Ollama. Ensure server is running at OLLAMA_HOST")
```

## Connection Health Check

```python
def check_ollama_health(model="llama3.2:latest"):
    """Check if Ollama server is running and model is available."""
    try:
        models = ollama.list()
        model_names = [m.get("model", "") for m in models.get("models", [])]
        return True, model in model_names
    except Exception:
        return False, False

server_ok, model_ok = check_ollama_health()
```

## Response Metrics

```python
result = ollama.generate(model="llama3.2:latest", prompt="Hello!")

print(f"Eval tokens: {result.get('eval_count', 'N/A')}")
print(f"Eval duration: {result.get('eval_duration', 0) / 1e9:.2f}s")

if result.get('eval_count') and result.get('eval_duration'):
    tokens_per_sec = result['eval_count'] / (result['eval_duration'] / 1e9)
    print(f"Tokens/second: {tokens_per_sec:.1f}")
```

## Common Patterns

### Conversation Class

```python
class Conversation:
    def __init__(self, model="llama3.2:latest", system_prompt=None):
        self.model = model
        self.messages = []
        if system_prompt:
            self.messages.append({"role": "system", "content": system_prompt})

    def chat(self, user_message):
        self.messages.append({"role": "user", "content": user_message})
        response = ollama.chat(model=self.model, messages=self.messages)
        assistant_message = response["message"]
        self.messages.append(assistant_message)
        return assistant_message["content"]

# Usage
conv = Conversation(system_prompt="You are a helpful assistant.")
print(conv.chat("What is Python?"))
print(conv.chat("What are its main features?"))
```

## When to Use This Skill

Use when:

- You want a clean, Pythonic interface
- Building Python applications
- Need IDE autocompletion support
- Working with multi-turn conversations
- Prefer not to handle HTTP directly

## Cross-References

- `bazzite-ai-ollama:api` - Direct REST API access
- `bazzite-ai-ollama:openai` - OpenAI-compatible interface
