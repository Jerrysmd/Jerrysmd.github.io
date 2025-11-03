---
title: "Reading Happy-LLM Notes: NLP"
# subtitle: ""
date: 2025-11-03T15:51:20+08:00
# lastmod: 2025-11-03T15:51:20+08:00
draft: false
# author: ""
# authorLink: ""
# description: ""
# license: ""
# images: []

tags: ["AI", "LLM", "GPT", "BERT", "Machine Learning", "Deep Learning"]
categories: ["Technology"]

# featuredImage: ""
# featuredImagePreview: ""

hiddenFromHomePage: false
hiddenFromSearch: false
twemoji: false
lightgallery: true
# ruby: true
# fraction: true
# fontawesome: true
# linkToMarkdown: true
# rssFullText: false

toc:
  enable: true
  auto: true
code:
  copy: true
  maxShownLines: 50
math:
  enable: false
#   # ...
# mapbox:
#   # ...
# share:
#   enable: true
#   # ...
comment:
  enable: true
#   # ...
# library:
#   css:
#     # someCSS = "some.css"
#     # located in "assets/"
#     # Or
#     # someCSS = "https://cdn.example.com/some.css"
#   js:
#     # someJS = "some.js"
#     # located in "assets/"
#     # Or
#     # someJS = "https://cdn.example.com/some.js"
# seo:
#   images: []

# admonition:
# {{< admonition tip>}}{{< /admonition >}}
# note abstract info tip success question warning failure danger bug example quote
# mermaid:
# {{< mermaid >}}{{< /mermaid >}}
---
NLP is a subfield of artificial intelligence that focuses on the interaction between computers and human language. It is a branch of artificial intelligence that deals with the processing, understanding, and generation of natural language text written by humans.
<!--more-->

## NLP Fundamentals

Natural Language Processing (NLP) aims to make computers work with human language in a meaningful way. As text becomes the dominant medium for knowledge and communication, advances in NLP let us extract signal from large corpora and model deeper semantics. The field has evolved from rule-based systems to statistical learning and, more recently, to deep learning. Among many building blocks, text representation is especially critical because it directly impacts downstream performance.

### 1.1 What is NLP?

NLP studies how to enable machines to understand, interpret, and generate human language. It draws on computer science, artificial intelligence, linguistics, and cognitive science, with the goal of narrowing the gap between human language and machine processing.

Modern NLP systems handle a wide range of tasks: Chinese word segmentation, subword tokenization, part-of-speech tagging, text classification, named entity recognition, relation extraction, summarization, machine translation, and question answering. Beyond surface form, robust systems model meaning, context, sentiment, and even cultural nuance.

Deep learning has pushed the state of the art by learning complex patterns from large datasets, often reaching or surpassing human-level performance on specific benchmarks. That said, open challenges remain—handling ambiguity, abstract concepts, metaphor, and sarcasm, to name a few. Progress hinges on better algorithms, larger and cleaner data, and more capable language models.

### 1.2 A Brief History of NLP

NLP progressed from rule-based approaches to statistical methods and then to machine learning and deep learning. Each step unlocked new applications—from translation and sentiment analysis to entity recognition and summarization—and continues to broaden NLP’s impact.

- Early exploration (1940s–1960s)
  - Post–World War II, automatic translation became a compelling goal. In 1950, Alan Turing proposed the Turing Test: if a machine can participate in a conversation such that its responses are indistinguishable from a human’s, it can be said to “think.” Around the same time, Noam Chomsky’s generative grammar shaped thinking about language structure. Early MT, however, relied on dictionaries and simple word-order rules and performed poorly.

- Symbolic vs. statistical methods (1970s–1990s)
  - Research bifurcated into symbolic (rule-driven) and statistical paradigms. With growing compute and the rise of machine learning in the 1980s, statistical models began to displace brittle hand-written rules.

- Machine learning and deep learning (2000s–today)
  - Deep architectures—RNNs, LSTMs, attention—became standard. Word2Vec (2013) popularized dense word embeddings. BERT (2018) ushered in pretraining-finetuning at scale. Transformer-based generative models (e.g., GPT family) demonstrated strong few-shot and generative capabilities.

### 1.3 Core NLP Tasks

The foundational tasks span from basic preprocessing to semantic understanding and generation. Below are concise overviews with simple examples.

#### 1.3.1 Chinese Word Segmentation (CWS)

Chinese lacks explicit word boundaries, so segmentation is a prerequisite for most pipelines.

Examples:

```text
English input:  The cat sits on the mat.
English tokens: [The | cat | sits | on | the | mat]

Chinese input:  今天天气真好，适合出去游玩。
Chinese tokens: [今天 | 天气 | 真 | 好 | ， | 适合 | 出去 | 游玩 | 。]
```

Segmentation quality cascades to POS tagging, NER, and parsing. For instance:

```text
Input:  雍和宫的荷花开的很好。

Correct:  雍和宫 | 的 | 荷花 | 开 | 的 | 很 | 好 | 。
Wrong #1:  雍 | 和 | 宫的 | 荷花 | 开的 | 很好 | 。      # place name split
Wrong #2:  雍和 | 宫 | 的荷 | 花开 | 的很 | 好 。         # boundaries garbled
```

