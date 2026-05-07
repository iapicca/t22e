# Story 2.3: Layout Algorithm

**Feature:** Rendering Core
**Estimate:** M
**Depends on:** Geometry Types (2.1.3)

## Description

Implement the layout algorithm that splits available space horizontally and vertically between children. Items can be fixed-size or flexible, with optional gaps. This is the foundation for Row/Column widgets.

## Tasks

| # | Task | Est. |
|---|------|------|
| 2.3.1 | SplitHorizontal layout | M |
| 2.3.2 | SplitVertical layout | M |
| 2.3.3 | Constraints and measuring | S |

## Acceptance Criteria

- `splitHorizontal(total, items, gap)`: fixed items get exact width, remaining space is split among flexible items (evenly or proportionally)
- `splitVertical(total, items, gap)`: same algorithm vertically
- Edge cases handled: all fixed, all flexible, single item, zero remaining space
- Constraints: min/max width/height, unbounded, tight (exact)
- Measuring: each widget computes its intrinsic size given constraints
- Flexible items can have flex factors (e.g., flex: 2 is twice as large as flex: 1)
- Unit tests for common layout combinations
