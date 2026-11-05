#!/usr/bin/env bash
# Agentic Engineering Kit — install the skill into every supported agent tool.
# Repo is the source of truth. Idempotent. No MCPs, no keys, no daemon.
set -euo pipefail

SKILL_NAME="karpathy-agentic-engineering"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$REPO_DIR/skills/$SKILL_NAME"

# Global skill locations per tool (ADMIN.md §1.2). Order: standard first.
LOCATIONS=(
  "$HOME/.agents/skills"        # Agent Skills standard: ZCode, Codex, Opencode...
  "$HOME/.claude/skills"        # Claude Code
  "$HOME/.cursor/skills"        # Cursor
  "$HOME/.gemini/skills"        # Gemini CLI / Antigravity family
  "$HOME/.gemini/antigravity/skills"       # Antigravity IDE
  "$HOME/.gemini/antigravity-cli/skills"   # agy CLI
)

UNINSTALL=0; CREATE_ALL=0
for arg in "$@"; do
  case "$arg" in
    --uninstall) UNINSTALL=1 ;;
    --all) CREATE_ALL=1 ;;
    --sync) ;; # same as default
    *) echo "unknown flag: $arg (supported: --all, --uninstall, --sync)"; exit 1 ;;
  esac
done

[ -f "$SRC/SKILL.md" ] || { echo "ERROR: $SRC/SKILL.md not found"; exit 1; }

for loc in "${LOCATIONS[@]}"; do
  if [ "$UNINSTALL" = 1 ]; then
    rm -rf "$loc/$SKILL_NAME" && echo "removed  $loc/$SKILL_NAME" || true
    continue
  fi
  if [ ! -d "$loc" ]; then
    if [ "$CREATE_ALL" = 1 ]; then
      mkdir -p "$loc"
    else
      echo "skip     $loc (missing; use --all to create)"
      continue
    fi
  fi
  rm -rf "$loc/$SKILL_NAME"
  cp -a "$SRC" "$loc/$SKILL_NAME"
  echo "installed $loc/$SKILL_NAME"
done

if [ "$UNINSTALL" = 0 ]; then
  echo
  echo "Done. Restart open agent sessions, then trigger with: karp-mode"
  echo "No skills support? Paste skills/$SKILL_NAME/PASTE-PROMPT.md into any agent."
  echo "Per-repo setup: copy templates/AGENTS-CORE.md to the project root (ADMIN.md §4)."
fi