#### 1.3.2 Subword Segmentation

Subword methods address out-of-vocabulary and rarity by splitting words into frequent units. Common approaches: BPE, WordPiece, Unigram, SentencePiece.

```text
Input: unhappiness

No subwords:     "unhappiness"
With subwords:   "un" | "happi" | "ness"
```

Even unseen words become interpretable via known morphemes (e.g., “un-” negation, “-ness” nominalizer).

#### 1.3.3 Part-of-Speech (POS) Tagging

Assigns a syntactic category to each token.

```text
She/PRP is/VBZ playing/VBG the/DT guitar/NN in/IN the/DT park/NN ./.
```

Classical models include HMMs and CRFs; modern systems often use RNN/LSTM/Transformer encoders. POS supports parsing, semantic role labeling, and downstream IE tasks.

#### 1.3.4 Text Classification

Maps text to predefined labels (e.g., sentiment, spam, topic).

```text
News: "NBA季后赛将于下周开始，湖人和勇士将在首轮对决。"
Label: 体育 (Sports)

News: "美国总统宣布将提高关税，引发国际贸易争端。"
Label: 政治 (Politics)

News: "苹果公司发布了新款 Macbook，配备最新 m3 芯片。"
Label: 科技 (Technology)
```

Model quality depends on representation, algorithm choice, and data. Deep models excel by capturing higher-order semantics.

#### 1.3.5 Named Entity Recognition (NER)

Identifies and classifies spans such as persons, locations, organizations, dates, etc.

```text
Input:  李雷和韩梅梅是北京市海淀区的居民，他们计划在2024年4月7日去上海旅行。
Output: (李雷, 人名) (韩梅梅, 人名) (北京市海淀区, 地名) (2024年4月7日, 日期) (上海, 地名)
```

NER is central to information extraction, knowledge graph construction, and QA.

#### 1.3.6 Relation Extraction

Finds semantic relations between entities.

```text
Input:  比尔·盖茨是微软公司的创始人。
Output: (比尔·盖茨, 创始人, 微软公司)
```

These triples fuel knowledge graphs and structured reasoning.

#### 1.3.7 Text Summarization

Two broad paradigms:

- **Extractive**: select salient sentences from the source.
- **Abstractive**: generate paraphrases that condense meaning.

Example source:

```text
2021年5月22日，国家航天局宣布，我国自主研发的火星探测器“天问一号”成功在火星表面着陆……
```

Extractive summary:

```text
“天问一号”成功着陆火星，标志着深空探测取得关键进展。
```

Abstractive summary:

```text
“天问一号”实现火星着陆，体现我国在宇宙探索上的重大突破。
```

Summarization underpins IR, news curation, and report generation.

#### 1.3.8 Machine Translation (MT)

Automatically maps source language to target language while preserving meaning and style.

```text
Source: 今天天气很好。
Target: The weather is very nice today.
```

Neural models—Seq2Seq with attention and Transformers—learn rich alignments that enable fluent outputs.

#### 1.3.9 Question Answering (QA)

Answers natural-language questions over text, knowledge bases, or community content. Typical flavors:

- **Retrieval-based QA**: find answers in unstructured corpora.
- **Knowledge-base QA**: query structured graphs.
- **Community QA**: leverage user-generated Q&A.

Better retrieval, understanding, and reasoning steadily lift QA coverage and accuracy.

### 1.4 The Evolution of Text Representations

The goal is to turn raw language into forms a computer can operate on—vectors, matrices, or other structures that preserve meaning efficiently.

#### 1.4.1 Vector Space Model (VSM)

VSM represents text as high-dimensional vectors whose dimensions correspond to features (characters, words, phrases). Weights often come from TF or TF–IDF.

Strengths: simple, effective for similarity and retrieval; amenable to linear algebra (e.g., SVD).

Limitations: extreme sparsity and the curse of dimensionality; independence assumptions ignore order and context; feature engineering and weighting matter.

Example sparsity intuition:

```text
Sentence: "雍和宫 的 荷花 很 美"
Vocab size: 16384 → one-hot style vectors are 99.97% zeros if only 5 terms appear.
```

Two mitigation avenues: improve feature construction (e.g., graph- and topic-based signals) and improve weighting schemes.

#### 1.4.2 Language Models (n-gram)

An n-gram LM assumes each token depends on the previous \(n-1\) tokens. For a trigram model on “The quick brown fox”, we estimate `P(brown | The, quick)` and `P(fox | quick, brown)` and multiply across the sequence.

Pros: conceptually simple and often strong baselines. Cons: data sparsity scales poorly with larger n; limited long-range dependencies.

#### 1.4.3 Word2Vec

Word2Vec (2013) learns dense embeddings by predicting contexts (Skip-gram) or targets from contexts (CBOW). These vectors capture semantic regularities and drastically reduce dimensionality compared to one-hot features. Weaknesses include locality (limited long-range context) and lack of global structure.

#### 1.4.4 ELMo

ELMo introduced contextualized embeddings via bidirectional language models. It follows a two-stage recipe: pretrain a language model; then, for a downstream task, extract contextual vectors and (optionally) finetune. Benefits include word sense disambiguation and richer context sensitivity; costs include higher complexity and training time.