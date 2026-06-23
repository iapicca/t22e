# task-5-2-2

## Identity

| Field        | Value                |
|--------------|----------------------|
| Type         | Task                 |
| Title        | Implement Text Layout |
| Parent Story | task-5-2             |

## Objective

Implement layout for the text node so it reports the correct terminal-cell size.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/view/components/text.dart`:
  - Implement `TextNode.layout`.
  - Compute desired width from string length (clamped by constraints).
  - Set height to one row.

Out of scope (to be handled in later tasks):

- Multi-line text height.
- Unicode character width beyond one cell per character.
- Text overflow strategies such as ellipsis.

## API References

- Project: `Constraints` from Milestone 1.
- Project: `TuiSize` from Milestone 1.

## Acceptance Criteria

- `TextNode.layout` computes a size of at least `1` in height.
- Width equals the string length unless constrained narrower.
- The computed size respects min/max width and height constraints.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

In `TextNode.layout`, compute `width = text.length.clamp(constraints.minWidth, constraints.maxWidth)` and `height = 1.clamp(constraints.minHeight, constraints.maxHeight)`. Store the resulting `TuiSize` on the node. If the text is empty, still report a width of zero or one based on the chosen design, documented in tests. This implementation intentionally stays simple to match the milestone scope.

## Why

Correct layout is required before paint can place characters accurately. A simple one-line text layout keeps the first milestone achievable while establishing the layout callback pattern.
