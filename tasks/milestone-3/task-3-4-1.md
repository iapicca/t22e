# task-3-4-1

## Identity

| Field        | Value                       |
|--------------|-----------------------------|
| Type         | Task                        |
| Title        | Implement Diff Engine       |
| Parent Story | task-3-4                    |

## Objective

Compare the target and current buffers cell-by-cell and produce a minimal set of update operations.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/engine/diff_engine.dart`:
  - Define a representation for diff operations (e.g., cursor move, style change, write cell).
  - Implement the sequential scan comparing two `CellBuffer` instances.
  - Track the current cursor position and emit a cursor move only when the next write index is not the natural successor.
  - Track the active style and emit a style change only when the target cell style differs.

- `lib/src/engine/cell_buffer.dart`:
  - Ensure `CellBuffer` supports index-based cell access and equality comparison.

Out of scope (to be handled in later tasks):

- ANSI sequence generation.
- Writing output to stdout.
- Region-based or run-length diff optimizations.

## API References

- Dart API: https://api.dart.dev/stable/dart-core/List/operator_get.html
- Existing types: `lib/src/engine/cell.dart`, `lib/src/engine/cell_buffer.dart`

## Acceptance Criteria

- The diff engine scans both buffers from index 0 to end.
- Only cells that differ from the current buffer generate operations.
- Cursor move operations are emitted only when the next write index is not the previous index + 1.
- Style changes are emitted only when the target cell style differs from the active style.
- After diffing, the current buffer can be replaced with a value copy of the target buffer.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Create a `DiffEngine` class with a method `List<DiffOp> diff(CellBuffer target, CellBuffer current, Size size)`. Initialize the cursor index to 0 and the active style to a default/null cell. For each index, compare `target[index]` to `current[index]`. If they differ, append a cursor move operation if the index is not `cursor + 1`, append a style change operation if the cell style differs from the active style, append a write operation for the character, and update the tracked cursor and style. Keep the operation model simple and serializable so the ANSI writer can consume it without additional logic.

## Why

The diff engine is responsible for minimizing terminal traffic. By isolating it from ANSI generation, both components can be tested independently: the diff engine can be verified purely against cell equality, and the writer can be verified against a fixed list of operations.
