---
title: "LLM-backed Automations"
tags: ["go", "agent-orchestration", "llm-integration", "cron-scheduling", "telegram-api"]
date: 2026-06-12
---

Config-driven orchestration engine scheduling cron-based services across HTTP,
shell, and RSS sources — feeding results through LLMs with custom system prompts
and delivering formatted reports via Telegram. Built for production reliability:
PID locking, graceful shutdown, retry logic, and comprehensive test coverage.

<!--more-->

Architecture:

- Service scheduler built on cron with per-service mutex locking to prevent
  concurrent runs. Supports HTTP, text, shell, aggregate (fan-out/fan-in),
  fetcher, and processor service types — each with configurable polling intervals,
  clean-up semantics, and conditional execution paths.

- Aggregate services implement a multi-phase pipeline: parent data fetch → JSON
  path extraction → dynamic child template instantiation → fan-out LLM calls per
  child → fan-in aggregation call. Child templates are parameterized from parent
  data using Go text/template syntax.

- Message processing pipeline ingests Telegram messages into SQLite/PostgreSQL,
  walks reply-to chains up to 20 levels deep (combining DB lookups with Telegram
  API fetches), builds full conversation context, and processes batches through
  an LLM with concurrency control and message claiming for deduplication.

- REST API exposes service management (CRUD on services), one-off triggers,
  message ingestion endpoints, and user authorization — enabling external systems
  to interact with the orchestration engine.

- Production configuration runs self-updating from git, Prometheus-based cluster
  health monitoring (CPU/memory/network trends per Kubernetes namespace), news
  aggregation via RSS with XPath extraction and urgency filtering, and system
  telemetry reporting (GPU, CPU, memory, disk).

Key design decisions:

- **Transit layer decouples LLM calls from data fetching.** Service results and prompts
  are serialized to JSON before reaching the LLM, enabling offline debugging, prompt
  inspection, and replays without re-fetching source data. Tradeoff: an extra serialization
  step adds complexity, but it means broken upstreams don't corrupt LLM conversations —
  you can replay from disk with clean input.

- **Aggregate services use fan-out/fan-in instead of sequential processing.** Each child
  service runs independently (HTTP fetch + XPath extraction or shell execution), then its
  output goes through a separate LLM call. Results are collected and fed into a single
  aggregate LLM call for synthesis. This is more expensive in API calls than one big prompt,
  but it produces higher-quality outputs — each child gets focused context rather than
  drowning in noise from unrelated sources.

- **XPath extraction with silent-fail semantics.** When an XPath query returns no results,
  that source is omitted entirely from the LLM prompt rather than passing empty or garbage
  data. This prevents the LLM from hallucinating on missing information, at the cost of
  potentially losing context if a source goes down silently.

- **SQLite as primary store with PostgreSQL as drop-in alternative.** SQLite was chosen for
  the default because it requires zero infrastructure — one file, no running process. When
  multi-user access or higher concurrency is needed, PostgreSQL works as a transparent swap.
  The tradeoff is that SQLite's WAL mode handles concurrent reads well but writes can become
  a bottleneck under heavy load; knowing when to switch is part of operational judgment.

- **PID locking prevents duplicate server instances.** A file-based lock in /tmp ensures only
  one server runs at a time, avoiding duplicate cron triggers and conflicting message sends.
  The lock is process-aware (checks PID ownership on release) so stale locks from crashed
  processes don't block recovery.

- **Config-driven service definitions over hardcoded automation.** Services are defined in
  YAML with templating support (`{{.key}}` substitution, `env:` variable resolution), making
  new automations declarative rather than code changes. The tradeoff is YAML complexity and
  the need for careful template discipline to avoid subtle runtime errors.

Built iteratively through extensive LLM-assisted development cycles with a focus
on reliability: graceful shutdown coordination, PID locking, message deduplication,
retry logic for Telegram API rate limits, and comprehensive test coverage.
