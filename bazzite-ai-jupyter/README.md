# bazzite-ai-jupyter

ML/AI development workflows for JupyterLab - LangChain, RAG, fine-tuning, and model optimization.

## Overview

This plugin provides skills for **ML/AI workflows** in JupyterLab.

**Note:** This plugin is designed to work with the `bazzite-ai-pod-jupyter` container or any JupyterLab environment with the required packages. For Ollama API operations, see `bazzite-ai-ollama`.

## Skills

| Skill | Description |
|-------|-------------|
| `langchain` | LangChain framework - prompts, chains, and model wrappers |
| `rag` | Retrieval-Augmented Generation with vector stores |
| `evaluation` | LLM evaluation and prompt optimization with Evidently.ai |
| `transformers` | Transformer architecture concepts (attention, FFN) |
| `finetuning` | Model fine-tuning with PyTorch and HuggingFace Trainer |
| `quantization` | Model quantization for efficient inference |
| `peft` | Parameter-efficient fine-tuning (LoRA, Unsloth) |

## MCP Server

This plugin bundles a **Jupyter MCP server** that connects to your running JupyterLab instance.

**Connection:** `http://127.0.0.1:8888/mcp`

**Available tools:**

| Tool | Description |
|------|-------------|
| `mcp__jupyter__list_files` | List files in Jupyter server filesystem |
| `mcp__jupyter__list_kernels` | List available kernels |
| `mcp__jupyter__use_notebook` | Activate a notebook for operations |
| `mcp__jupyter__read_notebook` | Read notebook cells and structure |
| `mcp__jupyter__insert_cell` | Insert new cells |
| `mcp__jupyter__execute_cell` | Execute notebook cells |
| `mcp__jupyter__execute_code` | Execute code directly in kernel |

The MCP server starts automatically when this plugin is enabled.

## Prerequisites

**JupyterLab Environment:**

- JupyterLab server running at `http://localhost:8888` with MCP enabled
- GPU access configured if using GPU-accelerated training

**Ollama (for inference):**

- Ollama server running (default: `http://ollama:11434` or `OLLAMA_HOST` env var)
- Model available (pull via API):

```python
import requests
OLLAMA_HOST = "http://ollama:11434"
requests.post(f"{OLLAMA_HOST}/api/pull", json={"name": "hf.co/NousResearch/Nous-Hermes-2-Mistral-7B-DPO-GGUF:Q4_K_M"}, stream=True)
```

**Note:** All required Python packages are pre-installed in the `bazzite-ai-pod-jupyter` container.

## Quick Start

### LangChain with Ollama

```python
import os
from langchain_openai import ChatOpenAI

OLLAMA_HOST = os.getenv("OLLAMA_HOST", "http://ollama:11434")

llm = ChatOpenAI(
    base_url=f"{OLLAMA_HOST}/v1",
    api_key="ollama",
    model="hf.co/NousResearch/Nous-Hermes-2-Mistral-7B-DPO-GGUF:Q4_K_M"
)

response = llm.invoke("What is machine learning?")
print(response.content)
```

### RAG Pipeline

```python
from langchain_community.vectorstores import Chroma
from langchain_openai import OpenAIEmbeddings

embeddings = OpenAIEmbeddings(
    base_url=f"{OLLAMA_HOST}/v1",
    api_key="ollama"
)

vectorstore = Chroma.from_texts(documents, embeddings)
retriever = vectorstore.as_retriever()
```

### Fine-tuning with LoRA

```python
from peft import LoraConfig, get_peft_model

lora_config = LoraConfig(
    r=8,
    lora_alpha=16,
    target_modules=["q_proj", "v_proj"],
    lora_dropout=0.05
)

model = get_peft_model(base_model, lora_config)
```

## Related Plugins

- `bazzite-ai-ollama` - Ollama API operations for LLM inference
