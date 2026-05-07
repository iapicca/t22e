# Story 1.3: Unicode Width Tables

**Feature:** Terminal Foundation
**Estimate:** L
**Depends on:** None (standalone data tables)

## Description

Implement a 3-stage lookup table for O(1) Unicode character property queries: width (0/1/2/ambiguous), emoji flag, printable flag, and private-use detection. Must handle grapheme clusters (base + ZWJ + variation selectors).

## Tasks

| # | Task | Est. |
|---|------|------|
| 1.3.1 | 3-stage lookup table generation and data | L |
| 1.3.2 | Character width querying API | S |
| 1.3.3 | Grapheme cluster handling (ZWJ, VS, CJK) | M |

## Acceptance Criteria

- `width(int codepoint)` returns correct column width (0, 1, 2) per Unicode standard
- Ambiguous-width characters are resolved using the terminal's configured width (default 1)
- Grapheme clusters are correctly identified: base + zero-width joiners + variation selectors
- CJK ideographs return width 2
- Emoji sequences (including ZWJ sequences like family, skin tones) are handled
- Tables are auto-generated from Unicode data files (script in tool/)
