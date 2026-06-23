# task-1-4-1

## Identity

| Field        | Value                         |
|--------------|-------------------------------|
| Type         | Task                          |
| Title        | Implement CellBuffer with Flat List |
| Parent Story | task-1-4                      |

## Objective

Create the `CellBuffer` class backed by a flat pre-allocated list of immutable cells.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/engine/cell_buffer.dart`:
  - Define `CellBuffer` with `int width`, `int height`, and an internal `List<Cell>` of length `width * height`.
  - Constructor accepts `width`, `height`, and a `Cell defaultCell` (defaulting to `const Cell.blank()`).
  - Provide `int get length` and `TuiSize get size` accessors.
  - Provide a `resize(int newWidth, int newHeight, Cell defaultCell)` method that reallocates the list and preserves overlapping content where possible.

Out of scope (to be handled in later tasks):

- Coordinate helpers beyond basic index math.
- Value-copy semantics and diff helper methods.
- Integration with the paint or diff passes.

## API References

- Dart API: https://api.dart.dev/stable/dart-core/List-class.html
- Package API: https://pub.dev/packages/freezed

## Acceptance Criteria

- `CellBuffer` pre-allocates a list of exactly `width * height` cells.
- The constructor fills the buffer with the provided default cell.
- `resize` changes dimensions and preserves cells that exist in both old and new overlapping regions.
- `length` and `size` report the correct values.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Store cells in a `List<Cell>` and use `List.filled(width * height, defaultCell, growable: false)` for the initial allocation. For resize, create a new list and copy cells from the overlapping old region. Keep the class free of ANSI or rendering concerns.

## Why

A flat buffer is the canonical representation of a terminal screen. Pre-allocation avoids per-frame allocation churn, and preserving content on resize is a basic quality-of-life behavior for any TUI buffer.
