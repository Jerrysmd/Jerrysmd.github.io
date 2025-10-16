---
title: "AI Turbo Quick-Start Handbook"
# subtitle: ""
date: 2025-10-13T04:13:31+08:00
# lastmod: 2025-04-02T04:13:31+08:00
draft: true
# author: ""
# authorLink: ""
# description: ""
# license: ""
# images: []

tags: ["AI", "GPT", "BERT", "Machine Learning", "Deep Learning"]
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
We all can chat with LLM through prompt, but what is the algorithm before LLM? What are the key development stages in the algorithmic world? And why is the route of LLM moving towards larger models? This handbook will take you through the key points of AI development, and help you quickly understand the core concepts and technologies in the field of artificial intelligence.
---

# Machine Learning

## Model Automation

We do not intervene and let the machine (for ease of understanding, it can be considered as a running piece of code) help us produce a more scientific algorithm formula to replace our rule formula. In other words, let the model recognize this potential rule formula (pattern, rule). We call this lazy method machine learning.

The concept of machine learning is very broad. We refer to the most basic machine learning methods as traditional machine learning. With the development of neural networks, deep learning (neural networks with sufficiently deep and multiple layers of neurons) has emerged as a key branch of machine learning. The large models we are familiar with today are a subfield of deep learning

So their relationship is machine learning > artificial neural network > deep learning > large model, which is a hierarchical inclusion relationship.

## Understanding Model

From a mathematical perspective, the formula for pd is a linear equation, generally written as f(x) = wx + b. For ease of understanding, we hide the intercept (also called bias) b. Linear equations are very intuitive. If f(x) = 2x (w = 2, b = 0)