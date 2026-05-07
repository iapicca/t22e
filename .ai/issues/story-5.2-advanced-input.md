# Story 5.2: Advanced Input (Kitty, Mouse, Clipboard, Hyperlinks)

**Feature:** Polish & Advanced
**Estimate:** L
**Depends on:** Input Parser (1.4), Capability Detection (3.2)

## Description

Implement advanced input protocols: Kitty keyboard protocol for proper modifier reporting, SGR mouse mode for click/drag/wheel, clipboard integration via OSC 52, and hyperlink rendering via OSC 8.

## Tasks

| # | Task | Est. |
|---|------|------|
| 5.2.1 | Kitty keyboard protocol | M |
| 5.2.2 | Mouse support (SGR) | M |
| 5.2.3 | Clipboard integration | S |
| 5.2.4 | Hyperlinks | S |

## Acceptance Criteria

- Kitty protocol: Ctrl+letter sends the actual key code instead of ASCII control char
- Kitty: KeyEvent includes modifiers, event type (press/repeat/release), all keys
- Mouse: click, release, drag, wheel events with SGR encoding
- Mouse: distinguish between buttons (left, middle, right) and wheel (up, down)
- Mouse: coordinate reporting (1-based row, col)
- Clipboard: read via OSC 52 (paste), write via OSC 52 (copy)
- Hyperlinks: text rendered with OSC 8 hyperlink sequences
- All features gracefully degrade if terminal doesn't support them
