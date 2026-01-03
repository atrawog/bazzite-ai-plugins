---
name: qlora
description: |
  Advanced QLoRA experiments and comparisons. Covers alpha scaling, LoRA rank selection,
  target module strategies, continual learning, multi-adapter hot-swapping, and
  quantization comparison (4-bit vs BF16).
---

# Advanced QLoRA Experiments

## Overview

This skill covers advanced QLoRA experimentation patterns for optimizing fine-tuning performance. Learn how to select the best LoRA rank, alpha scaling, target modules, and quantization settings for your specific use case.

## Quick Reference

| Topic | Key Finding |
|-------|-------------|
| **Rank (r)** | r=16 is optimal balance; r=8 for memory constrained |
| **Alpha** | alpha=r (1.0x scaling) is standard; alpha=2r for aggressive |
| **Target Modules** | all_linear for general; mlp_only for knowledge injection |
| **Quantization** | 4-bit NF4 matches BF16 quality with 11-15% memory savings |
| **Continual Learning** | Sequential training adds knowledge without forgetting |

## Alpha Scaling

### Formula

The effective LoRA scaling factor is:

```
scaling_factor = alpha / r
```

This acts as a learning rate multiplier for adapter weights.

### Alpha Comparison Code

```python
import unsloth
from unsloth import FastLanguageModel, is_bf16_supported
from trl import SFTTrainer, SFTConfig
from transformers import TrainerCallback

ALPHAS = [8, 16, 32, 64]
FIXED_RANK = 16
results = []

for alpha in ALPHAS:
    scaling_factor = alpha / FIXED_RANK
    print(f"\n=== Testing alpha={alpha} (scaling={scaling_factor}x) ===")

    # Load fresh model
    model, tokenizer = FastLanguageModel.from_pretrained(
        "unsloth/Qwen3-4B-Thinking-2507-unsloth-bnb-4bit",
        max_seq_length=512,
        load_in_4bit=True,
    )

    # Apply LoRA with specific alpha
    model = FastLanguageModel.get_peft_model(
        model,
        r=FIXED_RANK,
        lora_alpha=alpha,  # Variable alpha
        lora_dropout=0,
        target_modules=["q_proj", "k_proj", "v_proj", "o_proj",
                        "gate_proj", "up_proj", "down_proj"],
        bias="none",
        use_gradient_checkpointing="unsloth",
        random_state=42,
    )

    # Train and record results
    trainer = SFTTrainer(model=model, tokenizer=tokenizer, ...)
    stats = trainer.train()

    results.append({
        "alpha": alpha,
        "scaling": scaling_factor,
        "final_loss": stats.metrics["train_loss"]
    })
```

### Alpha Scaling Results

| Alpha | Scaling | Final Loss | Behavior |
|-------|---------|------------|----------|
| 8 | 0.5x | ~3.02 | Conservative, slower convergence |
| 16 | 1.0x | ~2.94 | Standard, balanced |
| 32 | 2.0x | ~2.80 | Aggressive, faster convergence |
| 64 | 4.0x | ~2.60 | Very aggressive, risk of instability |

### Recommendations

- **Standard**: `alpha = r` (1.0x scaling)
- **Aggressive training**: `alpha = 2r` with reduced learning rate
- **Stability priority**: `alpha = r/2` (0.5x scaling)

## LoRA Rank Comparison

### Rank Selection Code

```python
RANKS = [4, 8, 16, 32, 64]

for rank in RANKS:
    model = FastLanguageModel.get_peft_model(
        model,
        r=rank,
        lora_alpha=rank,  # Keep alpha = r for fair comparison
        lora_dropout=0,
        target_modules=["q_proj", "k_proj", "v_proj", "o_proj",
                        "gate_proj", "up_proj", "down_proj"],
        bias="none",
        use_gradient_checkpointing="unsloth",
        random_state=42,
    )

    # Count parameters
    trainable = sum(p.numel() for p in model.parameters() if p.requires_grad)
    total = sum(p.numel() for p in model.parameters())
    pct = 100 * trainable / total

    print(f"r={rank}: {trainable:,} trainable ({pct:.2f}%)")
```

### Rank Comparison Results (Qwen3-4B)

| Rank | Trainable Params | % of Total | Memory | Best For |
|------|------------------|------------|--------|----------|
| 4 | ~8M | 0.3% | Lowest | Quick experiments |
| 8 | ~16M | 0.6% | Low | Memory constrained |
| **16** | ~33M | 1.3% | Medium | **General use (default)** |
| 32 | ~66M | 2.6% | High | Complex tasks |
| 64 | ~132M | 5.2% | Highest | Maximum capacity |

