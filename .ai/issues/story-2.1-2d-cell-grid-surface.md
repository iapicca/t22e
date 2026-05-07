# Story 2.1: 2D Cell Grid (Surface)

**Feature:** Rendering Core
**Estimate:** L
**Depends on:** Unicode Width Tables (1.3), Geometry Types

## Description

Implement the 2D cell grid that is the core rendering surface. Each cell holds a grapheme cluster, its style, and a wide-continuation flag. The Surface provides mutation operations (putText, fillRect, clearRect, drawBorder) and serialization to ANSI strings.

## Tasks

| # | Task | Est. |
|---|------|------|
| 2.1.1 | Cell class definition | S |
| 2.1.2 | Surface class with grid operations | L |
| 2.1.3 | Geometry types (Rect, Point, Insets) | S |

## Acceptance Criteria

- Cell stores: grapheme cluster string, TextStyle, wideContinuation bool
- `putText()` is grapheme-aware, wide-char aware, and clips at surface boundaries
- `fillRect()` fills a rectangular region with a given char and style
- `clearRect()` resets cells to default
- `drawBorder()` draws box-drawing characters with optional title
- `toAnsiLines()` produces one ANSI-styled string per row
- `toPlainLines()` produces plain text per row (for diff comparison)
- Surface is zero-indexed (0,0 = top-left), row-major
