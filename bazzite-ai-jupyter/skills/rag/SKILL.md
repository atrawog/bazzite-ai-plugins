---
name: rag
description: |
  Retrieval-Augmented Generation (RAG) for grounding LLM responses with
  external knowledge. Covers document chunking, embeddings, vector stores
  (pandas, ChromaDB), similarity search, and conversational RAG pipelines.
---

# Retrieval-Augmented Generation (RAG)

## Overview

RAG enhances LLM responses by retrieving relevant context from a knowledge base before generation. This grounds responses in specific documents and reduces hallucination.

**Reference Notebooks:** D2_01, D2_02

## Quick Reference

| Step | Component |
|------|-----------|
| 1. Chunk | Split documents into segments |
| 2. Embed | Convert chunks to vectors |
| 3. Store | Save in vector database |
| 4. Retrieve | Find relevant chunks |
| 5. Generate | LLM answers with context |

## Basic RAG Pipeline

### 1. Document Chunking

```python
import textwrap

document = """
Your long document text here...
Multiple paragraphs of content...
"""

# Chunk into segments of max 1000 characters
chunks = textwrap.wrap(document, width=1000)

print(f"Created {len(chunks)} chunks")
```

### 2. Generate Embeddings

```python
import os
from openai import OpenAI

OLLAMA_HOST = os.getenv("OLLAMA_HOST", "http://ollama:11434")
EMBED_MODEL = "llama3.2:latest"

client = OpenAI(base_url=f"{OLLAMA_HOST}/v1", api_key="ollama")

def get_embedding(text):
    response = client.embeddings.create(
        model=EMBED_MODEL,
        input=text
    )
    return response.data[0].embedding

# Embed all chunks
embeddings = [get_embedding(chunk) for chunk in chunks]
print(f"Embedding dimensions: {len(embeddings[0])}")
```

### 3. Create Vector Database (Pandas)

```python
import pandas as pd
import numpy as np

vector_db = pd.DataFrame({
    "text": chunks,
    "embeddings": [np.array(e) for e in embeddings]
})
```

### 4. Similarity Search

```python
def cosine_similarity(a, b):
    return np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b))

def search(query, n_results=5):
    query_embedding = get_embedding(query)

    similarities = vector_db["embeddings"].apply(
        lambda x: cosine_similarity(query_embedding, x)
    )

    top_indices = similarities.nlargest(n_results).index
    return vector_db.loc[top_indices, "text"].tolist()

# Find relevant chunks
relevant = search("What are the symptoms?", n_results=3)
```

### 5. Generate with Context

```python
LLM_MODEL = "hf.co/NousResearch/Nous-Hermes-2-Mistral-7B-DPO-GGUF:Q4_K_M"

def rag_query(question, n_docs=5):
    # Retrieve context
    context_chunks = search(question, n_results=n_docs)
    context = "\n\n".join(context_chunks)

    # Build prompt
    messages = [
        {"role": "system", "content": f"Answer based on this context:\n\n{context}"},
        {"role": "user", "content": question}
    ]

    # Generate
    response = client.chat.completions.create(
        model=LLM_MODEL,
        messages=messages,
        max_tokens=500
    )

    return response.choices[0].message.content

answer = rag_query("What are the main symptoms of Omicron?")
```

## LangChain RAG with ChromaDB

### Setup

```python
import os
from langchain_openai import ChatOpenAI, OpenAIEmbeddings
from langchain_community.vectorstores import Chroma

OLLAMA_HOST = os.getenv("OLLAMA_HOST", "http://ollama:11434")
MODEL = "hf.co/NousResearch/Nous-Hermes-2-Mistral-7B-DPO-GGUF:Q4_K_M"

# LLM for generation
llm = ChatOpenAI(
    base_url=f"{OLLAMA_HOST}/v1",
    api_key="ollama",
    model=MODEL
)

# Embeddings
embeddings = OpenAIEmbeddings(
    base_url=f"{OLLAMA_HOST}/v1",
    api_key="ollama",
    model="llama3.2:latest"
)
```

