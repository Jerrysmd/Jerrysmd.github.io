---
title: "Different Prompt Styles for different companies"
# subtitle: ""
date: 2025-11-06T17:53:17+08:00
# lastmod: 2025-11-06T17:53:17+08:00
draft: false
# author: ""
# authorLink: ""
# description: ""
# license: ""
# images: []

tags: ["AI", "LLM", "GPT", "Prompt"]
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
A fascinating cultural divergence can be observed in the art of crafting prompts for large language models (LLMs), particularly between China's tech giants, Baidu and Alibaba. While both companies are at the forefront of AI development, their internal prompt engineering styles are remarkably different, reflecting their unique corporate cultures and technical approaches.
<!--more-->

## Language and Syntax: A Tale of Two Styles

One of the most immediate differences is the language used in prompts. At Baidu, there is a strong preference for writing prompts purely in Chinese. This approach is deeply rooted in the company's focus on the Chinese market and its extensive work in Chinese natural language processing. The prompts are often concise and idiomatic, leveraging the nuances of the Chinese language to guide the model's output.

In stark contrast, Alibaba's prompt engineers frequently use a mix of Chinese and English. It's common to see prompts where technical terms, framework names, and key instructions are in English, while the main narrative or context is in Chinese. This hybrid approach likely stems from Alibaba's global ambitions and the widespread use of English in the international tech community.

Another significant distinction lies in the use of syntax. Alibaba has a strong affinity for using angle brackets and XML-like tags in their prompts. This structured approach allows for a clear separation of different parts of the prompt, such as context, instructions, and examples. For instance, you might see a prompt structured like this:

```xml
<context>
  [Some background information]
</context>
<instructions>
  [Specific tasks for the model]
</instructions>
<example>
  [A sample input and desired output]
</example>
```

This method provides a clear and machine-readable format that helps the model understand the different components of the request. On the other hand, Baidu's prompts tend to be more free-form, relying on natural language instructions without such explicit structuring.

### Practical Examples

Let's consider a practical example. Suppose we want the LLM to act as a travel guide and recommend a three-day itinerary for a trip to Beijing. Here’s how the prompts might differ:

**Baidu-Style Prompt (Pure Chinese, Conversational):**

```
你是一个北京旅游专家，请帮我规划一个为期三天的北京旅游行程，要包含经典的必去景点，也要有一些本地人喜欢去的小众地方，另外，请推荐一些特色的北京美食。
```

**Alibaba-Style Prompt (Chinese-English Mix, XML-like Structure):**

```xml
<task>
  You are an expert travel guide for Beijing.
</task>
<instructions>
  - Create a 3-day travel itinerary for a trip to Beijing.
  - Include classic, must-see attractions (e.g., Great Wall, Forbidden City).
  - Add some niche spots favored by locals.
  - Recommend authentic Beijing cuisine.
</instructions>
<output_format>
  Please provide the itinerary in a day-by-day format.
</output_format>
```

## Effectiveness and Model Hallucinations

The structured nature of Alibaba's prompts often leads to more consistent and predictable outputs. By explicitly defining the roles, instructions, and output formats, the model is given a clearer roadmap to follow. This reduces ambiguity and minimizes the chances of the model deviating from the desired task. The use of English for technical terms also aligns with the training data of many foundational LLMs, which can improve the model's understanding of the request.

On the other hand, Baidu's conversational style, while more natural for humans, can sometimes be less effective for complex tasks. The lack of explicit structure can lead to ambiguity, and the model might misinterpret the user's intent. This is not to say that Baidu's approach is inferior; it can be highly effective for creative and open-ended tasks where a more human-like interaction is desired.

This difference in style also has implications for model hallucinations. A model is more likely to hallucinate—that is, generate plausible but incorrect or nonsensical information—when the prompt is ambiguous or lacks sufficient context. Therefore, the free-form, conversational style of Baidu's prompts may have a slightly higher tendency to produce hallucinations, especially if the request is complex or requires specific, factual information. The model might fill in the gaps with plausible-sounding but inaccurate details.

In contrast, Alibaba's structured approach, with its clear context and instructions, helps to ground the model and reduce the likelihood of hallucinations. By providing a well-defined framework, the model has less room for creative interpretation and is more likely to stick to the provided information and instructions.

## Frameworks and Methodologies

The differences in style also extend to the frameworks and methodologies used for prompt engineering. While both companies are familiar with a wide range of techniques, they tend to favor different approaches.

At Alibaba, there is a strong emphasis on structured prompting frameworks like **ICIO (Instruction, Context, Input, Output)**. This framework encourages engineers to break down their prompts into these four key components, ensuring that all necessary information is provided to the model in a clear and organized manner. The use of XML-like tags aligns perfectly with this structured approach.

Other frameworks and techniques that are popular at Alibaba include:

*   **APE (Automatic Prompt Engineer):** This involves using LLMs to automatically generate and optimize prompts, which is a testament to Alibaba's focus on automation and scalability.
*   **TAG (Tune-Generate-Audit-Go):** A systematic process for iterating on and improving prompts, which reflects a rigorous and data-driven approach to prompt engineering.
*   **RTF (Retrieval-based Task Formulation):** This involves retrieving relevant information from a knowledge base and incorporating it into the prompt, which is crucial for tasks that require up-to-date or domain-specific knowledge.
*   **TRCE (Task-Role-Context-Example):** A comprehensive framework that encourages engineers to define the task, the role of the AI, the context of the request, and to provide clear examples.

At Baidu, while these frameworks are known, there is a greater emphasis on the **CHAT** style of prompting, where the interaction with the model is more conversational. This approach is more akin to having a dialogue with the model, where the prompt engineer iteratively refines the instructions based on the model's responses. This style is well-suited for creative and exploratory tasks.

In conclusion, the prompt engineering styles at Baidu and Alibaba are a reflection of their broader corporate philosophies. Baidu's approach is more language-centric and conversational, while Alibaba's is more structured, and globally-oriented. Both have their strengths and are effective in their respective contexts. For a prompt engineer, it is a valuable experience to learn and adapt to these different ways of thinking about and interacting with LLMs.
