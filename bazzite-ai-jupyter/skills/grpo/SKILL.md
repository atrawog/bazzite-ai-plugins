---
name: grpo
description: |
  Group Relative Policy Optimization for reinforcement learning from human feedback.
  Covers GRPOTrainer, reward function design, policy optimization, and KL divergence
  constraints for stable RLHF training.
---

# Group Relative Policy Optimization (GRPO)

## Overview

GRPO is a reinforcement learning method for LLM alignment. It generates multiple completions per prompt, scores them with a reward function, and optimizes the policy to favor higher-reward responses using relative policy gradients.

## Quick Reference

| Component | Purpose |
|-----------|---------|
| `GRPOTrainer` | RL trainer for policy optimization |
| `GRPOConfig` | Training hyperparameters |
| `reward_funcs` | Reward function(s) for scoring |
| `beta` | KL penalty coefficient |
| `num_generations` | Completions per prompt |

## GRPO Concepts

### How GRPO Works

1. Generate multiple completions for each prompt
2. Score completions with reward function(s)
3. Compute relative advantages within each group
4. Update policy to favor higher-reward completions
5. Apply KL penalty to prevent divergence from reference

### Key Differences from PPO

| Aspect | GRPO | PPO |
|--------|------|-----|
| Baseline | Group relative | Value function |
| Critic | Not needed | Required |
| Memory | Lower | Higher |
| Stability | Good | Can be unstable |

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

### Dataset Format

```python
# GRPO requires prompts only (completions generated during training)
dataset = Dataset.from_dict({
    "prompt": [
        tokenizer.apply_chat_template(
            [{"role": "user", "content": "What is recursion?"}],
            tokenize=False, add_generation_prompt=True
        ),
        # ... more prompts
    ]
})
```

## Reward Functions

### Simple Reward Function

```python
def length_reward(completions, prompts=None):
    """Reward based on response length."""
    rewards = []
    for completion in completions:
        length = len(completion.split())
        if length < 5:
            rewards.append(-1.0)
        elif length < 50:
            rewards.append(1.0)
        else:
            rewards.append(0.5)
    return rewards
```

### LLM-as-Judge Reward

```python
def llm_judge_reward(completions, prompts):
    """Use another LLM to score responses."""
    rewards = []
    for prompt, completion in zip(prompts, completions):
        score = judge_model.evaluate(prompt, completion)
        rewards.append(score)
    return rewards
```

### Rule-Based Reward

```python
def format_reward(completions, prompts=None):
    """Reward proper formatting."""
    rewards = []
    for completion in completions:
        score = 0.0
        if completion.endswith("."):
            score += 0.5
        if not completion.startswith(" "):
            score += 0.5
        rewards.append(score)
    return rewards
```

### Composite Rewards

```python
def combined_reward(completions, prompts):
    """Combine multiple reward signals."""
    length_scores = length_reward(completions)
    format_scores = format_reward(completions)
    return [0.5 * l + 0.5 * f for l, f in zip(length_scores, format_scores)]
```

## GRPOTrainer Configuration

### Basic Configuration

```python
from trl import GRPOConfig

grpo_config = GRPOConfig(
    output_dir="./grpo_output",
    per_device_train_batch_size=1,
    gradient_accumulation_steps=4,
    max_steps=100,
    learning_rate=1e-5,
    fp16=not is_bf16_supported(),
    bf16=is_bf16_supported(),
    optim="adamw_8bit",
    max_completion_length=128,
    num_generations=4,
    beta=0.1,
)
```

### Key Parameters

| Parameter | Typical Values | Effect |
|-----------|----------------|--------|
| `beta` | 0.01-0.1 | KL penalty strength |
| `num_generations` | 2-8 | Completions per prompt |
| `max_completion_length` | 64-256 | Generation length |
| `learning_rate` | 1e-6 to 1e-5 | Lower than SFT |

## Training

### Basic Training Loop

```python
from trl import GRPOTrainer

trainer = GRPOTrainer(
    model=model,
    args=grpo_config,
    train_dataset=dataset,
    processing_class=tokenizer,
    reward_funcs=length_reward,
)

trainer.train()
```

### Multiple Reward Functions

```python
trainer = GRPOTrainer(
    model=model,
    args=grpo_config,
    train_dataset=dataset,
    processing_class=tokenizer,
    reward_funcs=[length_reward, format_reward],
    reward_weights=[0.5, 0.5],
)
```

## Troubleshooting

### Reward Hacking

**Symptom:** Model exploits reward function (e.g., always outputs same length)

**Fix:**
- Add diversity penalties
- Use multiple reward signals
- Cap maximum reward

### KL Divergence Too High

**Symptom:** Policy diverges too far from reference

**Fix:**
- Increase `beta` (stronger KL penalty)
- Reduce `learning_rate`
- Fewer training steps

### Training Instability

**Symptom:** Loss spikes or NaN

**Fix:**
- Lower `learning_rate` to 5e-6
- Reduce `num_generations` to 2
- Check reward scale (should be roughly -1 to 1)

### Memory Issues

**Symptom:** OOM with multiple generations

**Fix:**
- Reduce `num_generations` to 2
- Use gradient checkpointing
- Reduce `max_completion_length`

## When to Use This Skill

Use when:

- Aligning models with human preferences
- Optimizing for specific behaviors
- Post-SFT refinement
- Building reward-driven systems
- Simpler alternative to PPO

## Cross-References

- `bazzite-ai-jupyter:sft` - Pre-training before GRPO
- `bazzite-ai-jupyter:dpo` - Simpler preference learning (no reward model)
- `bazzite-ai-jupyter:reward` - Training reward models for GRPO
- `bazzite-ai-jupyter:peft` - LoRA for efficient RL
- `bazzite-ai-ollama:api` - Reward model inference