### Create Vector Store

```python
import textwrap

# Chunk document
document = "Your document text..."
chunks = textwrap.wrap(document, width=1000)

# Create ChromaDB store
vectorstore = Chroma.from_texts(
    texts=chunks,
    embedding=embeddings,
    persist_directory="./chroma_db"
)

# Create retriever
retriever = vectorstore.as_retriever(search_kwargs={"k": 5})
```

### Build RAG Chain

```python
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_classic.chains import create_retrieval_chain
from langchain.chains.combine_documents import create_stuff_documents_chain

# Prompt template
prompt = ChatPromptTemplate.from_messages([
    ("system", "Answer based on this context:\n\n{context}"),
    MessagesPlaceholder(variable_name="chat_history"),
    ("human", "{input}")
])

# Create chains
question_answer_chain = create_stuff_documents_chain(llm, prompt)
rag_chain = create_retrieval_chain(retriever, question_answer_chain)
```

### Conversational RAG

```python
from langchain_core.messages import HumanMessage, AIMessage

chat_history = []

def chat(question):
    result = rag_chain.invoke({
        "input": question,
        "chat_history": chat_history
    })

    # Update history
    chat_history.append(HumanMessage(content=question))
    chat_history.append(AIMessage(content=result["answer"]))

    return result["answer"]

# Multi-turn conversation
print(chat("What is Omicron?"))
print(chat("What are its symptoms?"))
print(chat("How does it compare to Delta?"))
```

## Chunking Strategies

### Fixed Size

```python
def fixed_chunks(text, size=1000):
    return textwrap.wrap(text, width=size)
```

### Sentence-Based

```python
import re

def sentence_chunks(text, max_sentences=5):
    sentences = re.split(r'(?<=[.!?])\s+', text)
    chunks = []
    current = []

    for sent in sentences:
        current.append(sent)
        if len(current) >= max_sentences:
            chunks.append(" ".join(current))
            current = []

    if current:
        chunks.append(" ".join(current))

    return chunks
```

### Overlap Chunks

```python
def overlap_chunks(text, size=1000, overlap=200):
    chunks = []
    start = 0

    while start < len(text):
        end = start + size
        chunks.append(text[start:end])
        start = end - overlap

    return chunks
```

## Vector Store Options

### Pandas DataFrame (Simple)

```python
import pandas as pd

vector_db = pd.DataFrame({
    "text": chunks,
    "embeddings": embeddings
})
```

### ChromaDB (Persistent)

```python
from langchain_community.vectorstores import Chroma

vectorstore = Chroma.from_texts(
    texts=chunks,
    embedding=embeddings,
    persist_directory="./chroma_db"
)
```

### FAISS (Fast)

```python
from langchain_community.vectorstores import FAISS

vectorstore = FAISS.from_texts(chunks, embeddings)
vectorstore.save_local("./faiss_index")
```

## Troubleshooting

### Poor Retrieval Quality

**Symptom:** Retrieved chunks not relevant

**Fix:**
- Increase chunk overlap
- Use smaller chunk sizes
- Try different embedding models
- Increase `k` in retriever

### Slow Embedding

**Symptom:** Takes long to embed documents

**Fix:**
- Batch embeddings
- Use smaller embedding model
- Cache embeddings to disk

### Out of Context

**Symptom:** LLM ignores retrieved context

**Fix:**
- Increase `max_tokens`
- Use explicit system prompt
- Reduce number of retrieved chunks

## When to Use This Skill

Use when:
- LLM needs to answer from specific documents
- Reducing hallucination is critical
- Building Q&A systems over documents
- Need up-to-date information not in training data

## Cross-References

- `bazzite-ai-jupyter:langchain` - LangChain fundamentals
- `bazzite-ai-jupyter:evaluation` - Evaluate RAG quality
- `bazzite-ai-ollama:python` - Ollama embeddings API
