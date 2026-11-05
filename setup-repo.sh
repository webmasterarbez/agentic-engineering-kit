#!/usr/bin/env bash
# setup-repo.sh — per-repo setup for the Agentic Engineering Kit.
# Creates an optimized context file (CLAUDE.md or AGENTS.md) with detected
# commands + never-touch list + verbatim rules, and optionally installs the
# Claude Code guardrail hook (merge-safe, marked, removable).
#
# Usage: ./setup-repo.sh <repo-path> [--name FILENAME] [--hooks] [--skill] [--force]
#        ./setup-repo.sh <repo-path> --remove-hooks
set -euo pipefail

REPO_DIR=""
CTX_NAME="" FORCE=0 HOOKS=0 REMOVE_HOOKS=0 SKILL=0
while [ $# -gt 0 ]; do
  case "$1" in
    --name) CTX_NAME="$2"; shift 2 ;;
    --hooks) HOOKS=1; shift ;;
    --remove-hooks) REMOVE_HOOKS=1; shift ;;
    --skill) SKILL=1; shift ;;
    --force) FORCE=1; shift ;;
    *) REPO_DIR="$1"; shift ;;
  esac
done
[ -n "$REPO_DIR" ] && [ -d "$REPO_DIR" ] || { echo "usage: ./setup-repo.sh <repo-path> [--name FILENAME] [--hooks] [--skill] [--force] | --remove-hooks"; exit 1; }
REPO_DIR="$(cd "$REPO_DIR" && pwd)"
KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---- 1. Context file ------------------------------------------------------
if [ "$REMOVE_HOOKS" = 0 ]; then
  if [ -z "$CTX_NAME" ]; then
    if [ -d "$REPO_DIR/.claude" ]; then CTX_NAME="CLAUDE.md"; else CTX_NAME="AGENTS.md"; fi
  fi
  CTX="$REPO_DIR/$CTX_NAME"

  if [ -f "$CTX" ] && [ "$FORCE" = 0 ]; then
    LINES=$(wc -l < "$CTX")
    echo "existing $CTX_NAME found ($LINES lines) — not overwriting (use --force to replace, or trim by hand: consolidate, never accumulate)"
    [ "$LINES" -gt 60 ] && echo "  note: over 60 lines — candidate for a trim pass"
  else
    python3 - "$REPO_DIR" "$CTX" "$CTX_NAME" <<'PYEOF'
import glob as g
import json, os, sys

repo, ctx_path, ctx_name = sys.argv[1], sys.argv[2], sys.argv[3]

def first(*paths):
    for p in paths:
        f = os.path.join(repo, p)
        if os.path.exists(f):
            return f
    return None

cmds, stack = [], ""
pkg = first("package.json")
if pkg:
    try:
        doc = json.load(open(pkg))
        s = doc.get("scripts", {})
        label_map = [("Setup", "install"), ("Run", "dev"), ("Start", "start"), ("Test", "test"),
                     ("Test (e2e)", "e2e"), ("Build", "build"), ("Lint", "lint"), ("Typecheck", "typecheck")]
        for label, key in label_map:
            if key in s:
                cmds.append((label, f"npm run {key}"))
        deps = set(doc.get("dependencies", {})) | set(doc.get("devDependencies", {}))
        stack = " + ".join(x for x in [
            "Next.js" if "next" in deps else "",
            "React" if "react" in deps else "",
            "Prisma" if "@prisma/client" in deps else "",
            "Playwright" if "@playwright/test" in deps else "",
            "TypeScript" if "typescript" in deps else ""] if x)
    except Exception:
        pass
mk = first("Makefile")
if mk and not cmds:
    seen = set()
    for line in open(mk):
        if line.startswith("\t") or line.startswith("#") or line.startswith("."):
            continue
        head = line.split(":")[0].strip()
        if head and "=" not in head and head not in seen and len(cmds) < 6:
            seen.add(head)
            cmds.append((head.capitalize(), f"make {head}"))
    stack = stack or "Make"
if not cmds and first("pyproject.toml", "requirements.txt", "setup.py"):
    stack = stack or "Python"
    cmds.append(("Run tests", "pytest" if (first("tests") or first("test")) else "python -m pytest (verify)"))
if first("Cargo.toml"):
    stack = stack or "Rust"
    cmds += [("Build", "cargo build"), ("Test", "cargo test")]
if first("go.mod"):
    stack = stack or "Go"
    cmds += [("Test", "go test ./..."), ("Build", "go build ./...")]
if first("docker-compose.yml", "compose.yml"):
    cmds.append(("Infra up", "docker compose up -d"))

never = [d for d in ["node_modules", ".next", "dist", "build", "vendor", "__pycache__",
                     ".venv", "venv", "target", ".turbo", "migrations"]
         if os.path.exists(os.path.join(repo, d))]
