---
name: transformers
description: |
  Transformer architecture fundamentals. Covers self-attention mechanism,
  multi-head attention, feed-forward networks, layer normalization, and
  residual connections. Essential concepts for understanding LLMs.
---

# Transformer Architecture

## Overview

The Transformer architecture is the foundation of modern LLMs. Understanding its components helps with fine-tuning decisions, model selection, and debugging performance issues.

**Reference Notebook:** D3_01

## Quick Reference

| Component | Purpose |
|-----------|---------|
| Self-Attention | Learn relationships between tokens |
| Multi-Head Attention | Multiple attention perspectives |
| Feed-Forward Network | Transform representations |
| Layer Normalization | Stabilize training |
| Residual Connections | Enable deep networks |

## Self-Attention Mechanism

### Concept

Self-attention allows each token to attend to all other tokens in a sequence, learning contextual relationships.

```
"The cat sat on the mat"
       ↓
  Each word attends to every other word
       ↓
  Contextual representations
```

### Implementation

```python
import torch
import torch.nn.functional as F

# Example tokens
tokens = ["The", "cat", "sat", "on", "the", "mat"]
seq_length = len(tokens)
embed_dim = 8

# Random embeddings (in practice, learned)
embeddings = torch.randn(seq_length, embed_dim)

# Query, Key, Value weight matrices
W_q = torch.randn(embed_dim, embed_dim)
W_k = torch.randn(embed_dim, embed_dim)
W_v = torch.randn(embed_dim, embed_dim)

# Compute Q, K, V
Q = embeddings @ W_q  # Queries: what am I looking for?
K = embeddings @ W_k  # Keys: what do I contain?
V = embeddings @ W_v  # Values: what information do I provide?

# Attention scores
scores = Q @ K.T / (embed_dim ** 0.5)  # Scale by sqrt(d_k)

# Softmax for attention weights
attention_weights = F.softmax(scores, dim=-1)

# Weighted sum of values
output = attention_weights @ V

print(f"Input shape: {embeddings.shape}")
print(f"Output shape: {output.shape}")
print(f"Attention weights shape: {attention_weights.shape}")
```

### Attention Formula

```
Attention(Q, K, V) = softmax(QK^T / sqrt(d_k)) V
```

Where:
- Q = Query matrix
- K = Key matrix
- V = Value matrix
- d_k = Key dimension (for scaling)

## Multi-Head Attention

### Concept

Multiple attention heads learn different aspects of relationships (syntax, semantics, etc.).

```python
num_heads = 4
head_dim = embed_dim // num_heads

# Split into heads
def split_heads(x, num_heads):
    batch_size, seq_len, embed_dim = x.shape
    head_dim = embed_dim // num_heads
    return x.view(batch_size, seq_len, num_heads, head_dim).transpose(1, 2)

# Compute attention for each head
heads = []
for h in range(num_heads):
    W_q_h = torch.randn(embed_dim, head_dim)
    W_k_h = torch.randn(embed_dim, head_dim)
    W_v_h = torch.randn(embed_dim, head_dim)

    Q_h = embeddings @ W_q_h
    K_h = embeddings @ W_k_h
    V_h = embeddings @ W_v_h

    scores_h = Q_h @ K_h.T / (head_dim ** 0.5)
    attn_h = F.softmax(scores_h, dim=-1)
    head_output = attn_h @ V_h
    heads.append(head_output)

# Concatenate heads
multi_head_output = torch.cat(heads, dim=-1)

# Project back to embed_dim
W_o = torch.randn(embed_dim, embed_dim)
final_output = multi_head_output @ W_o

print(f"Multi-head output shape: {final_output.shape}")
```

## Feed-Forward Network

### Concept

Two linear layers with activation, applied to each position independently.

```python
import torch.nn as nn

class FeedForward(nn.Module):
    def __init__(self, embed_dim, hidden_dim=2048):
        super().__init__()
        self.linear1 = nn.Linear(embed_dim, hidden_dim)
        self.linear2 = nn.Linear(hidden_dim, embed_dim)
        self.activation = nn.GELU()  # or ReLU

    def forward(self, x):
        x = self.linear1(x)
        x = self.activation(x)
        x = self.linear2(x)
        return x

ffn = FeedForward(embed_dim=512)
x = torch.randn(1, 10, 512)  # (batch, seq_len, embed_dim)
output = ffn(x)

print(f"FFN output shape: {output.shape}")
```

### Formula

```
FFN(x) = GELU(xW_1 + b_1)W_2 + b_2
```

## Layer Normalization

### Concept

