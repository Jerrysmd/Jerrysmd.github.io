# Reading Happy-LLM Notes: Preface

The emergence of ChatGPT changed people's perception of AI and brought about a transformative phase in the field of NLP. LLMs, represented by GPT, have become the mainstream research focus in NLP and even the broader field of AI.
<!--more-->

---

## Preface

### The Evolution of NLP: From PLM to LLM

**LLMs** are actually a derivative achievement of the classic research method of **Pretrained Language Models (PLMs)** in the field of NLP. The field of NLP focuses on the processing, understanding, and generation of natural language text written by humans, and has undergone multiple transformations:

{{< mermaid >}}

graph LR
    A[Symbolic Stage] --> B[Statistical Learning]
    B --> C[Deep Learning]
    C --> D[Pre-training Model]
    D --> E[Large Model Stage]
    
    D --> F[PLM<br/>GPT & BERT]
    E --> G[LLM<br/>ChatGPT & GPT-4]
    
    F --> H[Attention Mechanism<br/>Pre-training & Fine-tuning]
    G --> I[Instruction Fine-tuning<br/>Human Feedback RL]
    
    style A fill:#e1f5fe
    style B fill:#e8f5e8
    style C fill:#fff3e0
    style D fill:#f3e5f5
    style E fill:#ffebee
    style F fill:#e3f2fd
    style G fill:#e8f5e8

{{< /mermaid >}}

- **Symbolic stage** → **Statistical learning stage** → **Deep learning stage** → **Pre-training model stage** → **Current large model stage**

**PLMs** represented by **GPT** and **BERT** are the core research achievements of the previous stage of NLP, with:
- **Attention mechanism** as the model architecture
- **Pre-training and fine-tuning** approach
- **Self-supervised pre-training** on large amounts of unsupervised text

> **However**, traditional PLMs still depend on a certain amount of supervised data for downstream task fine-tuning, and their performance in natural language generation tasks is still not satisfactory. The performance of NLP systems is still **far from the expected general artificial intelligence**, with a significant gap.

### The LLM Breakthrough

**LLMs** are a breakthrough achievement realized by:
- **Expanding model parameters** and pre-training data scale
- **Introducing instruction fine-tuning** and human feedback reinforcement learning

{{< mermaid >}}

graph TB
    subgraph "PLM Era"
        A[Traditional PLM] --> B[Supervised Data Required]
        B --> C[Task-Specific Fine-tuning]
        C --> D[Limited Generation Quality]
    end
    
    subgraph "LLM Era"
        E[Large Language Model] --> F[Few-Shot Learning]
        F --> G[Instruction Following]
        G --> H[High-Quality Generation]
        H --> I[General AI Capabilities]
    end
    
    A --> E
    
    style A fill:#ffcdd2
    style E fill:#c8e6c9
    style I fill:#dcedc8

{{< /mermaid >}}

**Compared with traditional PLMs, LLMs have:**
- ✅ **Emergent capabilities**
- ✅ **Strong contextual learning ability** 
- ✅ **Instruction understanding ability**
- ✅ **Text generation ability**

At the large model stage, NLP researchers can to some extent **abandon a large amount of supervised data annotation work**. Through providing a small amount of supervised examples, LLMs can achieve performance on specified downstream tasks that is **comparable to that of large-scale fine-tuned PLMs**.

> The strong instruction understanding ability and text generation ability enable LLMs to **directly, efficiently, and accurately respond to user instructions**, thus truly approaching the goal of **general artificial intelligence**.

### The Current Landscape and Future

The breakthrough progress in LLMs has **ignited research enthusiasm** in the field of NLP and the entire field of artificial intelligence. Universities, research institutes, major corporations, and even many traditional industry enterprises have joined the wave of LLM research.

**Since 2023, there have been numerous achievements in LLMs:**
- Model performance continuously breaking through the upper limit
- From **ChatGPT** to **GPT-4**
- More powerful and customized models:
  - **Reasoning large models** (e.g., DeepSeek-R1)
  - **Multimodal large models** (e.g., Qwen-VL)

**LLM applications have emerged**, bringing innovative applications that:
- ✅ Enhance actual productivity
- ✅ Empower users' daily lives

From the **"hundred models battle"** to the **"Agent Year"**, the research on LLMs may have reached a stable structure, but the research on LLMs is **still in full swing**.

> **It is certain that in the not-too-distant future, LLMs and applications based on LLMs will definitely become infrastructure in people's lives, closely intertwined with everyone's life, study, and work.**
