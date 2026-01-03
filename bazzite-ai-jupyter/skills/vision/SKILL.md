---
name: vision
description: |
  Vision model fine-tuning with FastVisionModel. Covers Pixtral, Ministral VL training,
  UnslothVisionDataCollator, image+text datasets, and vision-specific LoRA configuration.
---

# Vision Model Fine-Tuning

## Overview

Unsloth provides `FastVisionModel` for fine-tuning vision-language models (VLMs) like Pixtral and Ministral with 2x faster training. This skill covers vision model loading, dataset preparation with images, and vision-specific LoRA configuration.

## Quick Reference

| Component | Purpose |
|-----------|---------|
| `FastVisionModel` | Load vision models with Unsloth optimizations |
| `UnslothVisionDataCollator` | Handle image+text modality in batches |
| `finetune_vision_layers` | Enable training of vision encoder |
| `finetune_language_layers` | Enable training of language model |
| `skip_prepare_dataset=True` | Required for vision datasets |
| `dataset_text_field=""` | Empty string for vision (not a field name) |
| List dataset format | Use `[convert(s) for s in dataset]`, not `.map()` |

## Critical Environment Setup

```python
import os
from dotenv import load_dotenv
load_dotenv()

# Force text-based progress in Jupyter
os.environ["TQDM_NOTEBOOK"] = "false"
```

## Critical Import Order

```python
# CRITICAL: Import unsloth FIRST for proper TRL patching
import unsloth
from unsloth import FastVisionModel, is_bf16_supported
from unsloth.trainer import UnslothVisionDataCollator

from trl import SFTTrainer, SFTConfig
from datasets import load_dataset
import torch
```

## Supported Vision Models

| Model | Path | Parameters | Best For |
|-------|------|------------|----------|
| Pixtral-12B | `unsloth/pixtral-12b-2409-bnb-4bit` | 12.7B | High-quality vision tasks |
| Ministral-8B-Vision | `unsloth/Ministral-8B-Vision-2507-bnb-4bit` | 8B | Balanced quality/speed |
| Llama-3.2-11B-Vision | `unsloth/Llama-3.2-11B-Vision-Instruct-bnb-4bit` | 11B | General vision tasks |

## Load Vision Model

```python
from unsloth import FastVisionModel, is_bf16_supported

model, tokenizer = FastVisionModel.from_pretrained(
    "unsloth/pixtral-12b-2409-bnb-4bit",
    load_in_4bit=True,
    use_gradient_checkpointing="unsloth",
)

print(f"Model loaded: {type(model).__name__}")
print(f"Tokenizer: {type(tokenizer).__name__}")
```

## Vision-Specific LoRA Configuration

Vision models require special LoRA flags to enable training of vision encoder layers:

```python
model = FastVisionModel.get_peft_model(
    model,
    # Vision-specific flags
    finetune_vision_layers=True,      # Train vision encoder
    finetune_language_layers=True,    # Train language model
    finetune_attention_modules=True,  # Train attention layers
    finetune_mlp_modules=True,        # Train MLP/FFN layers

    # Standard LoRA parameters
    r=16,
    lora_alpha=16,
    lora_dropout=0,
    bias="none",
    random_state=3407,
    use_rslora=False,
    loftq_config=None,
)

# Check trainable parameters
trainable = sum(p.numel() for p in model.parameters() if p.requires_grad)
total = sum(p.numel() for p in model.parameters())
print(f"Trainable: {trainable:,} / {total:,} ({100*trainable/total:.2f}%)")
```

### LoRA Flag Combinations

| Use Case | vision_layers | language_layers | attention | mlp |
|----------|--------------|-----------------|-----------|-----|
| Full fine-tune | True | True | True | True |
| Vision only | True | False | True | True |
| Language only | False | True | True | True |
| Minimal | False | True | True | False |

## Dataset Format

Vision datasets require messages with multi-modal content containing both text and images.

