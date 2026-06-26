---
title: "LLM Experiments"
github: https://github.com/chr0n1x/llm-experiments
tags: ["llama.cpp", "vllm", "qwen", "gguf", "local-llm", "cuda", "inference"]
date: 2026-06-26
---

Local inference experiments running Qwen 3.6 models on llama.cpp. Tweaking
parameters to avoid paying a token subscription!

<!--more-->

## Setup

AMD Ryzen 5 5600 + NVIDIA RTX 3090 (24 GB VRAM). Tried both vLLM and llama.cpp,
with the latter being the easiest to setup.

## llama.cpp

GGUF-based server with BLAS (BLIS) acceleration and full CUDA offload. Runs the
MoE model `Qwen3.6-35B-A3B` in Q6_K quantization, fitting entirely in 24 GB
VRAM at ~23.4 GB with 256k context support.

**Key config:**

- KV cache: `f16`, mlock enabled
- Batch size: 8192, ubatch: 2048 (optimized for MoE memory access patterns)
- CUDA priority: `--prio 3 --poll 100` (reduces MoE kernel launch latency)

Having some sysadmin chops helps here; I experimented with different setups to
get to this point:

- initially my AI machine was a TalosOS K8s VM node on proxmox with PCIe
  passthrough. ollama ran as a container via the nvidia node labeler operator
- ollama is _consistently_ behind in support for various vendors; if I waited,
  it would've taken upwards of 5 months for me to test out the qwen3.6 models
  when they were first quantized by the unsloth team!
- Ubuntu and debian support was kind of spotty; I frequently wanted to try new
  CUDA drivers that were simply not in the apt repos yet
- Finally settled on CachyOS (I kinda use Arch btw) for the rolling updates.

Tweaked my `ufw` settings, made sure nvidia CUDA libs and drivers were
installed, BOOM - ready for the races.

**Performance:** ~43 tok/s, no GPU OOM at full context.

## Notes

- Running with a display manager (SDDM + Hyprland) consumes ~600 MB VRAM;
  headless mode frees that for inference.
- The current temp., top-k, min-p and top-p have been perfect for smaller
  models and coding.
- Smaller models (sub 70B parameters) seem to be prone to looping due to
  "lower" attention/focus capabilities; the `1.5` presence penalty was the
  sweet spot for preventing looping, especially around tool invocations.
- Does it properly one-shot things? No. However, making your harness specify
  `/effort` level (e.g.: claude-code) is enough to make the LLM with these
  settings "explore" different ways of solving issues.
- HARNESSES and LOOPS- probably **THE MOST IMPORTANT** thing in any
  agentic-coding setup. This is ESPECIALLY so in local setups. I've found that
  my obsession with doing everything in the terminal + tmux has helped
  _immensely_ in doing this; main LLM agent is only responsible with task
  ingestion, delegation to sub-agent, and running tests against those results.
  Leveraging integration tests, playwright suites, etc keeps any-and-all LLMs
  on track, no matter how short your context or how small they are.
