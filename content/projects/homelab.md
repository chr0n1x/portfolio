---
title: "Homelab"
github: https://github.com/chr0n1x/rpi-talos
tags: ["kubernetes", "talosos", "argocd", "longhorn", "prometheus", "grafana", "arm"]
date: 2026-06-22
---

Self-hosted TalosOS Kubernetes platform running ~30 services across ARM and x86
nodes via GitOps (ArgoCD) with full observability, secrets management, storage,
and the ability to incorporate & run GPU inference.

<!--more-->

## Introduction

I started with a handful of Raspberry Pis and an old GPU card, a hoard of spare
computer parts...no grand plan - just a question about what "production-grade"
infrastructure looks like when it lives in the corner of my room. At work we
were moving towards k8s as the basis of all our workloads so I wanted my
homelab to kind of be a "safe" place for me to experiment with various
technologies and processes; an environment close to my work environment but
where I was free to not only experiment but also to mess up(!), and then to
find solutions that would make me feel comfort and safety.

That might seem kind of strange, but in my mind I don't want to interact with
technologies that make me feel stressed and anxious every day. I know that I
would perform better at any task if I felt like the environment that I'm in is
resilient, self-healing, secure...safe. Cozy, even!

K8s conceptually is a nice basis for all of this. I'm already an avid fan of
containerization, have years of experience with docker/CRI-O/podman. To me it's
this wonderful technology that let's me package up my "things" and go. With it I
can treat a collection of computers as fungible resources. The only friction to
worry about would be configuration, setup and runtime - all of which boil down
to a single question: `can this machine run a container?`

Eventually I ended up gravitating towards TalosOS Linux over vanilla Linux
because the attack surface is minimal and node configuration is a well
documented, machine manageable process. A read-only rootfs means you can't SSH
in and accidentally break something, the system either matches git or it
doesn't. Flashing the OS, wiping it clean, adding nodes - all trivial and
automatic.

At first I used `helmfile` to _kinda_ automate deployments of services that I
wanted to run. But eventually I settled on ArgoCD to self-apply and heal
everything. _Including_ argocd itself. And with that...my home started to fall
into place!

## Architecture

Two-tier deployment pipeline:

1. **helmfile** boots the platform layer — cert-manager, Longhorn storage, Traefik
   ingress, SMB CSI, ArgoCD itself, and internal registries (ChartMuseum, Distribution).
   These are seeded imperatively because some secrets aren't tracked in git (initially!).

2. **ArgoCD** eventually takes over ongoing management of _everything_ including itself.
   It creates ~30 nested Application CRDs from `k8s/helm/cluster-apps/`, each pointing to
   a Helm chart. ArgoCD continuously reconciles against git HEAD, self-healing drift and
   pruning removed resources.

GitOps flow: local changes -> `make sync` -> helmfile applies platform tier -> ArgoCD
reconciles all service Applications → cluster state matches git.

## Services

| Category | Services |
|---|---|
| Identity | Authentik (SSO), Vault (secrets), Twingate (remote access) |
| Infra | Traefik ingress, cert-manager (DNS-01 on DuckDNS), Longhorn, SMB CSI, Trivy |
| Media | Immich, Jellyfin, Pinchflat |
| Productivity | Paperless-ngx, Tandoor, BentoPDF |
| AI/ML | Ollama + Open WebUI (cluster GPU), CachyOS llama.cpp (edge proxy) |
| DevOps | Gitea, ChartMuseum, Distribution (registry proxy) |
| Monitoring | Prometheus, Grafana, Headlamp dashboard |
| Other | SearXNG, Kiwix, KEDA autoscaling, Descheduler |

## Hardware

- RPi5 control plane nodes
- Worker nodes: bare-metal RPi, ZimaBlade with NVMe, NVIDIA 3090Ti Proxmox host
  (PCIe passthrough to AI worker VM)
- Longhorn block storage on worker disks
- NUT UPS with PiSugar integration, etcd defragmentation automation

## Monitoring & Observability

Prometheus collects metrics from all cluster nodes and services via node_exporter,
cAdvisor, and service-level exporters. Grafana dashboards cover system resource
utilization, Kubernetes cluster health, namespace-level CPU/memory/network trends,
and SLO tracking. Alertmanager routes notifications to Telegram via nox-bot for
real-time incident awareness.

