# Story 4.2: Container Widgets (Row, Column)

**Feature:** Widget Library
**Estimate:** M
**Depends on:** Layout Algorithm (2.3)

## Description

Implement Row and Column layout widgets that distribute space among children using the layout algorithm (fixed/flexible sizing with gaps).

## Tasks

| # | Task | Est. |
|---|------|------|
| 4.2.1 | Row widget | M |
| 4.2.2 | Column widget | M |

## Acceptance Criteria

- Row lays out children horizontally, Column vertically
- Children can be fixed-size or flexible (with flex factors)
- Gap between children is configurable
- Row widths sum to parent width (after accounting for gaps and flex)
- Column heights sum to parent height (same logic)
- Widgets handle overflow (clipping) and underflow (flexible items shrink to minimum)
- `mainAxisAlignment` (start, center, end, spaceBetween, spaceAround)
- `crossAxisAlignment` (start, center, end, stretch)
- Unit tests: layout with various child combinations, alignment
