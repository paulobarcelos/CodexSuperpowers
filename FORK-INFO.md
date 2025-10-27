# Fork Info

This repository is a clean-slate fork of obra/superpowers, adapted for Codex CLI (GPT‑5).

## Why a fork?
- Claude Code has a first‑party plugin + Skills system; Codex CLI does not.
- We needed Codex‑tuned instructions (tone, planning hooks, manual activation).
- We want transparent attribution while avoiding confusion with the upstream.

## What changed (overview)
- "CLAUDE.md" → "AGENTS.md" as the central repo guide
- Removed plugin/Skill‑tool assumptions; added a manual session ritual
- Rewrote skills to rely on Codex’s Plan/Updated Plan UI (no TodoWrite)
- Updated examples, paths, and docs to Codex idioms

## Licensing and attribution
- Upstream: MIT License © Jesse Vincent and contributors
- This fork: MIT as well; see `LICENSE` and `NOTICE`

## Naming and repository
- Working title: "Codex Superpowers" (you may rename in your org)
- Not affiliated with Anthropic, OpenAI, or the upstream maintainers

## Migration notes
- If you used the original plugin flow, read `README.md` → Manual Setup
- Keep `AGENTS.md` in your project root so Codex applies the plan rules
- Load skills on demand by showing Codex the relevant `SKILL.md`

