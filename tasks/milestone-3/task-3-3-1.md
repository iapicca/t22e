# task-3-3-1

## Identity

| Field        | Value                         |
|--------------|-------------------------------|
| Type         | Task                          |
| Title        | Implement Paint Pass for TextNode |
| Parent Story | task-3-3                      |

## Objective

Write `TextNode` content into the target `CellBuffer` during the paint pass.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/engine/cell.dart`:
  - Ensure `Cell` is immutable and provides a sensible default/null cell.

- `lib/src/engine/cell_buffer.dart`:
  - Ensure `CellBuffer` supports coordinate-based writes and bounds checks.

- `lib/src/view/widget.dart` or `lib/src/engine/node.dart`:
  - Add a `void paint(CellBuffer buffer, TuiOffset offset)` contract to `Node`.

- `lib/src/view/components/text.dart`:
  - Implement `paint` on `TextNode` to write characters as `Cell` values.

- `lib/src/engine/pipeline.dart`:
  - Implement the paint step that creates the target buffer and invokes `paint` on the root node.

Out of scope (to be handled in later tasks):

- Diff engine and ANSI output.
- Multi-child painting and z-ordering.
- Complex text wrapping or truncation.

## API References

- Dart API: https://api.dart.dev/stable/dart-core/String/codeUnitAt.html
- Dart API: https://api.dart.dev/stable/dart-core/String/length.html
- Existing types: `lib/src/engine/cell.dart`, `lib/src/engine/cell_buffer.dart`

## Acceptance Criteria

- `Node.paint` writes `Cell` values into the provided `CellBuffer`.
- `TextNode` writes each character at the correct `(x, y)` using its style.
- Writing outside the node bounds is clipped.
- The pipeline paint step creates a fresh target buffer of terminal size and paints the root node.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Add `paint(CellBuffer buffer, TuiOffset offset)` to the `Node` base class. For `TextNode`, split the content into lines, then for each character create an immutable `Cell` carrying the character and style flags, and write it to `buffer[offset + characterOffset]` using the buffer's coordinate helpers. Skip characters whose coordinates exceed the node's computed width or height. The pipeline creates the target `CellBuffer` with terminal dimensions and calls `root.paint(target, TuiOffset.zero)`.

## Why

Paint is the final content-producing stage before diffing. Getting it correct for `TextNode` first provides a foundation for more complex widgets and ensures the diff engine has a well-formed target buffer to compare against.
