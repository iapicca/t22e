# Story 5.1: Cell-Level Renderer

**Feature:** Polish & Advanced
**Estimate:** L
**Depends on:** Diff Engine (2.4), Surface (2.1)

## Description

Implement a cell-level renderer that compares individual cells between frames and emits ANSI only for cells that changed. This eliminates flicker on terminals without sync support by minimizing output.

## Tasks

| # | Task | Est. |
|---|------|------|
| 5.1.1 | Cell-level diff renderer | L |
| 5.1.2 | Performance benchmarking | M |

## Acceptance Criteria

- Compares each cell's char and style between frames
- If style changed: emit new SGR code, then char
- If only char changed: move cursor to (row, col), write char
- If identical: skip entirely (no output)
- Cell renderer handles wide characters (only writes at start cell, skips continuation)
- Significantly reduces output compared to line-level on sparse updates
- Benchmark: measure bytes written and time per frame for both renderers
- Renderer can be selected at runtime based on terminal capability
