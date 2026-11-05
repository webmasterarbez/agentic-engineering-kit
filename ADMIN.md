# ADMIN.md — Agentic Engineering Kit operations guide

Everything an operator needs to install, wire, back up, re-validate, and extend this kit. Written to be repeatable on any Linux/macOS machine. This is the admin-side twin of `README.md` (user doc) and `LLM.md` (machine doc).

---

## 1. Inventory — what the kit is made of

### 1.1 Files

| File | Role | Loads when |
|---|---|---|
| `skills/karpathy-agentic-engineering/SKILL.md` | The skill body (method + rules + workflow) | Invoked by name/trigger in a skills-capable agent |
| `skills/karpathy-agentic-engineering/PASTE-PROMPT.md` | Same method as a paste-prompt | Manually pasted into any agent |
| `templates/AGENTS-CORE.md` | Repo context-file template (4 rules, trimmed) | Copied into a project as `AGENTS.md`/`CLAUDE.md` |
| `LLM.md` | Self-contained instruction doc for LLM consumption | Fetched/fed manually |
| `install.sh` | Installer/uninstaller for all skill locations | Run by operator |

### 1.2 Skill install locations (per tool)

| Tool | Global location | Project location | Verified against |
|---|---|---|---|
| ZCode | `~/.agents/skills/` (also `~/.zcode/skills/`) | `.agents/skills/` | Local install, loaded in session skill list |
| Claude Code | `~/.claude/skills/` | `.claude/skills/` | Local `~/.claude/skills` in active use |
| Cursor | `~/.cursor/skills/` | `.cursor/skills/` or `.agents/skills/` | cursor.com/docs/skills |
| Antigravity (`agy` CLI + IDE) | `~/.gemini/skills/`, `~/.gemini/antigravity/skills/`, `~/.gemini/antigravity-cli/skills/` | `.agents/skills/` | antigravity.google/docs/skills |
| Codex / Opencode / other standard readers | `~/.agents/skills/` | `.agents/skills/` | Agent Skills standard |

`install.sh` copies (not symlinks — some tools don't follow symlinks) the skill into every location that exists or that you flag. The repo is the source of truth; re-run `./install.sh` after any update to re-sync all locations.

### 1.3 MCP servers — required vs optional

**Required: none.** The kit is intentionally MCP-free so it adds zero always-on context-window tokens. Every MCP server an agent connects injects its full tool schemas into every session, so each one must earn its keep.

**Optional, used only by the validation procedure (§5):**

| Server | Purpose | Where configured (this machine) |
|---|---|---|
| `notebooklm` (local CLI, not MCP) | Grounded Q&A against the 37-source Karpathy research notebook | `~/.local/bin/notebooklm` (notebooklm-py) |
| `codegraph` | Symbol/call-path navigation in indexed repos (saves context vs grep-read cycles) | `~/.zcode/cli/config.json` → `mcp.servers`; also `agy mcp list` |
| `searx` (CLI, not MCP) | Rate-limit-free local web search for evidence gathering | `~/.local/bin/searx` |

To add an MCP to a tool (examples):
- **agy**: `agy mcp add <name> -- <command> [args...]`, `agy mcp list`, `agy mcp enable <name>`
- **Claude Code**: project `.mcp.json` (`{"mcpServers": {...}}`) or `claude mcp add`
- **Cursor**: `~/.cursor/mcp.json` (same schema)
- **ZCode**: `~/.zcode/cli/config.json` → `mcp.servers` object; project-level `.mcp.json` in the workspace

**Scope rule (hard-won):** anything big (like a reverse-engineering toolchain) belongs *project-scoped* (that project's `.mcp.json`), never global. One oversized global server cost ~15–20k tokens in every session before it was scoped down.

### 1.4 Hooks (enforcement beyond markdown)

Markdown rules guide; hooks enforce. The method's "correct twice → encode" principle and the leash map to native hook systems:

**Claude Code** (`~/.claude/settings.json` or project `.claude/settings.json`):

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash(git push --force*)|Bash(git reset --hard*)|Bash(rm -rf*)",
        "hooks": [{ "type": "command", "command": "echo 'BLOCKED: destructive git/fs op needs explicit human approval (leash rule)' && exit 2" }]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{ "type": "command", "command": "command -v lint-staged >/dev/null && lint-staged || true" }]
      }
    ]
  }
}
```

`exit 2` on PreToolUse blocks the call; PostToolUse runs verification after every edit (verify-first, mechanized).

**ZCode / standard readers**: no hook system of its own — put guardrails in `~/.zcode/AGENTS.md` (loaded every session) and lean on the skill.

**agy / Antigravity**: `--mode plan|accept-edits|auto` sets the session leash level; `--sandbox` for terminal restrictions; MCP permission prompts cover the rest.

**Correct-twice ledger**: keep a running `LEARNINGS.md` per project; when the same correction appears twice, promote it into `AGENTS.md`/`CLAUDE.md` or a hook, and delete the ledger line. Context files must be *consolidated*, never accumulated — sprawl is the #1 community failure mode.

---

## 2. Install / update / uninstall

```bash
./install.sh                 # install everywhere detected
./install.sh --all           # also create missing locations
./install.sh --uninstall     # remove from all locations
./install.sh --sync          # re-copy after repo updates (same as plain install)
```

Idempotent; copies are overwritten from the repo each run. After pulling upstream updates: `git pull && ./install.sh`.

## 3. Backup & restore

The kit is one git repo — that *is* the backup. To snapshot live installs before an experimental change:

```bash
tar czf ~/backups/aek-install-$(date +%F).tgz \
  ~/.agents/skills/karpathy-agentic-engineering \
  ~/.claude/skills/karpathy-agentic-engineering \
  ~/.cursor/skills/karpathy-agentic-engineering \
  ~/.gemini/skills/karpathy-agentic-engineering 2>/dev/null
