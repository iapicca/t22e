# Story 1.1: ANSI Escape Code Definitions

**Feature:** Terminal Foundation
**Estimate:** M
**Depends on:** None

## Description

A zero-logic definitions layer that produces ANSI escape sequences as pure string constants. No terminal I/O, no state — just functions that return the correct ANSI string for the requested operation.

## Tasks

| # | Task | Est. |
|---|------|------|
| 1.1.1 | ANSI constants (ESC, CSI, OSC, DCS, ST, BEL) | S |
| 1.1.2 | Color sequences (RGB fg/bg, 256-color, ANSI 16) | S |
| 1.1.3 | Text attribute sequences (bold, italic, dim, etc.) | S |
| 1.1.4 | Cursor sequences (moveTo, hide/show, style) | S |
| 1.1.5 | Erase sequences (screen/line clear variants) | S |
| 1.1.6 | Terminal mode sequences (alt screen, mouse, sync, etc.) | M |

## Acceptance Criteria

- All functions are pure (`String` return, no futures, no side effects)
- Constants are well-named and documented with the ANSI spec they implement
- Module structure mirrors `ansi/codes.dart`, `ansi/color.dart`, `ansi/cursor.dart`, `ansi/erase.dart`, `ansi/term.dart`
- Each function has unit tests verifying the exact output string