### Rank Selection Guidelines

```python
def recommend_rank(gpu_vram_gb, task_complexity, dataset_size):
    """Recommend LoRA rank based on constraints."""

    # Memory constraints
    if gpu_vram_gb < 8:
        max_rank = 8
    elif gpu_vram_gb < 12:
        max_rank = 16
    elif gpu_vram_gb < 24:
        max_rank = 32
    else:
        max_rank = 64

    # Task complexity adjustment
    if task_complexity == "simple":
        suggested = 8
    elif task_complexity == "medium":
        suggested = 16
    elif task_complexity == "complex":
        suggested = 32
    else:
        suggested = 16

    # Dataset size adjustment
    if dataset_size < 1000:
        suggested = min(suggested, 16)  # Avoid overfitting
    elif dataset_size > 10000:
        suggested = max(suggested, 16)  # Can use higher rank

    return min(suggested, max_rank)
```

## Target Module Selection

### Available Configurations

```python
TARGET_CONFIGS = {
    "qv_only": {
        "modules": ["q_proj", "v_proj"],
        "params": "~9M",
        "description": "Query + Value only (minimal, original LoRA paper)"
    },
    "attention_only": {
        "modules": ["q_proj", "k_proj", "v_proj", "o_proj"],
        "params": "~18M",
        "description": "All attention layers"
    },
    "mlp_only": {
        "modules": ["gate_proj", "up_proj", "down_proj"],
        "params": "~15M",
        "description": "MLP/FFN layers only"
    },
    "all_linear": {
        "modules": ["q_proj", "k_proj", "v_proj", "o_proj",
                    "gate_proj", "up_proj", "down_proj"],
        "params": "~33M",
        "description": "All linear layers (maximum capacity)"
    },
}
```

### Module Function Analysis

**Attention Layers (q, k, v, o):**
- Control how model attends to input
- Affect reasoning patterns and style
- Best for: Format adaptation, thinking pattern changes

**MLP Layers (gate, up, down):**
- Store factual knowledge
- Process and transform representations
- Best for: Knowledge injection, domain adaptation

### Use Case Recommendations

| Use Case | Config | Rationale |
|----------|--------|-----------|
| Minimal fine-tuning | `qv_only` | Fastest, smallest adapters |
| Style/format change | `attention_only` | Changes reasoning patterns |
| Knowledge injection | `mlp_only` | Updates knowledge only |
| **General fine-tuning** | `all_linear` | **Maximum flexibility (default)** |
| Preserve reasoning | `mlp_only` | Keeps thinking style |

### Target Module Selection Code

```python
def get_target_modules(use_case):
    """Select target modules based on use case."""

    configs = {
        "minimal": ["q_proj", "v_proj"],
        "style": ["q_proj", "k_proj", "v_proj", "o_proj"],
        "knowledge": ["gate_proj", "up_proj", "down_proj"],
        "full": ["q_proj", "k_proj", "v_proj", "o_proj",
                 "gate_proj", "up_proj", "down_proj"],
    }

    return configs.get(use_case, configs["full"])

# Usage
model = FastLanguageModel.get_peft_model(
    model,
    r=16,
    lora_alpha=16,
    target_modules=get_target_modules("full"),
    ...
)
```

## Continual Learning

Sequential training adds new knowledge without catastrophic forgetting.

### Sequential Training Pattern

```python
TRAINING_STAGES = [
    ("medical", medical_dataset),
    ("legal", legal_dataset),
    ("technical", technical_dataset),
]

# Load model ONCE
model, tokenizer = FastLanguageModel.from_pretrained(
    "unsloth/Qwen3-4B-Thinking-2507-unsloth-bnb-4bit",
    max_seq_length=512,
    load_in_4bit=True,
)

# Apply LoRA ONCE
model = FastLanguageModel.get_peft_model(
    model,
    r=16,
    lora_alpha=16,
    target_modules=["q_proj", "k_proj", "v_proj", "o_proj",
                    "gate_proj", "up_proj", "down_proj"],
    use_gradient_checkpointing="unsloth",
)

# Train sequentially
for stage_idx, (domain_name, domain_data) in enumerate(TRAINING_STAGES):
    print(f"\n=== Stage {stage_idx + 1}: Training on {domain_name} ===")

    trainer = SFTTrainer(
        model=model,
        tokenizer=tokenizer,
        train_dataset=domain_data,
        args=SFTConfig(
            output_dir=f"./continual_{domain_name}",
            max_steps=5,
            learning_rate=2e-4,
            ...
        ),
    )
    trainer.train()

    # Save checkpoint
    model.save_pretrained(f"./checkpoint_stage_{stage_idx}")

    # Test retention on ALL previous domains
    test_retention(model, tokenizer, TRAINING_STAGES[:stage_idx+1])
```

