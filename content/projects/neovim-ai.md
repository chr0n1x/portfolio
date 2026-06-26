---
title: "Neovim + AI"
github: https://github.com/chr0n1x/neovim-configs
tags: ["neovim", "lua", "claude-code", "minuet-ai", "agent-editing", "local-llm"]
date: 2026-06-26
---

My Neovim setup centered around Claude Code for agent-driven development.
Treats local LLMs hosted via OpenAI-compatible APIs as first-class citizens!

<!--more-->

![Neovim with Claude Code](https://github.com/chr0n1x/portfolio/blob/main/static/images/projects/neovim-ai/neovim-claude.png?raw=true)

## Architecture

Typical neovim plugin setup.

```
init.lua          -> flag-consts, consts, base-settings, key-bindings, lazy.nvim
lua/plugins/      -> modular plugin configs loaded by lazy.nvim
  ai-claude.lua   -> Claude Code via 99 + claudecode.nvim
  ai-minuet.lua   -> OpenAI-compatible FIM completion via minuet-ai.nvim
```

claude-code sits on TOP of my neovim buffers and I can quickly navigate to/from it.

In this world of AI - there's no point in fighting the agents. Next best
thing - integrate them!

I settled on claude code for the following reasons:

- enterprise - my employer is 100% in with Anthropic (or so it seems)
- compiled bin - I can install claude-code on ANY machine I own, regardless
  of architecture
- claude-code supports open-api backends! self-hosters REJOICE!

## AI Integration

### Claude Code — two interfaces, one workflow one LLM

I run Claude Code through **both** [ThePrimeagen/99](https://github.com/ThePrimeagen/99) and [claudecode.nvim](https://github.com/coder/claudecode.nvim), each serving a
different interaction pattern:

**99** handles agent-mode tasks. `<leader>C` opens a floating terminal prompt that
dynamically builds prompts scoped to specific segments/lines that my cursor is on.
That prompt is then fed to whatever LLM backend I'm using. Buffer refreshes
happen immediately even while I'm typing in some other section of the file.
The goal of using this is to give me a more hands-on approach to agentic
coding; the LLM may be faster than spewing out code, but if the code that I'm
dealing with requires _very_ strict navigation via specific libs or styles I
still would like to "have my hands on the wheel" to some degree.

In most cases though, I just use **claudecode.nvim** (backed by snacks.nvim).

- `<leader>c` — summon claude-code in a floating neovim terminal above my code.
- `<leader>ca` — add current buffer to context (either the entire file or specific lines)

When coupled with treesitter and telescope, this overall UX gives me the
ability to fly through files the same way that I always have! Only difference
now is that I leave all of the typing and cross lib/file implementation to the
LLM. Most of my workflows these days are:

1. open up neovim, find the file that I think I want to work on (`<leader>p`,
   so `<spacebar>p` -> fuzzy search)
2. if the changes are smaller and I'm familiar with the
   codebase/language/framework - I can usually type faster than the LLM
   inference time
3. if the change would span multiple files, or if I'm unsure - I put claude ->
   sub-agent -> go into plan mode and have it come up with a solution
4. while claude is doing that (with whatever LLM backend, haiku, opus, even my
   qwen3.6 instance) - I'll open up the tests and try to figure out what the
   tests should concretely cover, what regression tests or new use-cases _must_
   function
5. go back to claude, have it write the tests based on how I think things
   should work, have it come up with other test cases too
6. put claude into a loop.

For the last bit - I run everything in `tmux` and have a command called
`/watch-tests` that makes claude watch any tests that it spins up for the repo
by investigating tmux panes. So while changes are happening, it knows what's a
valid "end-state" because I then have tests to help steer it the right way.

_I have some secret sauce in various personal and proprietary repos that helps
claude "remember" what tests to run per repo, some other tools to save on token
costs...all of which is a bit of its own systems engineering ;)_

And all of this is happening while I'm in my editor, still jumping around!

### Local LLM — OpenAI-compatible FIM autocomplete

Minuet-AI connects to my local inference server
([llm-experiments](https://github.com/chr0n1x/llm-experiments.md) or ollama)
via its OpenAI-compatible API for Fill-In-the-Middle completion. This is
effectively in-line auto-completion via LLMs _on top of_ LSP suggestions! The
idea is to have _something_ like copilot or cursor super-tab functionality.
The model and URL set through environment variables — and **can be a different
model, powered by a completely different provider!**

### Configuration

Both Claude Code and the local FIM backend are driven entirely by environment
variables. The environment variables are read at config load time, so switching
between local and cloud backends is a matter of setting the right env vars
before launching Neovim.

Coming from a SRE background, I _prefer_ that all configurations are shell
env-vars for configuration injection. And because my work environment has a
claude subscription whereas my personal setup is powered by a local/private
LLM, I _need_ this setup to be able to be configured on the fly.

## Final Thoughts

I've been using vim and neovim for over 14 years now. The first time I saw `vi`
in use was in college, by my professor in a graduate course. I was absolutely
_enthralled and dumbstruck_ with how magical he made editing code look. A few
keystrokes in less than a second and he finished editing blocks of code.

Over the years I've built up my vim-motion muscle memory. While I don't think I
can min-max [vim golf](https://www.vimgolf.com/) the same way the terminal
wizards do, nor would I ever achieve the grace that my professor displayed
all those years ago, I do my darndest to achieve something smooth, something
that's a joy for me to "drive". And over time it's proven to make me faster
(_trust me bro_). Countless times I've sat in pair-programming or brainstorming
sessions and while folks are futzing around with cursors or awkwardly trying
to navigate between their editor and terminal, I've already opened all files
required, a terminal, and jumping between them.

AI is here to stay. And I have to say - it's been a joy integrating it into what
already feels like an amazing setup. A bit hectic because of its speed. But a
joy nonetheless.
