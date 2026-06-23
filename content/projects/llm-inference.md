---
title: "LLM Inference Benchmarks"
github: llm-experiments
tags: ["llama.cpp", "vLLM", "Qwen", "GPU-inference", "speculative-decoding", "CUDA"]
date: 2026-06-23
---

Local LLM inference testing and optimization comparing llama.cpp and vLLM for Qwen 3.6 models on a single-GPU setup — focusing on throughput, latency, and memory efficiency tradeoffs between quantized MoE models and speculative decoding. Hardware: AMD Ryzen 5 5600, NVIDIA RTX 3090 (24GB VRAM).

<!--more-->

## Architecture

Two inference backends running on the same hardware, each optimized for different
workloads:

- **llama.cpp** — quantized mixture-of-experts model serving approximately 62 tokens/s
  with extended context windows. Built from source with CMake, using GGUF quantization
  for memory-efficient loading. Optimized for batched offline inference and prompt
  processing.

- **vLLM** — integer-4 compressed weights with speculative decoding and flash attention
  optimization. Served as an OpenAI-compatible API on port 8000, enabling integration
  with existing tooling (nox-bot, custom clients) without code changes. Systemd units
  for persistent operation.

## Key findings

- Speculative decoding significantly improves throughput for autoregressive workloads
  by using a smaller draft model to propose tokens that the larger model verifies in
  parallel.
- Quantized MoE models trade some output quality for substantial VRAM savings, enabling
  larger context windows on consumer hardware.
- llama.cpp excels at offline batch processing; vLLM's PagedAttention and continuous
  batching make it better for interactive/API workloads.

Both backends are production-ready and serve as the inference layer for homelab
automation (nox-bot) and local experimentation.
