# task-5-3-2

## Identity

| Field        | Value                |
|--------------|----------------------|
| Type         | Task                 |
| Title        | Implement Root Layout Sizing |
| Parent Story | task-5-3             |

## Objective

Implement root node layout so the child fills the entire terminal rectangle.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/view/components/root.dart`:
  - Implement `RootNode.layout`.
  - Set the root node size to the terminal size.
  - Position the child at `(0, 0)` and lay it out with the full terminal constraints.

Out of scope (to be handled in later tasks):

- Padding, margins, or alignment.
- Resize events.
- Multi-child roots.

## API References

- Project: `Constraints` from Milestone 1.
- Project: `TuiOffset` and `TuiSize` from Milestone 1.

## Acceptance Criteria

- `RootNode.layout` sets the node size to the terminal size.
- The child offset is `(0, 0)`.
- The child receives constraints equal to the terminal width and height.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

In `RootNode.layout`, store the terminal size as the root size. Create a `Constraints` with min and max width/height equal to the terminal dimensions. Call `child.layout(constraints)` and set `child.offset = TuiOffset(0, 0)`. Because the root is full-screen, the child should be allowed to take the entire rectangle.

## Why

The root defines the coordinate system for the whole frame. Ensuring the child fills the terminal rectangle is what makes the output "full-screen."
