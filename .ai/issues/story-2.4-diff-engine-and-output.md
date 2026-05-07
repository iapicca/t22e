# Story 2.4: Diff Engine & Output

**Feature:** Rendering Core
**Estimate:** L
**Depends on:** Surface (2.1), TextStyle (2.2)

## Description

Implement the diff-based output engine that compares the current frame against the previous frame and emits minimal ANSI escape sequences to update only changed cells/rows. Supports synchronized updates for flicker-free rendering.

## Tasks

| # | Task | Est. |
|---|------|------|
| 2.4.1 | Frame comparison (line-level diff) | M |
| 2.4.2 | Line-level renderer | M |
| 2.4.3 | Synchronized update support | S |

## Acceptance Criteria

- Line-level diff: compares plain text AND styled text per row
- Only emits ANSI for rows that differ — unchanged rows are skipped
- Emits `CSI row;0H` to position cursor at start of changed row, then the styled row content
- Synchronized update wraps output in `\x1b[?2026h` / `\x1b[?2026l` when supported
- Renderer is stateless (all state is in the previous frame passed as parameter)
- Frame is a pair of `List<String>` (plain lines + styled lines)
- Performance target: diff 1000 rows in < 1ms
