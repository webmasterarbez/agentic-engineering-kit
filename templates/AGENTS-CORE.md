# AGENTS.md — project context file (Agentic Engineering core)

> Template: fill the four bracketed sections, keep the rules verbatim, stay under ~60 lines.
> Works as AGENTS.md (standard/Antigravity), CLAUDE.md (Claude Code), or GEMINI.md.

## Project map

- **What this is:** [1–2 sentences, plain language]
- **Architecture:** [key directories/modules and what they own — one line each]
- **Never touch:** [generated dirs, migration files, vendored code, secrets — list explicitly]

## Commands

- Setup: `[exact command]`
- Run: `[exact command]`
- Test (fast suite): `[exact command]`
- Lint/format: `[exact command]`

## Conventions

- [Language/framework idioms worth one line each — not a style guide, just the load-bearing habits]
- [Naming/structure rules an agent would otherwise guess wrong]

## Agent rules (verbatim — do not edit)

1. **Think before coding.** State assumptions before writing code. Surface tradeoffs. Ask when uncertain; show interpretations when ambiguous. Never hide confusion.
2. **Simplicity first.** Write the minimum code that solves the stated problem. No unrequested features, no speculative abstractions, no single-use abstractions.
3. **Surgical changes.** Touch only what the task requires. Don't refactor unbroken adjacent code, comments, or formatting. Match existing style. Clean up orphaned imports/variables you created.
4. **Goal-driven execution.** Turn requests into declarative goals with success criteria, then verify against them. For bugs: write a failing test that reproduces it, then make it pass.

## Operating constraints

- Verifier before implementation: tests / eval / metric must exist before feature code. Loops must be resettable, fast, and unambiguous.
- Autonomy: architecture, identity/auth, security, payments, and data-model decisions are **on-the-leash** — surface to the human, never improvise.
- Delivery = what changed & why + proof (test output/logs) + what to review + what could break.
- Corrected the same thing twice → encode it here (or as a hook/test), then trim this file. Keep this file short: consolidate, never accumulate.
