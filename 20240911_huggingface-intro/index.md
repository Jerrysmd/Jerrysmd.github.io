# Introduction to Hugging Face: From API to Fine-Tuning


This guide provides a practical introduction to the Hugging Face ecosystem. You'll learn how to find and use models via the API, work with key components like Transformers and Tokenizers, and grasp the fundamentals of fine-tuning. Finally, we cover designing, training, and evaluating custom models for downstream tasks.

<!--more-->

## Hugging face intro

The paltform where the machine learning community collaborates on models, datasets, and applications.

Hugging Face provide `transformers` library, which is using to load and use pre-trained models. It also provides `datasets` library, which is used to load datasets. The `tokenizers` library is used to tokenize text data.

```bash
pip install transformers datasets tokenizers
```

## Models categories and download

### Categories

The models are categorized into different types.

#### Task

+ Text Generation: GPT, BERT, T5, etc.
+ Any-to-Any: Translation, Summarization, etc.
+ Image-Text-to-Text: CLIP, BLIP, etc.
+ Text-to-Video: VideoGPT, etc.

#### Parameters

+ < 1B: gpt2
+ 1B - 6B: whisper-large-v3
+ 6B - 12B: qwen2
+ 12B - 32B: DeepSeek-R1-Distill-Qwen-14B
+ 32B - 128B: LLaMA-2-70B
+ 128B - 500B: DeepSeek-V2.5
+ \> 500B: DeepSeek-R1

#### Libraries

+ Pytorch: The primary deep learning framework, offering flexibility for building and training most Hugging Face models.
+ TensorFlow: A powerful, production-ready framework also supported by Hugging Face for building and deploying models.
+ JAX: A high-performance framework for cutting-edge research and fast model training on modern hardware accelerators.
+ Transformers: The core library providing a unified interface to thousands of pretrained models for various tasks.
+ Diffusers: A specialized library providing easy access to state-of-the-art models for image and audio generation.

#### Apps

+ vLLM: A versatile language model supporting a wide range of tasks, including text generation and understanding.
+ TGI: A framework for building and deploying text generation models with a focus on efficiency and scalability.
+ llama.cpp: A lightweight implementation of LLaMA models for efficient inference on various devices.

#### Inference Providers

+ Cerebras: A provider offering high-performance inference solutions for large language models.
+ Novita: A platform specializing in efficient inference for various machine learning models.
+ Nebius AI: A provider focused on scalable and efficient inference solutions for AI applications.

#### Licenses

+ apache-2.0: A permissive license allowing for wide usage and modification, commonly used in open-source projects.
+ mit: A simple and permissive license allowing for free use, modification, and distribution.
+ openrail: A license designed to promote open collaboration and sharing of AI models and datasets.
+ cc-by-nc-4.0: A Creative Commons license allowing for non-commercial use, requiring attribution to the original creator.

### Online request hf directly

```python
import requests
API_URL = "https://api-inference.huggingface.co/models/gpt2"
API_TOKEN = "*"
headers = {"Authorization": f"Bearer {API_TOKEN}"}

def query(payload):
    response = requests.post(API_URL, headers=headers, json=payload)
    return response.json()
```

### Offline use

#### Download

```python
from transformers import AutoModel, AutoTokenizer
model_name = "bert-base-uncased"
cache_dir = "model/bert-base-uncased"

model = AutoModel.from_pretrained(model_name, cache_dir = cache_dir)
tokenizer = AutoTokenizer.from_pretrained(model_name, cache_dir = cache_dir)
```

Model in local structure:

```bash
- bert-base-uncased
  ├ blobs
  ├ refs
  ┗ snapshots
    ┗ (base64)
      ├ config.json
      ├ model.safetensors
      ├ tokenizer.json
      ├ tokenizer_config.json
      ┗ vocab.txt
```

- **config.json:** Defines the model's architecture and hyperparameters, like hidden size and number of attention heads.
- **model.safetensors:** Contains the model's trained weights in a secure and efficient format for fast loading.
- **tokenizer.json:** A single file that holds all the necessary tokenizer information, including vocabulary and rules.
- **tokenizer_config.json:** Specifies tokenizer settings, like whether to lowercase text, and special token information.
- **vocab.txt:** Lists the vocabulary of the tokenizer, mapping each token to a unique ID.

#### Using

```python
from transformers import AutoModelForCausalLM, AutoTokenizer, pipeline
model_dir = r"/path"

model = AutoModelForCausalLM.from_pretrained(model_dir)
tokenizer = AutoTokenizer.from_pretrained(model_dir)

pipe = pipeline("text-generation", model=model, tokenizer=tokenizer, device="cuda")
output = pipe("Hello, I'm a language model,", max_length=50, num_return_sequences=1)
print(output[0]['generated_text'])
```

### Tuning parameters

```python
#...
output = pipe("Hello, I'm a language model,", # prompt, as the initial text, text-generation based on this
             max_length=50, # maximum length of the generated text, 50 tokens
             num_return_sequences=1, # number of generated sequences to return, 1 sequence
             truncation=True, # truncate the input text if it exceeds the model's maximum length
             temperature=0.7, # controls randomness in generation, lower values make output more deterministic. Higher values (e.g., 1.0) make it more random.
             top_k=50, # limits the sampling to the top k most probable tokens, reducing randomness and focusing on high-probability tokens. top_k=50 means only the top 50 tokens are considered.
             top_p=0.95, # nucleus sampling, considers the smallest set of tokens whose
             clean_up_tokenization_spaces=False, # whether to clean up spaces in tokenization, False means no cleanup
```
