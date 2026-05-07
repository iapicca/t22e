# Story 2.2: TextStyle & Color Resolution

**Feature:** Rendering Core
**Estimate:** M
**Depends on:** ANSI Color Sequences (1.1.2)

## Description

Implement the TextStyle class with tiered color support, layout properties, and a color resolution/downgrade chain. Colors auto-downgrade based on terminal capability: TrueColor → 256-color palette → ANSI 16 → no color.

## Tasks

| # | Task | Est. |
|---|------|------|
| 2.2.1 | TextStyle definition | M |
| 2.2.2 | Color model with downgrade chain | M |
| 2.2.3 | Style inheritance | S |

## Acceptance Criteria

- TextStyle holds: fg/bg color (3 tiers), text attributes, padding, margin, border, width, height, align, wordWrap
- `resolveForeground(ColorProfile)` returns the best available color for the terminal
- Color downgrade is automatic and never upgrades (e.g., 256-color → ANSI 16, never reverse)
- `Style.inherit(parent)` fills null fields from parent
- Color model supports: noColor, ansi(0-15), indexed(0-255), rgb(0xFFFFFF)
- Color conversion: rgb → indexed uses 6×6×6 cube + grayscale ramp with nearest color by redmean distance
- Unit tests for each downgrade path
