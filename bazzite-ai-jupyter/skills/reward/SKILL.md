---
name: reward
description: |
  Reward model training for RLHF pipelines. Covers RewardTrainer, preference dataset
  preparation, sequence classification heads, and reward scaling for stable
  reinforcement learning.
---

# Reward Model Training

## Overview

Reward models learn to score responses based on human preferences. They're used in RLHF pipelines (PPO, GRPO, RLOO) to provide reward signals for policy optimization. The model outputs a scalar reward for each response.

## Quick Reference

| Component | Purpose |
|-----------|---------|
| `RewardTrainer` | Trainer for reward model |
| `RewardConfig` | Training hyperparameters |
| `AutoModelForSequenceClassification` | Model with classification head |
| Preference pairs | Training data format |

## Reward Model Concepts

### How Reward Models Work

1. Take prompt + response as input
2. Output scalar reward score
3. Trained on preference pairs (chosen > rejected)
4. Used to guide RL policy optimization

### Architecture

```
Input: [prompt + response]
  ↓
Base LLM (frozen or LoRA)
  ↓
Classification Head (Linear → Scalar)
  ↓
Output: Reward score (float)
```

## Dataset Format

### Required Fields

```python
dataset = [
    {
        "prompt": "What is recursion?",
        "chosen": "Recursion is a function calling itself with a base case.",
        "rejected": "Recursion is loops."
    },
    # ... more preference pairs
]
```

### Preprocessing

```python
def format_for_reward(sample):
    prompt = tokenizer.apply_chat_template(
        [{"role": "user", "content": sample["prompt"]}],
        tokenize=False, add_generation_prompt=True
    )
    return {
        "input_ids_chosen": tokenizer(prompt + sample["chosen"])["input_ids"],
        "input_ids_rejected": tokenizer(prompt + sample["rejected"])["input_ids"],
    }
```

## Setup

### Load Reward Model

```python
from transformers import AutoModelForSequenceClassification, AutoTokenizer

model = AutoModelForSequenceClassification.from_pretrained(
    "unsloth/Qwen3-4B-unsloth-bnb-4bit",
    num_labels=1,  # Single scalar output
    load_in_4bit=True,
    device_map="auto",
)

tokenizer = AutoTokenizer.from_pretrained("unsloth/Qwen3-4B-unsloth-bnb-4bit")
```

### Apply LoRA

```python
from peft import LoraConfig, get_peft_model

lora_config = LoraConfig(
    r=16,
    lora_alpha=16,
    lora_dropout=0,
    target_modules=["q_proj", "k_proj", "v_proj", "o_proj",
                    "gate_proj", "up_proj", "down_proj"],
    bias="none",
    task_type="SEQ_CLS",
)

model = get_peft_model(model, lora_config)
```

## RewardTrainer Configuration

### Basic Configuration

```python
from trl import RewardConfig

reward_config = RewardConfig(
    output_dir="./reward_output",
    per_device_train_batch_size=2,
    gradient_accumulation_steps=4,
    max_steps=100,
    learning_rate=1e-5,
    fp16=not is_bf16_supported(),
    bf16=is_bf16_supported(),
    optim="adamw_8bit",
    max_length=512,
)
```

### Key Parameters

| Parameter | Typical Values | Effect |
|-----------|----------------|--------|
| `learning_rate` | 1e-5 to 5e-5 | Training speed |
| `max_length` | 512-1024 | Input truncation |
| `center_rewards_coefficient` | 0.0-0.1 | Reward centering |

## Training

### Basic Training

```python
from trl import RewardTrainer

trainer = RewardTrainer(
    model=model,
    args=reward_config,
    train_dataset=dataset,
    processing_class=tokenizer,
)

trainer.train()
```

## Using the Reward Model

### Score Responses

```python
def get_reward(prompt, response):
    text = prompt + response
    inputs = tokenizer(text, return_tensors="pt", truncation=True)
    inputs = {k: v.to(model.device) for k, v in inputs.items()}

    with torch.no_grad():
        outputs = model(**inputs)
        reward = outputs.logits[0, 0].item()

    return reward

# Example
score = get_reward("What is Python?", "A programming language.")
print(f"Reward: {score:.3f}")
```

### Batch Scoring

```python
def get_rewards_batch(prompts, responses):
    texts = [p + r for p, r in zip(prompts, responses)]
    inputs = tokenizer(texts, return_tensors="pt", padding=True, truncation=True)
    inputs = {k: v.to(model.device) for k, v in inputs.items()}

    with torch.no_grad():
        outputs = model(**inputs)
        rewards = outputs.logits[:, 0].tolist()

    return rewards
```

### In GRPO/RLOO

```python
def reward_fn(completions, prompts):
    return get_rewards_batch(prompts, completions)

grpo_trainer = GRPOTrainer(
    model=policy_model,
    args=grpo_config,
    train_dataset=dataset,
    reward_funcs=reward_fn,
)
```

## Reward Scaling

### Normalize Rewards

```python
def normalized_reward(completions, prompts):
    raw_rewards = get_rewards_batch(prompts, completions)
    mean = sum(raw_rewards) / len(raw_rewards)
    std = (sum((r - mean) ** 2 for r in raw_rewards) / len(raw_rewards)) ** 0.5
    return [(r - mean) / (std + 1e-8) for r in raw_rewards]
```

### Clip Rewards

```python
def clipped_reward(completions, prompts):
    rewards = get_rewards_batch(prompts, completions)
    return [max(-1.0, min(1.0, r)) for r in rewards]
```

## Troubleshooting

### Poor Discrimination

**Symptom:** Similar scores for chosen and rejected

**Fix:**
- More training steps
- Higher learning rate
- Check data quality

### Reward Hacking

**Symptom:** RL model exploits reward model

**Fix:**
- Add diversity in training data
- Ensemble multiple reward models
- Regularization during RL

### Overconfident Scores

**Symptom:** Extreme reward values

**Fix:**
- Use `center_rewards_coefficient`
- Normalize outputs
- Clip reward range

### Memory Issues

**Symptom:** OOM during training

**Fix:**
- Use LoRA instead of full fine-tuning
- Reduce `max_length`
- Smaller batch size

## When to Use This Skill

Use when:

- Building RLHF pipelines
- Need explicit reward signal
- Have preference data
- Want interpretable scoring
- Planning to use GRPO or RLOO

## Cross-References

- `bazzite-ai-jupyter:grpo` - Uses reward models for RL
- `bazzite-ai-jupyter:rloo` - Uses reward models for RL
- `bazzite-ai-jupyter:dpo` - Alternative that doesn't need reward model
- `bazzite-ai-jupyter:peft` - LoRA for efficient reward training
