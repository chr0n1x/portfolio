---
title: "任"
---

## Intro

HI! Welcome to my blog/portfolio...thing.

New York-based SRE and infrastructure engineer. Previously fullstack and
ecommerce, now focused on Linux systems, Kubernetes, and building tooling that
makes complex systems manageable.

## Professional Experience

- **Ecommerce:** inventory systems (SKU management and tracking), created APIs
  that helped shape user UX to increase sales (e.g.: quick-add items w/ `only 6
  left in stock` to cart right before checkout), financial reports, UX
  adjustments to help sales productivity.
- **SRE:** CI/CD pipelines for application deployments (emphasis on sub-10
  minute recovery times for outages). Testing libraries and harnesses (this is
  BEFORE LLMs) Security audits (routed requests for PEN testers). Scaled
  deployments for applications (e.g.: goin from deploy once a month to multiple
  times a DAY), eventually scaling and standardizing practices across multiple
  teams and BUs.
- **Ops:** Infrastructure A/B automations for 0-downtime cluster cutovers. AWS
  (cloudformation), Chef, Ansible, terraform; now ArgoCD and K8s. Implemented
  OTeL monitoring and alerting (Prometheus, Grafana, Alertmanager). Outage
  triage, direction, RCA composition/writeups.
- **SWE:** full-stack - front-end is admittedly my weakpoint (latest experience
  in TS React, Spotify backstage). Have written various applications to
  **sensibly** wrap all systems that I've worked on above, in a myriad of flavors
  (MVC monoliths, to microservice-based workflow systems).

Current focus: shared LLM memory/context architectures and GitOps pipelines for
AI workloads.

_The above is a _very_ abbreviated splurge of my experience using and
developing proprietary software! For more details, you'll have to speak to me
face-to-face ;)_

## Personal/FOSS Work

**Homelab & Infrastructure:** I run a TalosOS Linux Kubernetes cluster on
Raspberry Pi 5s, managing ~30 application services via ArgoCD GitOps. See
[my project entry on my homelab for more details!](/projects/homelab/).

**LLM Ops:** Running local inference experiments with Qwen 3.6 models
(llama.cpp vs vLLM), speculative decoding, and quantized MoE models on consumer
hardware. This entire site was coded with
[`qwen3.6-35b-a3b`](https://huggingface.co/unsloth/Qwen3.6-35B-A3B) :D

**Automation Tooling:** Built `nox-bot` — a Go CLI for Telegram messaging,
LLM-powered service reports, and homelab automation. Also maintain
`pinchscrape` (OPML feed scraper) and various utility scripts
([luks-utils](https://github.com/kran/luks-utils)).

**Infrastructure as Code:** Documented my Talos Linux + K8s homelab setup for
others to replicate. Contributing to the Talos ecosystem through configuration
examples and operational runbooks.

**Open Source & Community:** Arctic Code Vault Contributor - code archived at
Svalbard. Pull Shark x3 (100+ PRs opened). Active contributor across Adobe,
Behance, and Adobe Platform orgs on GitHub. I maintain helm-charts for any
services that I self-host in my homelab!

## Skills

**Infrastructure:** Linux (RHEL, Debian, Alpine, Arch/CachyOS), Kubernetes,
Talos Linux, Docker, Ansible, Terraform, Vault, Traefik, Longhorn, CNPG,
NUT UPS, AWS

**CI/CD & GitOps:** GitHub Actions, Flux CD, Argo CD, Helm, Kustomize, Gitea

**AI/ML Ops:** llama.cpp, OpenAI-compatible APIs, speculative decoding,
quantized MoE models, LLM-assisted development workflows

**Languages:** Go, Ruby, Bash, Python, TypeScript