Prometheus queries feed into shell services that extract per-namespace resource
trends (CPU delta, memory growth, network bandwidth changes) and report the top
three anomalies on each poll cycle — enabling proactive capacity planning without
expensive commercial monitoring tools.

## Infrastructure Details

- **Storage:** Longhorn for block storage with SMB CSI for NFS/SMB mount integration;
  etcd weekly snapshots backed up and managed via cron-driven defragmentation.
- **Networking:** Traefik ingress controller with cert-manager DNS-01 challenges on
  DuckDNS, split between internal (`rannet.duckdns.org`) and edge-accessible
  (`rannet-edge.duckdns.org`) domains.
- **Secrets management:** Vault with Vault Secrets Operator for Kubernetes-native
  secret injection; Authentik for identity and SSO across services.
- **Power resilience:** NUT UPS monitoring with custom systemd integration — on-battery
  scripts trigger graceful service shutdowns and notifications via Telegram.

## Architecture Decisions

- **Two-tier GitOps (helmfile -> ArgoCD) .** helmfile to start and seed the cluster, but
  ArgoCD takes over ongoing reconciliation and self-healing for all service deployments.
  Pure GitOps top to bottom, including references to secrets (VSO).

- **TalosOS Linux for all nodes.** Chosen over vanilla Ubuntu/K3s because the
  attack surface is minimal (read-only rootfs, no container runtime exposed), node
  configuration is declarative and versioned, and upgrades are atomic across all nodes.
  The tradeoff is reduced interactivity — debugging requires SSH into a read-only system
  and using `talosctl` instead of familiar kubectl/debug containers. But to me this is and
  "a blessing in disguise" - I don't have to care about what kind of machine I want in the
  cluster, I just need to answer one question - `can this run TalosOS?`. Upgrading the
  entire fleet is then trivial too!

- **Hardware tiering & segregation via workload & labels.** Control plane on RPi5s + nvme
  (adequate for etcd and API server), media/AI workloads on the RTX 3090Ti host,
  bare-metal RPi for lightweight services. This avoids over-provisioning a single node
  type and lets each workload use hardware it was designed for. K8s lets me do this
  with taints/labels. It's all GitOps. Code.

## Learnings - Working with an LLM agent on a production cluster

When AI coding first came about I was relatively _certain_ that infra and
ops would never be replaced by agents.

Per usual, I was wrong. At least to a degree.

Here's my anecdotal experience though.

**Guardrails written in skills/commands are really damn flaky**

Trying to make the LLM stop at every change for approval is **frail**.
As "the human in the middle" I'm frequently `/compact`ing, finding ways to
decrease tokens that flood context, etc to preserve the LLMs ability to stay
in its "smart zone". The more that you flood context with various skills,
tangential tasks...the higher the chance of the LLM to spew out tokens that
steer it _away_ from "desirable" behaviour. Which makes sense, since with
each generated & errant token, every subsequent prediction is affected.

At least, that's how I conceptually think of it as I stare at all of this
text filling my harness TUI.

**TESTS. SCRIPTS THAT `exit <code>` ARE EVERYTHING**

Admittedly, I've only had good luck with the `qwen3.x` series of models.
I say this because they're seemingly VERY good at adhering to instructions
that indicate boolean `go` or `no-go` signals based on the results of what
they output. Specifically - if you tell them `after every change, always run
"make ci" to validate your changes` they will adhere.

This behavior is definitely a result of the class/size of the model, along
with the context size that you're able to leverage and the harness that you
use. I overall have this sneaking suspicion that when you tell the LLM to
run a suite of tests and evaluate the output (e.g.: linter results, test
results, etc) - the logs themselves have a residual effect on the LLM. I say
this because I imagine that, as it reads many many lines of output it forces
the entire pipeline (harness, context, tools, LLM) to hold more data that's
"testing results and reaction behavior" in context itself. So as a result,
I believe and imagine that verbose test result logs _steer_ the LLM _back
towards_ running tests.

**A strange shift in human work and attention**

It's weird writing/creating automations in this day and age. It's almost
like we're no longer playing on a boardgame, writing code to get to the
finish line or "win box" of the game. We're now instead responsible for
clearly defining the rules that _MAKE UP_ the board game itself. And now
the LLM "plays through the board" everytime you think you've "codified" the
rules, be it with skills, AGENTS.md, etc.
