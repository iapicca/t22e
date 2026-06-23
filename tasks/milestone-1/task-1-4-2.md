# task-1-4-2

## Identity

| Field        | Value                                         |
|--------------|-----------------------------------------------|
| Type         | Task                                          |
| Title        | Add Coordinate Helpers and Value-Copy Semantics |
| Parent Story | task-1-4                                      |

## Objective

Add 2D coordinate access and value-copy helpers to `CellBuffer` so callers can address cells naturally and duplicate buffers safely.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/engine/cell_buffer.dart`:
  - Add `int indexAt(int x, int y)` using `(y * width) + x`.
  - Add `TuiOffset offsetAt(int index)` using `TuiOffset(index % width, index ~/ width)`.
  - Add `Cell get(int x, int y)` and `Cell getAt(int index)` accessors.
  - Add `void set(int x, int y, Cell cell)` and `void setAt(int index, Cell cell)` mutators.
  - Add `void copyFrom(CellBuffer source)` to overwrite this buffer's cells with the source buffer's cells, using a value-copy approach.
  - Add bounds checking that throws `RangeError` or `ArgumentError` for invalid coordinates.

Out of scope (to be handled in later tasks):

- Diff engine or minimal update logic.
- Region copies (sub-rect) beyond the full-buffer copy.
- ANSI output or cursor positioning.

## API References

- Dart API: https://api.dart.dev/stable/dart-core/RangeError-class.html
- Package API: https://pub.dev/packages/freezed

## Acceptance Criteria

- `indexAt` and `offsetAt` are inverse operations for every valid coordinate.
- `get`/`set` and `getAt`/`setAt` read and write the same cell.
- `copyFrom` replaces all cells in the destination with the corresponding cells from the source, and subsequent mutations to either buffer do not affect the other.
- Out-of-bounds access throws a clear error.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Implement helpers as small, deterministic methods. For `copyFrom`, copy the source's `List<Cell>` references into the destination list; because `Cell` is immutable, this is a safe value-copy. Validate bounds explicitly so that misuse fails fast during development and testing.

## Why

Coordinate helpers translate between the 2D terminal model and the 1D list representation required for performance. Value-copy semantics are essential for double buffering: after diffing, the engine must copy the target buffer into the current display buffer without sharing mutable state.