```

Restore = untar over the locations, or simply `./install.sh` from a clean clone.

## 4. Porting the rules into a project (per-repo setup)

Automated: `./setup-repo.sh <repo-path> [--hooks] [--skill] [--force]`

- Auto-names the context file (`.claude/` present → `CLAUDE.md`, else `AGENTS.md`; `--name` overrides).
- Pre-fills from the repo itself: package.json scripts / Makefile targets / cargo / go / pytest / docker compose → Commands section; generated dirs, `.env*`, `*.db`, `prisma/migrations` → Never-touch list; detected stack → header.
- Injects the verbatim 4 rules + operating constraints; lands under ~35 lines; two `[fill me]` sections remain for the human.
- `--hooks` installs the §1.4 guardrail into `<repo>/.claude/settings.json` **merge-safe** (existing hooks and keys untouched), marked `agentic-engineering-kit leash`, idempotent, removable via `--remove-hooks` without touching anything else.
- `--skill` embeds the skill into `<repo>/.agents/skills/` so clones carry the method.
- An existing context file is never overwritten without `--force`; you get a line count instead (>60 = trim candidate).

Manual fallback: copy `templates/AGENTS-CORE.md` to the repo root as `AGENTS.md` (or `CLAUDE.md`; Antigravity reads either, plus `GEMINI.md`), fill the four sections, keep under ~60 lines, detail goes to `.agents/rules/*.md` or docs/.

## 5. Weekly re-validation procedure (the repeatable part)

Goal: detect drift between the skill, the community, and Karpathy's corpus; update and push. Runs every Monday at 09:00 (automated on the author's machine via a scheduled task; here is the manual procedure any machine can run). Most weeks nothing changes — a no-change week reports the check and creates no commit.

### 5.1 Community evidence (last30days skill)

```bash
# prerequisites: python3.12+, the last30days skill installed
SKILL_DIR=~/.agents/skills/last30days
/usr/bin/python3.14 "$SKILL_DIR/scripts/last30days.py" \
  "Karpathy agentic engineering workflow" \
  --emit=compact --save-suffix=v3 \
  --x-handle=karpathy --github-user=karpathy \
  --subreddits=ChatGPTCoding,ClaudeCode,ExperiencedDevs,AgentsOfAI,singularity
```

Write the query plan to a temp file and pass `--plan` (see the last30days runbook) when running interactively through an agent. Read the ranked clusters: note any finding that supports, contradicts, or extends the six pillars (spec-first, autonomy dial, verify-first, delivery contract, correct-twice, supervisor duty).

### 5.2 Corpus cross-check (notebooklm CLI)

```bash
notebooklm use a6b9e81a        # Karpathy Claude Code Research Notebook
notebooklm ask "For each of these community findings from the last 30 days: [paste findings] — does Karpathy's work in this notebook support it, contradict it, or stay silent? Quote exact words."
```

### 5.3 Apply + publish

1. Edit `skills/karpathy-agentic-engineering/SKILL.md` and `PASTE-PROMPT.md` — add supported extensions, mark community-vs-Karpathy provenance in the footer (update the validation date and counts).
2. Regenerate `docs/` if the method changed materially.
3. `./install.sh` to re-sync all live locations.
4. `git add -A && git commit -m "re-validate YYYY-MM-DD" && git push`

### 5.4 When validation says the skill is wrong

Contradiction by the corpus wins: fix the skill to match what Karpathy actually said. Community consensus without corpus support may be added but must be labeled "community-converged addition" in the footer (the risk-tier clause is the precedent).

## 6. Extending the kit

- **New agent tool**: if it reads `~/.agents/skills/` or `.agents/skills/`, nothing to do. Otherwise add its location to `install.sh` `LOCATIONS` and to §1.2.
- **New language/stack guidance**: put it in `templates/AGENTS-CORE.md` conventions, not in the skill — the skill stays stack-agnostic.
- **Translations of the method**: keep one canonical `SKILL.md`; fork only the paste-prompt.

## 7. Troubleshooting

| Symptom | Fix |
|---|---|
| Skill doesn't appear in a tool | Check the exact directory from §1.2; most tools need a session restart to rescan |
| Tool loads the skill but never triggers it | The description field is the trigger surface — keep trigger phrases ("karp-mode", "agentic engineering") in it |
| Two copies diverge | Re-run `./install.sh`; never edit live copies, edit the repo |
| Context bloat returns | Audit MCP list per tool (§1.3); the kit itself is always zero-cost |
| Hook fires too eagerly | Widen/narrow the `matcher` regex; hooks are guardrails, not roadblocks |