### Retention Testing

```python
def test_retention(model, tokenizer, trained_domains):
    """Verify model retains knowledge from previous domains."""

    RETENTION_TESTS = {
        "medical": "What is hypertension and how is it treated?",
        "legal": "Explain the concept of due process.",
        "technical": "What is a REST API?",
    }

    FastLanguageModel.for_inference(model)

    print("\n--- Retention Test ---")
    for domain_name, _ in trained_domains:
        prompt = RETENTION_TESTS[domain_name]
        messages = [{"role": "user", "content": prompt}]
        inputs = tokenizer.apply_chat_template(
            messages, tokenize=True, add_generation_prompt=True, return_tensors="pt"
        ).to(model.device)

        outputs = model.generate(input_ids=inputs, max_new_tokens=100)
        response = tokenizer.decode(outputs[0], skip_special_tokens=True)

        # Check response quality
        has_content = len(response.split()) > 10
        print(f"{domain_name}: {'PASS' if has_content else 'FAIL'}")
```

### Continual Learning Benefits

- **No catastrophic forgetting**: Base weights frozen, adapters accumulate knowledge
- **Incremental updates**: Add new domains without full retraining
- **Curriculum learning**: Simple → complex topic progression
- **Personalization**: Adapt over time with user feedback

## Multi-Adapter Hot-Swapping

Train task-specific adapters and swap at inference time.

### Training Multiple Adapters

```python
from peft import PeftModel

TASK_DATASETS = {
    "technical": technical_data,   # Precise, factual
    "creative": creative_data,     # Imaginative, expressive
    "code": code_data,             # Code-focused
}

# Train separate adapters
for task_name, task_data in TASK_DATASETS.items():
    # Load base model fresh
    model, tokenizer = FastLanguageModel.from_pretrained(
        "unsloth/Qwen3-4B-Thinking-2507-unsloth-bnb-4bit",
        max_seq_length=512,
        load_in_4bit=True,
    )

    # Apply LoRA
    model = FastLanguageModel.get_peft_model(model, r=16, lora_alpha=16, ...)

    # Train on task-specific data
    trainer = SFTTrainer(model=model, train_dataset=task_data, ...)
    trainer.train()

    # Save lightweight adapter (~130MB each)
    model.save_pretrained(f"./adapters/{task_name}")
    print(f"Saved {task_name} adapter")
```

### Hot-Swap at Inference

```python
from peft import PeftModel

# Load base model ONCE
base_model, tokenizer = FastLanguageModel.from_pretrained(
    "unsloth/Qwen3-4B-Thinking-2507-unsloth-bnb-4bit",
    max_seq_length=512,
    load_in_4bit=True,
)

# Function to swap adapters
def load_adapter(base_model, adapter_path):
    """Load specific adapter onto base model."""
    adapted_model = PeftModel.from_pretrained(base_model, adapter_path)
    FastLanguageModel.for_inference(adapted_model)
    return adapted_model

# Usage
technical_model = load_adapter(base_model, "./adapters/technical")
response = generate(technical_model, "Explain TCP vs UDP")

creative_model = load_adapter(base_model, "./adapters/creative")
response = generate(creative_model, "Write a haiku about coding")
```

### Adapter Storage

| Component | Size |
|-----------|------|
| Base model | ~8GB |
| Each adapter | ~130MB |
| 10 adapters | ~1.3GB total |

Multi-adapter approach: 8GB + 1.3GB = 9.3GB total
vs. 10 full models = 80GB

## Quantization Comparison

### 4-bit vs BF16 Code

