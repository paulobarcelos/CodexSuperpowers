---
name: code-style
description: Use when writing or reviewing code — emphasizes small, clear changes that match surrounding style, favor readability over cleverness, and keep comments evergreen (WHAT/WHY, not history).
---

# Code Style

## Small and Clear
- Make the smallest reasonable change to achieve the outcome
- Prefer clarity over cleverness; remove duplication when practical

## Match Surroundings
- Adopt local conventions (naming, formatting, file layout)
- Use project formatters where configured; otherwise don’t churn whitespace

## Naming
- Names describe what code does (domain terms), not how/when
- Avoid temporal/pattern noise (e.g., New/Legacy/Improved, *Factory*)

## Comments
- Explain WHAT and WHY; avoid historical change logs in comments
- Keep comments evergreen; remove ones that became false

