---
name: evaluation
description: |
  LLM evaluation and prompt optimization with Evidently.ai. Covers text
  descriptors, dataset metrics, LLM-as-a-Judge patterns, and automated
  prompt optimization for classification and generation tasks.
---

# LLM Evaluation with Evidently.ai

## Overview

Evidently.ai provides tools for evaluating LLM outputs using descriptors (row-level metrics) and reports. It supports automated prompt optimization and LLM-as-a-Judge patterns for quality assessment.

## Quick Reference

| Component | Purpose |
|-----------|---------|
| `Dataset` | Wrapper for evaluation data |
| `Descriptor` | Row-level score or label |
| `Report` | Aggregate metrics |
| `TextEvals` | Text quality metrics |
| `LLMJudge` | LLM-based evaluation |
| `PromptOptimizer` | Automated prompt tuning |

## Basic Setup

```python
import pandas as pd
from evidently import Dataset, DataDefinition
from evidently.descriptors import TextLength, Sentiment, WordCount

# Sample data
data = [
    {"question": "What is Python?", "answer": "Python is a programming language."},
    {"question": "Explain AI.", "answer": "AI is artificial intelligence."},
]

df = pd.DataFrame(data)

# Define data structure
definition = DataDefinition(text_columns=["question", "answer"])

# Create Evidently Dataset
eval_dataset = Dataset.from_pandas(df, data_definition=definition)
```

## Text Descriptors

### Basic Metrics

```python
from evidently.descriptors import TextLength, WordCount, Sentiment

# Add descriptors
eval_dataset.add_descriptors(descriptors=[
    TextLength(column="answer"),
    WordCount(column="answer"),
    Sentiment(column="answer")
])

# View results
eval_dataset.as_dataframe()
```

### Available Descriptors

| Descriptor | Description |
|------------|-------------|
| `TextLength` | Character count |
| `WordCount` | Word count |
| `Sentiment` | Sentiment score (-1 to 1) |
| `RegexMatch` | Regex pattern matching |
| `Contains` | Substring presence |
| `IsValidJSON` | JSON validity check |
| `IsValidPython` | Python syntax check |

## LLM-as-a-Judge

### Binary Classification

```python
import os
from evidently.descriptors import LLMJudge
from evidently.llm import OpenAIProvider

OLLAMA_HOST = os.getenv("OLLAMA_HOST", "http://ollama:11434")
MODEL = "hf.co/NousResearch/Nous-Hermes-2-Mistral-7B-DPO-GGUF:Q4_K_M"

# Configure Ollama as provider
provider = OpenAIProvider(
    base_url=f"{OLLAMA_HOST}/v1",
    api_key="ollama",
    model=MODEL
)

# Create judge
judge = LLMJudge(
    provider=provider,
    template="Is this answer helpful? Answer YES or NO.\n\nQuestion: {question}\nAnswer: {answer}",
    include_reasoning=True
)

eval_dataset.add_descriptors(descriptors=[judge])
```

### Multi-Class Classification

```python
from evidently.descriptors import LLMJudge

judge = LLMJudge(
    provider=provider,
    template="""Classify this query into one category: BOOKING, CANCELLATION, GENERAL.

Query: {query}

Category:""",
    options=["BOOKING", "CANCELLATION", "GENERAL"],
    include_reasoning=True
)
```

### Quality Scoring

```python
from evidently.descriptors import LLMJudge

quality_judge = LLMJudge(
    provider=provider,
    template="""Rate this code review on a scale of 1-5.

Code Review: {review}

Score (1-5):""",
    score_range=(1, 5)
)
```

## Prompt Optimization

### Setup Optimizer

