# Story 3.2: Terminal Capability Detection

**Feature:** Application Architecture
**Estimate:** L
**Depends on:** ANSI sequences (1.1), Input parser (1.4)

## Description

Implement a sequential probe pipeline that queries terminal capabilities: color depth, synchronized update support, keyboard enhancement protocol, Unicode support, window size, and color scheme.

## Tasks

| # | Task | Est. |
|---|------|------|
| 3.2.1 | Device Attributes (DA1) query | M |
| 3.2.2 | Color capability detection (OSC 10/11) | M |
| 3.2.3 | Sync update support detection (?2026) | S |
| 3.2.4 | Keyboard enhancement protocol detection | M |

## Acceptance Criteria

- Probe pipeline runs sequentially (each step may depend on previous results)
- Each probe returns `QueryResult<T>` — either `Supported<T>` or `Unavailable`
- Color depth is detected: no color, ANSI 16, 256-color, truecolor
- Sync update support is detected via DECRPM on ?2026
- Kitty keyboard protocol support is probed
- Window size is queried (rows, columns, optionally pixels)
- Unicode support is detected
- Color scheme (light/dark) is detected via OSC 10/11
- Probes have timeouts — if terminal doesn't respond, return Unavailable
- Results are cached and available throughout the app lifecycle
