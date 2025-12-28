---
name: langchain
description: |
  LangChain framework for LLM applications. Covers model wrappers (HuggingFace,
  Ollama), prompt templates, few-shot learning, output parsing, and chaining
  techniques for building sophisticated LLM workflows.
---

# LangChain Framework

## Overview

LangChain is a framework for building LLM applications. It provides abstractions for prompts, models, chains, and output parsing that work with both local models (HuggingFace, Ollama) and cloud APIs (OpenAI, Anthropic).

## Quick Reference

| Component | Purpose |
|-----------|---------|
| `ChatOpenAI` | Connect to Ollama (OpenAI-compatible) |
| `HuggingFacePipeline` | Wrap local HuggingFace models |
| `ChatHuggingFace` | Chat interface for HF models |
| `PromptTemplate` | Single-string prompt formatting |
| `ChatPromptTemplate` | Multi-message prompt formatting |
| `PydanticOutputParser` | Structured output parsing |

## Model Wrappers

### Ollama via OpenAI-Compatible API

```python
import os
from langchain_openai import ChatOpenAI

OLLAMA_HOST = os.getenv("OLLAMA_HOST", "http://ollama:11434")
MODEL = "hf.co/NousResearch/Nous-Hermes-2-Mistral-7B-DPO-GGUF:Q4_K_M"

llm = ChatOpenAI(
    base_url=f"{OLLAMA_HOST}/v1",
    api_key="ollama",  # Required by library, ignored by Ollama
    model=MODEL,
    temperature=0.7,
    max_tokens=150
)

response = llm.invoke("What is Python?")
print(response.content)
```

### HuggingFace Local Model

```python
import torch
from transformers import AutoModelForCausalLM, AutoTokenizer, BitsAndBytesConfig, pipeline
from langchain_huggingface import HuggingFacePipeline, ChatHuggingFace

HF_MODEL = "NousResearch/Nous-Hermes-2-Mistral-7B-DPO"

# 4-bit quantization for memory efficiency
quantization_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_quant_type="nf4",
    bnb_4bit_compute_dtype=torch.bfloat16
)

tokenizer = AutoTokenizer.from_pretrained(HF_MODEL)
model = AutoModelForCausalLM.from_pretrained(
    HF_MODEL,
    device_map="auto",
    quantization_config=quantization_config
)

# Create pipeline
text_pipeline = pipeline(
    "text-generation",
    model=model,
    tokenizer=tokenizer,
    max_new_tokens=150,
    return_full_text=False
)

# Wrap for LangChain
llm = HuggingFacePipeline(pipeline=text_pipeline)
chat_llm = ChatHuggingFace(llm=llm)
```

## LLM Methods

### invoke() - Single Input

```python
response = llm.invoke("Tell me a fact about Mars.")
print(response)
```

### batch() - Multiple Inputs

```python
prompts = ["Tell me a joke", "Translate to German: Hello!"]
results = llm.batch(prompts)

for prompt, result in zip(prompts, results):
    print(f"Prompt: {prompt}")
    print(f"Response: {result}\n")
```

### generate() - With Metadata

```python
results = llm.generate(["Where should I go for a Safari?"])

for gen in results.generations:
    print(gen[0].text)

# Access token counts
print(results.llm_output)
```

### stream() - Token Streaming

```python
for chunk in llm.stream("Tell me a story about a cat."):
    print(chunk, end="", flush=True)
```

## Prompt Templates

### Basic PromptTemplate

```python
from langchain_core.prompts import PromptTemplate

template = PromptTemplate(
    input_variables=["topic"],
    template="Explain {topic} in simple terms."
)

formatted = template.format(topic="quantum computing")
response = llm.invoke(formatted)
```

### ChatPromptTemplate

```python
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.messages import SystemMessage, HumanMessage

chat_prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a helpful legal translator."),
    ("human", "Simplify this legal text: {legal_text}")
])

messages = chat_prompt.format_messages(legal_text="...")
response = chat_llm.invoke(messages)
```

## Few-Shot Learning

