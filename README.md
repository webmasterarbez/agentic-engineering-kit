# Agentic Engineering Kit

Vibe code the Karpathy way. A validated, agent-agnostic operating method — "claim the leverage of AI coding agents without compromising software quality" — packaged as a skill for every major agent, a paste-prompt for everything else, and a repo context-file template.

Built from Andrej Karpathy's 2026 corpus (Sequoia AI Ascent talk *"From Vibe Coding to Agentic Engineering"*, `autoresearch`, `nanochat`, MenuGen, the 4-rules `CLAUDE.md`), then validated two ways on 2026-11-05:

- **Community**: 30-day evidence across Reddit / X / Hacker News / dev.to (58 items) — spec-first, verify-first, autonomy levels, and diff-review all held up; the community added the *correct-twice → encode* pattern and deskilling countermeasures.
- **Corpus**: every finding cross-checked against a 37-source research notebook — 5/6 supported with exact quotes, 1 partial (formal risk tiers are a community addition, not Karpathy's words).

## What's in the kit

| Path | What it is |
|---|---|
| `skills/karpathy-agentic-engineering/SKILL.md` | The skill — drops into any Agent-Skills-compatible tool |
| `skills/karpathy-agentic-engineering/PASTE-PROMPT.md` | Universal paste-prompt for agents without skills support |
| `templates/AGENTS-CORE.md` | Repo context-file template (the 4 rules, trimmed) — drop into any project |
| `setup-repo.sh` | Per-repo setup: generates an optimized `CLAUDE.md`/`AGENTS.md` (auto-detected commands, never-touch list, verbatim rules) + installs the Claude Code guardrail hook, merge-safe and removable |
| `LLM.md` | Full instruction doc, self-contained, for feeding to any LLM directly |
| `ADMIN.md` | Admin guide: install, MCPs, hooks, backup, monthly re-validation procedure |
| `docs/index.html` + `docs/agentic-engineering-kit.pdf` | The same docs as HTML and PDF |
| `install.sh` | One-command install into every supported tool |

## Quick start

```bash
git clone https://github.com/webmasterarbez/agentic-engineering-kit.git
cd agentic-engineering-kit
./install.sh          # installs the skill into every detected tool
```

Then in any supported agent, say **"karp-mode"**, **"agentic engineering mode"**, or invoke the skill by name.

Per-repo setup (do this once per project):

```bash
./setup-repo.sh ~/projects/my-app --hooks   # optimized CLAUDE.md/AGENTS.md + guardrail hook
#                                            (auto-detects name: .claude/ present → CLAUDE.md, else AGENTS.md)
# flags: --skill (embed the skill in the repo) · --force (replace existing file) · --remove-hooks
```

The generated file lands under ~35 lines with the repo's real commands and never-touch list pre-filled; you fill two `[fill me]` sections and every tool reads it. If a context file already exists it is never overwritten — you get a line-count audit instead (over 60 lines = trim candidate).

No skills support? Open `skills/karpathy-agentic-engineering/PASTE-PROMPT.md` and paste it into any agent before your task. That file *is* the whole method — fitting, since Karpathy's own framing is "what is the piece of text to copy-paste to your agent? That's the programming paradigm now."

## The method in 60 seconds

1. **Context**: repo has a short `AGENTS.md`/`CLAUDE.md` (architecture, commands, conventions, never-touch list). Trim ruthlessly — the context window is the program.
2. **Spec**: co-author `SPEC.md` (detailed enough to be the docs) before any implementation. Human signs off.
3. **Autonomy dial**: pick per task — *on-the-leash* (architecture/security/judgment), *autopilot* (scoped goals + checkpoints), *autonomous* (isolated env + explicit verifier). Default one lower when unsure.
4. **Verify-first**: build the failing test / eval / metric before the implementation. Loops must be resettable, efficient, rewardable.
5. **Deliver as a contract**: what changed & why + proof it works (test output, logs) + what to review + what could break.
6. **The loop improves, not the agent**: corrected the same thing twice? Encode it — rule, hook, or test.

Golden rule: **outsource the thinking (syntax, API recall), never the understanding (invariants, identity, security, architecture).**

## Usage per tool

### Claude Code
`install.sh` copies the skill to `~/.claude/skills/karpathy-agentic-engineering/`. Start any session and say `karp-mode` or `/karpathy-agentic-engineering`. Project-level alternative: copy the folder to `.claude/skills/` in the repo. Pair it with `templates/AGENTS-CORE.md` as your project `CLAUDE.md`. Hooks (see `ADMIN.md`) can enforce the leash automatically.

### Google Antigravity (`agy` CLI + Antigravity IDE)
`install.sh` copies the skill to `~/.gemini/skills/`, `~/.gemini/antigravity/skills/`, and `~/.gemini/antigravity-cli/skills/` (whichever exist). In the CLI: `agy -i "karp-mode"` or invoke the skill by name in a session; skills and slash-commands expand in both CLI and IDE. Project-level: put it in `.agents/skills/` at the repo root. Rules files the IDE loads: `AGENTS.md`, `GEMINI.md`, or `.agents/rules/*.md` — use `templates/AGENTS-CORE.md` as `AGENTS.md`. MCPs: `agy mcp add|list|enable`.

### Cursor
`install.sh` copies the skill to `~/.cursor/skills/karpathy-agentic-engineering/` (user-level) — Cursor also reads `.cursor/skills/` or `.agents/skills/` in the project. Type `/karpathy-agentic-engineering` in Agent chat, or just say "karp-mode" — Cursor discovers skills at startup and loads them on trigger. Pair with `templates/AGENTS-CORE.md` as your project `AGENTS.md`.

### ZCode (and anything reading the Agent Skills standard)
Already covered by the standard location: `~/.agents/skills/karpathy-agentic-engineering/`. New session + "karp-mode" triggers it. ZCode-specific guardrails can live in `~/.zcode/AGENTS.md`.

### Any other agent (Codex, Gemini CLI, Opencode, Aider, ChatGPT, …)
Use `PASTE-PROMPT.md`. Most tools that read `~/.agents/skills/` or project `.agents/skills/` will pick the skill up automatically too — that's the point of the standard.

## What it does NOT need

- **No MCP servers.** The kit is pure markdown — zero always-on context-window cost. (Optional research-validation MCPs are documented in `ADMIN.md`.)
- **No API keys.**
- **No daemon, no build step.**

## Maintenance

The skill carries its provenance in its footer. A weekly re-validation (every Monday 09:00 on the author's machine: community evidence via `last30days`, corpus check via `notebooklm` CLI, update + push only when something changed) is documented step-by-step in `ADMIN.md` so it stays repeatable on any machine. The full evidence trail lives in `research/`.

## License

MIT — see `LICENSE`.