### Image + Text Format

```python
from datasets import Dataset
from PIL import Image

# Sample dataset structure
samples = [
    {
        "image": Image.open("equation1.png"),
        "instruction": "Convert this equation to LaTeX.",
        "response": "\\frac{d}{dx} x^2 = 2x"
    },
    {
        "image": Image.open("equation2.png"),
        "instruction": "What does this equation represent?",
        "response": "This is the quadratic formula: x = \\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}"
    },
]

dataset = Dataset.from_list(samples)
```

### Converting to Chat Format

```python
def convert_to_vision_conversation(sample):
    """Convert sample to vision chat format with image content."""
    messages = [
        {
            "role": "user",
            "content": [
                {"type": "text", "text": sample["instruction"]},
                {"type": "image", "image": sample["image"]}
            ]
        },
        {
            "role": "assistant",
            "content": [
                {"type": "text", "text": sample["response"]}
            ]
        }
    ]
    return {"messages": messages}

# Apply conversion
converted_dataset = dataset.map(convert_to_vision_conversation)
```

### Using HuggingFace Datasets

**Important**: Use list comprehension, NOT `.map()` for vision datasets:

```python
from datasets import load_dataset

# Load LaTeX OCR dataset from HuggingFace (via Unsloth mirror)
dataset = load_dataset("unsloth/LaTeX_OCR", split="train[:100]")

instruction = "Write the LaTeX representation for this image."

def convert_to_conversation(sample):
    """Format sample for vision training."""
    return {
        "messages": [
            {"role": "user", "content": [
                {"type": "text", "text": instruction},
                {"type": "image", "image": sample["image"]}
            ]},
            {"role": "assistant", "content": [
                {"type": "text", "text": sample["text"]}
            ]}
        ]
    }

# CRITICAL: Use list comprehension, NOT .map()
converted_dataset = [convert_to_conversation(s) for s in dataset]
```

**Why list format?** Vision datasets with PIL images work more reliably as plain Python lists than HuggingFace Dataset objects with `.map()`.

## Vision Data Collator

The `UnslothVisionDataCollator` handles image+text batching:

```python
from unsloth.trainer import UnslothVisionDataCollator

data_collator = UnslothVisionDataCollator(model, tokenizer)
```

## Training Configuration

Vision training requires specific SFTConfig settings:

```python
from trl import SFTConfig

sft_config = SFTConfig(
    output_dir="./vision_output",
    per_device_train_batch_size=1,      # Keep low for large vision models
    gradient_accumulation_steps=4,       # Effective batch size = 4
    max_steps=100,                       # Or num_train_epochs=1
    warmup_steps=5,
    learning_rate=2e-4,
    logging_steps=1,

    # Precision settings
    fp16=not is_bf16_supported(),
    bf16=is_bf16_supported(),

    # Optimizer
    optim="adamw_8bit",
    weight_decay=0.01,

    # Sequence length
    max_seq_length=1024,

    # CRITICAL for vision - all 3 are required
    remove_unused_columns=False,         # Keep image column
    dataset_text_field="",               # Empty string (NOT a field name)
    dataset_kwargs={"skip_prepare_dataset": True},  # Required for vision

    # Other
    seed=3407,
    report_to="none",
)
```

**Critical settings explained:**
- `remove_unused_columns=False`: Preserves image column during training
- `dataset_text_field=""`: Empty string tells TRL to use the messages format
- `skip_prepare_dataset=True`: Prevents TRL from processing vision data incorrectly

## SFTTrainer for Vision

```python
from trl import SFTTrainer

trainer = SFTTrainer(
    model=model,
    tokenizer=tokenizer,
    data_collator=UnslothVisionDataCollator(model, tokenizer),
    train_dataset=converted_dataset,
    args=sft_config,
)

# Train
trainer_stats = trainer.train()

print(f"Training completed!")
print(f"Final loss: {trainer_stats.metrics.get('train_loss', 'N/A'):.4f}")
```