never += [p for p in [".env", ".env.local", ".env.production"] if os.path.exists(os.path.join(repo, p))]
if g.glob(os.path.join(repo, "*.db")):
    never.append("`*.db` and `*.db.bak-*` backups")
if os.path.exists(os.path.join(repo, "prisma")):
    never.append("`prisma/migrations` (append-only)")

cmd_lines = "\n".join(f"- {l}: `{c}`" for l, c in cmds) or "- Setup/Run/Test/Lint: [fill exact commands]"
never_line = ", ".join(f"`{n}`" for n in never) if never else "[generated dirs, secrets, migrations]"

ctx = f"""# {ctx_name} — project context (Agentic Engineering)

## Project map

- **What this is:** [1-2 sentences — fill me]
- **Architecture:** [key dirs/modules and what they own — one line each]{f' ({stack})' if stack else ''}
- **Never touch:** {never_line}

## Commands

{cmd_lines}

## Conventions

- [Language/framework idioms worth one line each — fill me]

## Agent rules (verbatim — do not edit)

1. **Think before coding.** State assumptions before writing code. Surface tradeoffs. Ask when uncertain; show interpretations when ambiguous. Never hide confusion.
2. **Simplicity first.** Write the minimum code that solves the stated problem. No unrequested features, no speculative abstractions.
3. **Surgical changes.** Touch only what the task requires. Don't refactor unbroken adjacent code, comments, or formatting. Match existing style; clean up your own orphans.
4. **Goal-driven execution.** Turn requests into declarative goals with success criteria, then verify. For bugs: write a failing test that reproduces it, then make it pass.

## Operating constraints

- Verifier before implementation: tests / eval / metric must exist before feature code. Loops must be resettable, fast, and unambiguous.
- Autonomy: architecture, identity/auth, security, payments, and data-model decisions are **on-the-leash** — surface to the human, never improvise.
- Delivery = what changed & why + proof (test output/logs) + what to review + what could break.
- Corrected the same thing twice → encode it here (or as a hook/test), then trim this file. Keep this file short: consolidate, never accumulate.
"""
open(ctx_path, "w").write(ctx)
print(f"created {ctx_path}: {len(ctx.splitlines())} lines, stack: {stack or 'unknown'}, "
      f"{len(cmds)} commands detected, never-touch: {len(never)} entries")
print("  → fill the two [fill me] sections, then it is live for every tool")
PYEOF
  fi

  if [ "$SKILL" = 1 ]; then
    mkdir -p "$REPO_DIR/.agents/skills"
    rm -rf "$REPO_DIR/.agents/skills/karpathy-agentic-engineering"
    cp -a "$KIT_DIR/skills/karpathy-agentic-engineering" "$REPO_DIR/.agents/skills/"
    echo "skill installed into $REPO_DIR/.agents/skills/ (travels with the repo)"
  fi
fi

# ---- 2. Claude Code guardrail hook (merge-safe, marked, removable) --------
SETTINGS="$REPO_DIR/.claude/settings.json"
MARK="agentic-engineering-kit leash"

python3 - "$SETTINGS" "$HOOKS" "$REMOVE_HOOKS" "$MARK" <<'PYEOF'
import json, os, sys

settings, add, remove, mark = sys.argv[1], sys.argv[2] == "1", sys.argv[3] == "1", sys.argv[4]

data = {}
if os.path.exists(settings):
    try:
        data = json.load(open(settings))
    except Exception as e:
        sys.exit(f"ERROR: {settings} is not valid JSON: {e}")
elif not add:
    sys.exit(0)

hooks = data.setdefault("hooks", {})
pre = hooks.setdefault("PreToolUse", [])
ours = [h for h in pre if mark in json.dumps(h)]

if remove:
    if ours:
        hooks["PreToolUse"] = [h for h in pre if mark not in json.dumps(h)]
        if not hooks["PreToolUse"]:
            del hooks["PreToolUse"]
        if not hooks:
            del data["hooks"]
        os.makedirs(os.path.dirname(settings), exist_ok=True)
        json.dump(data, open(settings, "w"), indent=2)
        print(f"removed {len(ours)} kit hook(s) from {settings}")
    else:
        print("no kit hooks found")
elif add:
    if ours:
        print(f"kit hook already present in {settings} (idempotent)")
    else:
        entry = {
            "matcher": "Bash(git push --force*)|Bash(git reset --hard*)|Bash(git clean -fd*)|Bash(rm -rf*)",
            "hooks": [{"type": "command",
                       "command": f"echo 'BLOCKED ({mark}): destructive op needs explicit human approval' && exit 2"}],
        }
        pre.append(entry)
        os.makedirs(os.path.dirname(settings), exist_ok=True)
        json.dump(data, open(settings, "w"), indent=2)
        print(f"installed guardrail hook into {settings}")
        print("  blocks: force-push, reset --hard, clean -fd, rm -rf  (remove: ./setup-repo.sh <repo> --remove-hooks)")
elif ours:
    print(f"kit hook present in {settings}")
PYEOF
