# Feature: Rendering Core

**Phase:** 2
**Priority:** P0 - Must have
**Depends on:** Feature 1 (ansi codes, unicode widths)

## Description

Build the core rendering pipeline: a 2D cell grid (Surface), TextStyle with color resolution/downgrade, layout algorithm, and diff-based output engine. This translates declarative widget trees into terminal output.

## Stories

| # | Story | Est. |
|---|-------|------|
| 2.1 | 2D Cell Grid (Surface) | L |
| 2.2 | TextStyle & Color Resolution | M |
| 2.3 | Layout Algorithm | M |
| 2.4 | Diff Engine & Output | L |

## Acceptance Criteria

- Surface supports grapheme-aware text placement, fill, clear, borders
- TextStyle supports tiered color (truecolor → 256 → ANSI 16) with auto-downgrade
- Layout algorithm correctly splits horizontal/vertical space between fixed and flexible items
- Diff engine compares frames at line level and produces minimal ANSI output
- Synchronized update support eliminates flicker
- All rendering is pure (input → output, no side effects)