## Complete Training Example

This example matches the tested notebook pattern:

```python
# 1. Environment Setup
import os
from dotenv import load_dotenv
load_dotenv()
os.environ["TQDM_NOTEBOOK"] = "false"

# 2. Imports (unsloth FIRST)
import unsloth
from unsloth import FastVisionModel, is_bf16_supported
from unsloth.trainer import UnslothVisionDataCollator
from trl import SFTTrainer, SFTConfig
from datasets import load_dataset

# 3. Load model
model, tokenizer = FastVisionModel.from_pretrained(
    "unsloth/pixtral-12b-2409-bnb-4bit",
    load_in_4bit=True,
    use_gradient_checkpointing="unsloth",
)
print(f"Model loaded: {type(model).__name__}")

# 4. Apply LoRA
model = FastVisionModel.get_peft_model(
    model,
    finetune_vision_layers=True,
    finetune_language_layers=True,
    finetune_attention_modules=True,
    finetune_mlp_modules=True,
    r=16,
    lora_alpha=16,
    lora_dropout=0,
    bias="none",
    random_state=3407,
)
trainable = sum(p.numel() for p in model.parameters() if p.requires_grad)
print(f"LoRA applied ({trainable:,} trainable params)")

# 5. Prepare dataset (use LIST, not .map())
dataset = load_dataset("unsloth/LaTeX_OCR", split="train[:50]")
instruction = "Write the LaTeX representation for this image."

def convert_to_conversation(sample):
    return {
        "messages": [
            {"role": "user", "content": [
                {"type": "text", "text": instruction},
                {"type": "image", "image": sample["image"]}
            ]},
            {"role": "assistant", "content": [
                {"type": "text", "text": sample["text"]}
            ]}
        ]
    }

# CRITICAL: List comprehension, not .map()
converted_dataset = [convert_to_conversation(s) for s in dataset]
print(f"Dataset loaded ({len(converted_dataset)} samples)")

# 6. Configure training
sft_config = SFTConfig(
    output_dir="./vision_lora",
    per_device_train_batch_size=1,
    gradient_accumulation_steps=4,
    max_steps=50,
    warmup_steps=5,
    learning_rate=2e-4,
    logging_steps=1,
    fp16=not is_bf16_supported(),
    bf16=is_bf16_supported(),
    optim="adamw_8bit",
    max_seq_length=1024,
    # CRITICAL for vision - all 3 required
    remove_unused_columns=False,
    dataset_text_field="",
    dataset_kwargs={"skip_prepare_dataset": True},
    seed=3407,
    report_to="none",
)

# 7. Train
trainer = SFTTrainer(
    model=model,
    tokenizer=tokenizer,
    data_collator=UnslothVisionDataCollator(model, tokenizer),
    train_dataset=converted_dataset,
    args=sft_config,
)

trainer_stats = trainer.train()
print(f"Training complete! Loss: {trainer_stats.metrics.get('train_loss', 'N/A'):.4f}")
```

## Inference with Vision Models

### Prepare for Inference

```python
FastVisionModel.for_inference(model)
```

### Generate from Image

```python
from PIL import Image

# Load test image
test_image = Image.open("test_equation.png")

# Format as conversation
messages = [
    {
        "role": "user",
        "content": [
            {"type": "text", "text": "Convert this to LaTeX:"},
            {"type": "image", "image": test_image}
        ]
    }
]

# Apply chat template
inputs = tokenizer.apply_chat_template(
    messages,
    tokenize=True,
    add_generation_prompt=True,
    return_tensors="pt"
).to(model.device)

# Generate
outputs = model.generate(
    input_ids=inputs,
    max_new_tokens=256,
    temperature=0.1,      # Low for accurate transcription
    do_sample=True,
    pad_token_id=tokenizer.pad_token_id,
)

# Decode
response = tokenizer.decode(outputs[0], skip_special_tokens=True)
print(response)
```

