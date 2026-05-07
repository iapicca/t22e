# Story 1.4: Input Parser (VT500)

**Feature:** Terminal Foundation
**Estimate:** XL
**Depends on:** None (can be developed independently)

## Description

Implement a 2-stage VT500-inspired input parser. Stage 1 is a 13-state state machine processing bytes one-at-a-time. Stage 2 comprises semantic parsers (CSI, ESC, OSC, DCS, Char) that translate raw sequences into structured event objects.

## Tasks

| # | Task | Est. |
|---|------|------|
| 1.4.1 | VT500 13-state state machine engine | XL |
| 1.4.2 | CSI semantic parser (arrows, F-keys, SGR mouse, etc.) | L |
| 1.4.3 | ESC/OSC/DCS semantic parsers (SS3, color, clipboard, etc.) | L |
| 1.4.4 | Event type hierarchy (InputEvent, ResponseEvent, ErrorEvent, InternalEvent) | M |

## Acceptance Criteria

- State machine correctly implements the VT500 spec for all byte sequences
- CSI parser correctly identifies: arrows, F-keys, Home/End, Insert/Delete, Kitty protocol, SGR mouse, CPR, DA1 responses
- OSC parser handles: color queries, clipboard, terminal title, hyperlinks
- DCS parser handles: Kitty graphics protocol (stub)
- Event hierarchy has clear separation: `InputEvent | ResponseEvent | ErrorEvent | InternalEvent`
- Parser is fuzz-tested against known sequences from xterm, kitty, and Windows Terminal
- ESC disambiguation timer (10ms for standalone ESC vs escape sequence lead-in) is supported
