---
name: rloo
description: |
  Reinforcement Learning with Leave-One-Out estimation for policy optimization.
  Covers RLOOTrainer, reward function integration, baseline estimation, and
  variance reduction techniques for stable RL training.
---

# Reinforcement Learning with Leave-One-Out (RLOO)

## Overview

RLOO is a reinforcement learning method that uses leave-one-out baseline estimation for variance reduction. Like GRPO, it generates multiple completions per prompt but uses a different baseline computation that can provide more stable gradients.

## Quick Reference

| Component | Purpose |
|-----------|---------|
| `RLOOTrainer` | RL trainer with RLOO baseline |
| `RLOOConfig` | Training hyperparameters |
| `reward_model` | Reward function or model |
| `num_generations` | Completions per prompt |

## RLOO Concepts

### How RLOO Works

1. Generate K completions for each prompt
2. Score all completions with reward function
3. For each completion, compute baseline as mean of other K-1 rewards
4. Advantage = reward - leave-one-out baseline
5. Update policy using advantages

### Leave-One-Out Baseline

```
For completion i:
  baseline_i = mean(rewards except reward_i)
  advantage_i = reward_i - baseline_i

This reduces variance compared to:
  - Single-sample estimates (high variance)
  - Fixed baselines (may be inaccurate)
```

### Comparison with GRPO

| Aspect | RLOO | GRPO |
|--------|------|------|
| Baseline | Leave-one-out mean | Group mean |
| Variance | Lower | Higher |
| Compute | Similar | Similar |
| Stability | Often better | Good |

## Dataset Format

```python
# RLOO requires prompts only (completions generated during training)
dataset = Dataset.from_dict({
    "prompt": [
        tokenizer.apply_chat_template(
            [{"role": "user", "content": "Explain recursion."}],
            tokenize=False, add_generation_prompt=True
        ),
        # ... more prompts
    ]
})
```

## Setup

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

## RLOOTrainer Configuration

### Basic Configuration

```python
from trl import RLOOConfig

rloo_config = RLOOConfig(
    output_dir="./rloo_output",
    per_device_train_batch_size=1,
    gradient_accumulation_steps=4,
    max_steps=100,
    learning_rate=1e-5,
    fp16=not is_bf16_supported(),
    bf16=is_bf16_supported(),
    optim="adamw_8bit",
    num_generations=4,
    max_completion_length=128,
    kl_coef=0.05,
)
```

### Key Parameters

| Parameter | Typical Values | Effect |
|-----------|----------------|--------|
| `num_generations` | 4-8 | Completions per prompt |
| `kl_coef` | 0.01-0.1 | KL penalty strength |
| `learning_rate` | 1e-6 to 1e-5 | Lower than SFT |
| `max_completion_length` | 64-256 | Generation length |

## Reward Functions

### Simple Reward Function

```python
def length_reward(completions, prompts=None):
    """Reward based on response quality heuristics."""
    rewards = []
    for completion in completions:
        length = len(completion.split())
        score = 0.0

        # Prefer medium length
        if 10 <= length <= 50:
            score += 1.0
        elif length < 10:
            score -= 0.5

        # Prefer complete sentences
        if completion.strip().endswith("."):
            score += 0.5

        rewards.append(score)
    return rewards
```

### Using Trained Reward Model

```python
def trained_reward(completions, prompts):
    """Use trained reward model."""
    return reward_model.get_rewards(prompts, completions)
```

## Training

### Basic Training

```python
from trl import RLOOTrainer

trainer = RLOOTrainer(
    model=model,
    args=rloo_config,
    train_dataset=dataset,
    processing_class=tokenizer,
    reward_model=length_reward,
)

trainer.train()
```

### With Reward Model Instance

```python
trainer = RLOOTrainer(
    model=model,
    args=rloo_config,
    train_dataset=dataset,
    processing_class=tokenizer,
    reward_model=trained_reward_model,
)
```

## num_generations Selection

| K | Use Case |
|---|----------|
| 2 | Minimum (limited variance reduction) |
| 4 | Standard (recommended) |
| 8 | Better baseline estimation (more compute) |
| 16+ | Diminishing returns |

**Trade-off:** Higher K = better baseline but more memory/compute

## Troubleshooting

### High Variance

**Symptom:** Unstable training, jumpy rewards

**Fix:**
- Increase `num_generations` to 6-8
- Lower `learning_rate`
- Increase `kl_coef`

### KL Divergence Explosion

**Symptom:** Model output degrades quickly

**Fix:**
- Increase `kl_coef` to 0.1
- Reduce `learning_rate`
- More frequent evaluation

### Reward Collapse

**Symptom:** All generations get similar rewards

**Fix:**
- Check reward function diversity
- Increase `temperature` during generation
- More diverse prompts

### Memory Issues

**Symptom:** OOM with multiple generations

**Fix:**
- Reduce `num_generations` to 2-4
- Reduce `max_completion_length`
- Use gradient checkpointing

## When to Use This Skill

Use when:

- Want lower variance than GRPO
- Have compute for multiple generations
- Building RLHF pipelines
- Need stable RL training
- Policy optimization from rewards

## Cross-References

- `bazzite-ai-jupyter:sft` - Pre-training before RLOO
- `bazzite-ai-jupyter:grpo` - Alternative RL method
- `bazzite-ai-jupyter:reward` - Training reward models for RLOO
- `bazzite-ai-jupyter:dpo` - Simpler alternative (no RL)
- `bazzite-ai-jupyter:peft` - LoRA for efficient training
