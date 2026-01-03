---
name: sft
description: |
  Supervised Fine-Tuning with SFTTrainer and Unsloth. Covers dataset preparation,
  chat template formatting, training configuration, and Unsloth optimizations
  for 2x faster instruction tuning.
---

# Supervised Fine-Tuning (SFT)

## Overview

SFT adapts a pre-trained LLM to follow instructions by training on instruction-response pairs. Unsloth provides an optimized SFTTrainer for 2x faster training with reduced memory usage.

## Quick Reference

| Component | Purpose |
|-----------|---------|
| `FastLanguageModel` | Load model with Unsloth optimizations |
| `SFTTrainer` | Trainer for instruction tuning |
| `SFTConfig` | Training hyperparameters |
| `dataset_text_field` | Column containing formatted text |

## Dataset Formats

### Instruction-Response Format

```python
dataset = [
    {"instruction": "What is Python?", "response": "A programming language."},
    {"instruction": "Explain ML.", "response": "Machine learning is..."},
]
```

### Chat/Conversation Format

```python
dataset = [
    {"messages": [
        {"role": "user", "content": "What is Python?"},
        {"role": "assistant", "content": "A programming language."}
    ]},
]
```

### Using Chat Templates

```python
def format_conversation(sample):
    messages = [
        {"role": "user", "content": sample["instruction"]},
        {"role": "assistant", "content": sample["response"]}
    ]
    return {"text": tokenizer.apply_chat_template(
        messages, tokenize=False, add_generation_prompt=False
    )}

dataset = dataset.map(format_conversation)
```

## Unsloth SFT Setup

### Load Model

```python
from unsloth import FastLanguageModel

model, tokenizer = FastLanguageModel.from_pretrained(
    "unsloth/Qwen3-4B-unsloth-bnb-4bit",
    max_seq_length=512,
    load_in_4bit=True,
)
```

### Apply LoRA

```python
model = FastLanguageModel.get_peft_model(
    model,
    r=16,
    lora_alpha=16,
    lora_dropout=0,
    target_modules=["q_proj", "k_proj", "v_proj", "o_proj",
                    "gate_proj", "up_proj", "down_proj"],
    use_gradient_checkpointing="unsloth",
)
```

### Training Configuration

```python
from trl import SFTConfig

sft_config = SFTConfig(
    output_dir="./sft_output",
    per_device_train_batch_size=2,
    gradient_accumulation_steps=4,
    max_steps=100,
    learning_rate=2e-4,
    fp16=not is_bf16_supported(),
    bf16=is_bf16_supported(),
    optim="adamw_8bit",
    max_seq_length=512,
)
```

## SFTTrainer Usage

### Basic Training

```python
from trl import SFTTrainer

trainer = SFTTrainer(
    model=model,
    tokenizer=tokenizer,
    train_dataset=dataset,
    dataset_text_field="text",
    args=sft_config,
)

trainer.train()
```

### With Custom Formatting

```python
def formatting_func(examples):
    texts = []
    for instruction, response in zip(examples["instruction"], examples["response"]):
        text = f"### Instruction:\n{instruction}\n\n### Response:\n{response}"
        texts.append(text)
    return texts

trainer = SFTTrainer(
    model=model,
    tokenizer=tokenizer,
    train_dataset=dataset,
    formatting_func=formatting_func,
    args=sft_config,
)
```

## Key Parameters

| Parameter | Typical Values | Effect |
|-----------|----------------|--------|
| `learning_rate` | 2e-4 to 2e-5 | Training speed vs stability |
| `per_device_train_batch_size` | 1-4 | Memory usage |
| `gradient_accumulation_steps` | 2-8 | Effective batch size |
| `max_seq_length` | 512-2048 | Context window |
| `optim` | "adamw_8bit" | Memory-efficient optimizer |

## Save and Load

### Save Model

```python
# Save LoRA adapters only (small)
model.save_pretrained("./sft_lora")

# Save merged model (full size)
model.save_pretrained_merged("./sft_merged", tokenizer)
```

### Load for Inference

```python
from unsloth import FastLanguageModel

model, tokenizer = FastLanguageModel.from_pretrained("./sft_lora")
FastLanguageModel.for_inference(model)
```

## Ollama Integration

### Export to GGUF

```python
# Export to GGUF for Ollama
model.save_pretrained_gguf(
    "model",
    tokenizer,
    quantization_method="q4_k_m"
)
```

### Deploy to Ollama

```bash
ollama create mymodel -f Modelfile
ollama run mymodel
```

## Troubleshooting

### Out of Memory

**Symptom:** CUDA out of memory error

**Fix:**
- Use `gradient_checkpointing="unsloth"`
- Reduce `per_device_train_batch_size` to 1
- Use 4-bit quantization (`load_in_4bit=True`)

### NaN Loss

**Symptom:** Loss becomes NaN during training

**Fix:**
- Lower `learning_rate` to 1e-5
- Check data quality (no empty samples)
- Use gradient clipping

### Slow Training

**Symptom:** Training slower than expected

**Fix:**
- Ensure Unsloth is imported FIRST (before TRL)
- Use `bf16=True` if supported
- Enable `use_gradient_checkpointing="unsloth"`

## When to Use This Skill

Use when:

- Creating instruction-following models
- Fine-tuning for chat/conversation
- Adapting to domain-specific tasks
- Building custom assistants
- First step before preference optimization (DPO/GRPO)

## Cross-References

- `bazzite-ai-jupyter:peft` - LoRA configuration details
- `bazzite-ai-jupyter:finetuning` - General fine-tuning concepts
- `bazzite-ai-jupyter:dpo` - Direct Preference Optimization after SFT
- `bazzite-ai-jupyter:grpo` - GRPO reinforcement learning after SFT
- `bazzite-ai-ollama:api` - Ollama deployment