Normalizes across the embedding dimension to stabilize training.

```python
class LayerNorm(nn.Module):
    def __init__(self, embed_dim, eps=1e-6):
        super().__init__()
        self.gamma = nn.Parameter(torch.ones(embed_dim))
        self.beta = nn.Parameter(torch.zeros(embed_dim))
        self.eps = eps

    def forward(self, x):
        mean = x.mean(dim=-1, keepdim=True)
        std = x.std(dim=-1, keepdim=True)
        return self.gamma * (x - mean) / (std + self.eps) + self.beta

layer_norm = nn.LayerNorm(embed_dim)
normalized = layer_norm(embeddings)
```

## Residual Connections

### Concept

Skip connections that add input to output, enabling gradient flow in deep networks.

```python
class TransformerBlock(nn.Module):
    def __init__(self, embed_dim, num_heads):
        super().__init__()
        self.attention = nn.MultiheadAttention(embed_dim, num_heads)
        self.ffn = FeedForward(embed_dim)
        self.norm1 = nn.LayerNorm(embed_dim)
        self.norm2 = nn.LayerNorm(embed_dim)

    def forward(self, x):
        # Self-attention with residual
        attn_out, _ = self.attention(x, x, x)
        x = self.norm1(x + attn_out)  # Residual connection

        # FFN with residual
        ffn_out = self.ffn(x)
        x = self.norm2(x + ffn_out)  # Residual connection

        return x
```

## Complete Transformer Layer

```python
class TransformerLayer(nn.Module):
    def __init__(self, embed_dim=512, num_heads=8, hidden_dim=2048, dropout=0.1):
        super().__init__()

        # Multi-head attention
        self.self_attn = nn.MultiheadAttention(embed_dim, num_heads, dropout=dropout)

        # Feed-forward
        self.ffn = nn.Sequential(
            nn.Linear(embed_dim, hidden_dim),
            nn.GELU(),
            nn.Dropout(dropout),
            nn.Linear(hidden_dim, embed_dim),
            nn.Dropout(dropout)
        )

        # Layer norms
        self.norm1 = nn.LayerNorm(embed_dim)
        self.norm2 = nn.LayerNorm(embed_dim)

        self.dropout = nn.Dropout(dropout)

    def forward(self, x, mask=None):
        # Self-attention block
        attn_out, attn_weights = self.self_attn(x, x, x, attn_mask=mask)
        x = self.norm1(x + self.dropout(attn_out))

        # FFN block
        ffn_out = self.ffn(x)
        x = self.norm2(x + ffn_out)

        return x, attn_weights

# Example usage
layer = TransformerLayer()
x = torch.randn(10, 1, 512)  # (seq_len, batch, embed_dim)
output, weights = layer(x)
print(f"Output shape: {output.shape}")
```

## Key Parameters

| Parameter | Typical Values | Effect |
|-----------|----------------|--------|
| `embed_dim` | 768, 1024, 4096 | Model capacity |
| `num_heads` | 8, 12, 16 | Attention perspectives |
| `num_layers` | 12, 24, 32 | Model depth |
| `hidden_dim` | 4 * embed_dim | FFN capacity |
| `dropout` | 0.1 | Regularization |

## Model Size Estimation

```python
def estimate_params(vocab_size, embed_dim, num_layers, hidden_dim, num_heads):
    # Embedding
    embedding_params = vocab_size * embed_dim

    # Per layer
    attn_params = 4 * embed_dim * embed_dim  # Q, K, V, O projections
    ffn_params = 2 * embed_dim * hidden_dim  # Two linear layers
    norm_params = 4 * embed_dim  # Two layer norms

    layer_params = attn_params + ffn_params + norm_params
    total_layer_params = num_layers * layer_params

    # Output head
    output_params = embed_dim * vocab_size

    total = embedding_params + total_layer_params + output_params
    return total / 1e9  # Billions

# Example: LLaMA-7B-like
params_b = estimate_params(
    vocab_size=32000,
    embed_dim=4096,
    num_layers=32,
    hidden_dim=11008,
    num_heads=32
)
print(f"Estimated parameters: {params_b:.1f}B")
```

## When to Use This Skill

Use when:
- Understanding model architecture for fine-tuning
- Debugging attention patterns
- Selecting target modules for LoRA
- Estimating model size and memory
- Building custom transformer components

## Cross-References

- `bazzite-ai-jupyter:finetuning` - Fine-tuning transformers
- `bazzite-ai-jupyter:peft` - Parameter-efficient tuning
- `bazzite-ai-jupyter:quantization` - Memory optimization