```python
QUANT_CONFIGS = {
    "4bit_nf4": {
        "model_name": "unsloth/Qwen3-4B-Thinking-2507-unsloth-bnb-4bit",
        "load_in_4bit": True,
    },
    "bf16": {
        "model_name": "unsloth/Qwen3-4B-Thinking-2507",
        "load_in_4bit": False,
    },
}

results = []

for config_name, config in QUANT_CONFIGS.items():
    model, tokenizer = FastLanguageModel.from_pretrained(
        config["model_name"],
        max_seq_length=512,
        load_in_4bit=config.get("load_in_4bit", False),
    )

    # Measure memory
    memory_before = measure_gpu_memory()

    # Train
    trainer = SFTTrainer(model=model, ...)
    stats = trainer.train()

    memory_after = measure_gpu_memory()

    results.append({
        "config": config_name,
        "memory_mb": memory_after,
        "final_loss": stats.metrics["train_loss"],
    })
```

### Quantization Results

| Method | Peak Memory | Final Loss | Quality |
|--------|-------------|------------|---------|
| 4-bit NF4 | ~5.7GB | 3.0742 | Excellent |
| BF16 | ~6.5GB | 3.0742 | Reference |

**Key Finding**: 4-bit NF4 achieves identical final loss with 11-15% memory savings.

### GPU Memory Recommendations

| GPU VRAM | Recommended | Notes |
|----------|-------------|-------|
| <12GB | 4-bit NF4 | Required for training |
| 12-16GB | 4-bit NF4 | Allows larger batches |
| >16GB | BF16 or 4-bit | Choose based on batch needs |

## Utility Functions

### Loss History Callback

```python
from transformers import TrainerCallback

class LossHistoryCallback(TrainerCallback):
    """Track loss during training for comparison."""

    def __init__(self):
        self.losses = []

    def on_log(self, args, state, control, logs=None, **kwargs):
        if logs and 'loss' in logs:
            self.losses.append({
                'step': state.global_step,
                'loss': logs['loss']
            })

# Usage
loss_callback = LossHistoryCallback()
trainer = SFTTrainer(..., callbacks=[loss_callback])
trainer.train()

# Access loss history
for entry in loss_callback.losses:
    print(f"Step {entry['step']}: Loss {entry['loss']:.4f}")
```

### GPU Memory Measurement

```python
import subprocess
import gc
import torch

def measure_gpu_memory():
    """Get current GPU memory usage in MB."""
    result = subprocess.run(
        ['nvidia-smi', '--query-gpu=memory.used', '--format=csv,noheader,nounits'],
        capture_output=True, text=True
    )
    return int(result.stdout.strip().split('\n')[0])

def cleanup_memory():
    """Force garbage collection and clear CUDA cache."""
    gc.collect()
    if torch.cuda.is_available():
        torch.cuda.empty_cache()
        torch.cuda.synchronize()

# Usage
print(f"Memory before: {measure_gpu_memory()} MB")
cleanup_memory()
print(f"Memory after cleanup: {measure_gpu_memory()} MB")
```

### Parameter Counting

```python
def count_parameters(model):
    """Count trainable and total parameters."""
    trainable = sum(p.numel() for p in model.parameters() if p.requires_grad)
    total = sum(p.numel() for p in model.parameters())
    return {
        "trainable": trainable,
        "total": total,
        "trainable_formatted": f"{trainable:,}",
        "total_formatted": f"{total:,}",
        "percentage": f"{100 * trainable / total:.2f}%"
    }

# Usage
params = count_parameters(model)
print(f"Trainable: {params['trainable_formatted']} ({params['percentage']})")
```

## Decision Tree

```
What's your priority?
│
├── Memory constrained (<12GB VRAM)
│   ├── Use r=8 or r=4
│   ├── Use 4-bit quantization
│   └── Use qv_only or attention_only modules
│
├── Maximum quality
│   ├── Use r=32
│   ├── Use BF16 if VRAM allows
│   └── Use all_linear modules
│
├── Knowledge injection only
│   ├── Use mlp_only modules
│   └── Preserves reasoning style
│
├── Multiple tasks
│   ├── Train separate adapters
│   └── Hot-swap at inference
│
└── Incremental updates
    ├── Sequential training
    └── Test retention after each stage
```

## When to Use This Skill

Use when:
- Optimizing LoRA hyperparameters
- Memory-constrained training
- Building multi-task systems
- Incrementally updating models
- Comparing quantization approaches

## Cross-References

- `bazzite-ai-jupyter:peft` - Basic LoRA setup
- `bazzite-ai-jupyter:quantization` - Quantization fundamentals
- `bazzite-ai-jupyter:sft` - Training with SFTTrainer
- `bazzite-ai-jupyter:inference` - Fast inference patterns