```python
from evidently.llm import PromptOptimizer, OpenAIProvider

OLLAMA_HOST = os.getenv("OLLAMA_HOST", "http://ollama:11434")
MODEL = "hf.co/NousResearch/Nous-Hermes-2-Mistral-7B-DPO-GGUF:Q4_K_M"

provider = OpenAIProvider(
    base_url=f"{OLLAMA_HOST}/v1",
    api_key="ollama",
    model=MODEL
)

optimizer = PromptOptimizer(
    provider=provider,
    max_iterations=10
)
```

### Binary Classification Optimization

```python
# Initial prompt template
initial_prompt = """Classify if this code review is good or bad.

Review: {review}

Answer (GOOD or BAD):"""

# Define judge for evaluation
judge = LLMJudge(
    provider=provider,
    template=initial_prompt,
    options=["GOOD", "BAD"]
)

# Run optimization
best_prompt = optimizer.optimize(
    dataset=eval_dataset,
    initial_template=initial_prompt,
    target_column="label",  # Ground truth column
    judge=judge
)

print("Best prompt found:")
print(best_prompt)
```

### Multi-Class Optimization

```python
initial_prompt = """Classify this query.

Query: {query}

Category (BOOKING/CANCELLATION/GENERAL):"""

judge = LLMJudge(
    provider=provider,
    template=initial_prompt,
    options=["BOOKING", "CANCELLATION", "GENERAL"]
)

best_prompt = optimizer.optimize(
    dataset=dataset,
    initial_template=initial_prompt,
    target_column="category",
    judge=judge
)
```

## Reports

### Generate Report

```python
from evidently import Report
from evidently.metrics import TextDescriptorsDriftMetric

report = Report(metrics=[
    TextDescriptorsDriftMetric(column="answer")
])

report.run(reference_data=reference_dataset, current_data=current_dataset)
report.show()
```

### Save Report

```python
report.save_html("evaluation_report.html")
report.save_json("evaluation_report.json")
```

## Common Patterns

### Evaluate RAG Quality

```python
from evidently.descriptors import LLMJudge, TextLength, Contains

# Relevance judge
relevance_judge = LLMJudge(
    provider=provider,
    template="""Is this answer relevant to the question?

Question: {question}
Answer: {answer}

Answer YES or NO:"""
)

# Factuality judge
factuality_judge = LLMJudge(
    provider=provider,
    template="""Is this answer factually accurate based on the context?

Context: {context}
Answer: {answer}

Answer YES or NO:"""
)

eval_dataset.add_descriptors([
    relevance_judge,
    factuality_judge,
    TextLength(column="answer")
])
```

### Compare Models

```python
# Evaluate model A
model_a_dataset = run_inference(model_a, test_data)
model_a_dataset.add_descriptors([quality_judge])

# Evaluate model B
model_b_dataset = run_inference(model_b, test_data)
model_b_dataset.add_descriptors([quality_judge])

# Compare
print("Model A average score:", model_a_dataset.as_dataframe()["quality"].mean())
print("Model B average score:", model_b_dataset.as_dataframe()["quality"].mean())
```

## Troubleshooting

### Slow Evaluation

**Symptom:** Evaluation takes too long

**Fix:**

- Reduce dataset size for initial testing
- Use smaller/faster judge model
- Batch requests where possible

### Inconsistent Judgments

**Symptom:** LLM judge gives inconsistent scores

**Fix:**

- Lower temperature (0.0-0.3)
- Make prompt more specific
- Add examples to prompt
- Use structured output options

### Optimization Not Improving

**Symptom:** Prompt optimization stuck

**Fix:**

- Increase `max_iterations`
- Try different initial prompts
- Check ground truth labels are correct
- Use more training examples

## When to Use This Skill

Use when:

- Measuring LLM output quality
- Comparing different prompts
- Automating prompt engineering
- Building evaluation pipelines
- Monitoring LLM performance over time

## Cross-References

- `bazzite-ai-jupyter:langchain` - LangChain for LLM calls
- `bazzite-ai-jupyter:rag` - RAG evaluation patterns
- `bazzite-ai-ollama:openai` - Ollama OpenAI compatibility