```python
from langchain_core.prompts import ChatPromptTemplate

# Define examples
examples = [
    {"input": "Legal term 1", "output": "Plain explanation 1"},
    {"input": "Legal term 2", "output": "Plain explanation 2"}
]

# Build few-shot prompt
messages = [
    ("system", "Translate legal terms to plain language.")
]
for ex in examples:
    messages.append(("human", ex["input"]))
    messages.append(("assistant", ex["output"]))
messages.append(("human", "{new_input}"))

few_shot_prompt = ChatPromptTemplate.from_messages(messages)
```

## Output Parsing

### Pydantic Parser

```python
from pydantic import BaseModel, Field
from langchain.output_parsers import PydanticOutputParser

class LegalClause(BaseModel):
    parties: list[str] = Field(description="Parties involved")
    obligations: str = Field(description="Main obligations")
    conditions: str = Field(description="Key conditions")

parser = PydanticOutputParser(pydantic_object=LegalClause)

prompt = PromptTemplate(
    input_variables=["clause"],
    template="Parse this legal clause:\n{clause}\n\n{format_instructions}",
    partial_variables={"format_instructions": parser.get_format_instructions()}
)

formatted = prompt.format(clause="...")
response = llm.invoke(formatted)
parsed = parser.parse(response)

print(parsed.parties)
print(parsed.obligations)
```

## Chaining

### Sequential Chain (Pipe Syntax)

```python
from langchain_core.prompts import PromptTemplate

# Define chains
template1 = "Give a bullet point outline for a blog about {topic}"
template2 = "Write a blog post from this outline:\n{outline}"

chain1 = PromptTemplate.from_template(template1) | llm
chain2 = PromptTemplate.from_template(template2) | llm

# Compose
full_chain = chain1 | chain2

result = full_chain.invoke({"topic": "AI"})
```

### Multi-Step Processing

```python
template1 = "Summarize this review:\n{review}"
template2 = "Identify weaknesses:\n{summary}"
template3 = "Create improvement plan:\n{weaknesses}"

chain_1 = PromptTemplate.from_template(template1) | llm
chain_2 = PromptTemplate.from_template(template2) | llm
chain_3 = PromptTemplate.from_template(template3) | llm

full_chain = chain_1 | chain_2 | chain_3
result = full_chain.invoke(employee_review)
```

### Router Chain

```python
from langchain.chains.router import MultiPromptChain

beginner_template = "Explain {input} simply for a child."
expert_template = "Explain {input} technically for an expert."

prompt_infos = [
    {"name": "beginner", "description": "For simple questions", "prompt_template": beginner_template},
    {"name": "expert", "description": "For technical questions", "prompt_template": expert_template}
]

chain = MultiPromptChain.from_prompts(llm, prompt_infos, verbose=True)
result = chain.invoke("How do Feynman diagrams work?")
```

## Caching

```python
import langchain
from langchain.cache import SQLiteCache

langchain.llm_cache = SQLiteCache(database_path=".langchain.db")

# First call - hits LLM
response1 = llm.invoke("What is Python?")

# Second call - uses cache (instant)
response2 = llm.invoke("What is Python?")
```

## Messages

```python
from langchain_core.messages import SystemMessage, HumanMessage, AIMessage

messages = [
    SystemMessage(content="You are a helpful assistant."),
    HumanMessage(content="What is 2+2?"),
    AIMessage(content="4"),
    HumanMessage(content="And times 3?")
]

response = chat_llm.invoke(messages)
```

## When to Use This Skill

Use when:

- Building LLM applications with structured workflows
- Need prompt templating and variable substitution
- Chaining multiple LLM calls together
- Parsing structured output from LLMs
- Working with both local and cloud models

## Cross-References

- `bazzite-ai-jupyter:rag` - RAG pipelines using LangChain
- `bazzite-ai-jupyter:evaluation` - LLM evaluation
- `bazzite-ai-ollama:openai` - Ollama OpenAI compatibility
- `bazzite-ai-ollama:python` - Native Ollama Python library