### Batch Inference

```python
from PIL import Image

images = [Image.open(f"image_{i}.png") for i in range(3)]
prompts = ["Describe this image.", "What objects are in this image?", "Transcribe the text."]

for img, prompt in zip(images, prompts):
    messages = [
        {"role": "user", "content": [
            {"type": "text", "text": prompt},
            {"type": "image", "image": img}
        ]}
    ]

    inputs = tokenizer.apply_chat_template(
        messages, tokenize=True, add_generation_prompt=True, return_tensors="pt"
    ).to(model.device)

    outputs = model.generate(input_ids=inputs, max_new_tokens=128)
    print(tokenizer.decode(outputs[0], skip_special_tokens=True))
```

## Save and Load

### Save LoRA Adapter

```python
# Save only LoRA weights (~66MB for Pixtral)
model.save_pretrained("./vision_lora")
tokenizer.save_pretrained("./vision_lora")
```

### Save Merged Model

```python
# Save full merged model (large)
model.save_pretrained_merged(
    "./vision_merged",
    tokenizer,
    save_method="merged_16bit",
)
```

### Load for Inference

```python
from unsloth import FastVisionModel

model, tokenizer = FastVisionModel.from_pretrained(
    "./vision_lora",
    load_in_4bit=True,
)
FastVisionModel.for_inference(model)
```

## Memory Requirements

| Model | 4-bit VRAM | Training VRAM |
|-------|------------|---------------|
| Pixtral-12B | ~8GB | ~12GB |
| Ministral-8B-Vision | ~6GB | ~10GB |
| Llama-3.2-11B-Vision | ~7GB | ~11GB |

## Troubleshooting

### Image Not Processed

**Symptom:** Model ignores image content

**Fix:**
- Ensure `remove_unused_columns=False` in SFTConfig
- Use `skip_prepare_dataset=True` in dataset_kwargs
- Verify image is PIL.Image object, not path string

### Out of Memory

**Symptom:** CUDA OOM during vision training

**Fix:**
- Reduce `per_device_train_batch_size` to 1
- Increase `gradient_accumulation_steps`
- Use smaller model (Ministral-8B instead of Pixtral-12B)
- Enable gradient checkpointing

### Poor Generation Quality

**Symptom:** Model outputs nonsense for images

**Fix:**
- Increase training steps (50-100+)
- Check dataset quality (image-text alignment)
- Use lower learning rate (1e-4)
- Ensure vision layers are being trained (`finetune_vision_layers=True`)

### Data Collator Error

**Symptom:** `KeyError` or shape mismatch in data collator

**Fix:**
- Use `UnslothVisionDataCollator(model, tokenizer)`
- Ensure dataset has "messages" field with correct structure
- Check that images are valid PIL.Image objects

## Kernel Shutdown (Jupyter)

Vision models use significant GPU memory. Shutdown kernel to release memory:

```python
import IPython
print("Shutting down kernel to release GPU memory...")
app = IPython.Application.instance()
app.kernel.do_shutdown(restart=False)
```

**Important**: Always run this at the end of training notebooks before switching to different models.

## Use Cases

- **OCR/Document Processing**: LaTeX equation recognition, receipt scanning
- **Image Captioning**: Generate descriptions for images
- **Visual QA**: Answer questions about image content
- **Chart/Graph Analysis**: Extract data from visualizations
- **Medical Imaging**: X-ray, scan analysis (with appropriate data)

## When to Use This Skill

Use when:
- Fine-tuning models to understand images
- Building OCR or document processing pipelines
- Creating image captioning systems
- Developing visual question-answering applications

## Cross-References

- `bazzite-ai-jupyter:sft` - Standard SFT for text-only models
- `bazzite-ai-jupyter:peft` - LoRA configuration details
- `bazzite-ai-jupyter:inference` - Fast inference patterns
- `bazzite-ai-jupyter:quantization` - Memory optimization
