# task-3-3-1

## Identity

| Field        | Value                         |
|--------------|-------------------------------|
| Type         | Task                          |
| Title        | Implement Paint Pass for RenderObject Tree |
| Parent Story | task-3-3                      |

## Objective

Write render object content into the target `CellBuffer` during the paint pass.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/engine/cell.dart`:
  - Ensure `Cell` is immutable and provides a sensible default/null cell.

- `lib/src/engine/cell_buffer_builder.dart`:
  - Define a mutable `CellBufferBuilder` that collects many cell writes.
  - Provide a `CellBuffer build()` method that produces an immutable `CellBuffer`.

- `lib/src/engine/render_object.dart`:
  - Add a `void paint(CellBufferBuilder buffer, Offset offset)` contract to `RenderObject`.
  - Implement `paint` on `RenderText` and `RenderRoot`.

- `lib/src/engine/pipeline.dart`:
  - Implement the paint step that creates a `CellBufferBuilder`, invokes `paint` on the root render object, and builds the immutable target `CellBuffer`.

Out of scope (to be handled in later tasks):

- Diff engine and ANSI output.
- Multi-child painting and z-ordering.
- Complex text wrapping or truncation.

## API References

- Dart API: https://api.dart.dev/stable/dart-core/String/codeUnitAt.html
- Dart API: https://api.dart.dev/stable/dart-core/String/length.html
- Existing types: `lib/src/engine/cell.dart`, `lib/src/engine/cell_buffer.dart`

## Acceptance Criteria

- `RenderObject.paint` writes `Cell` values into the provided `CellBufferBuilder`.
- `RenderText` writes each character at the correct `(x, y)` using its style.
- `RenderRoot` paints its child at the child's assigned offset.
- Writing outside the render object bounds is clipped.
- The pipeline paint step creates a `CellBufferBuilder` of terminal size, paints the root render object, and builds the immutable target `CellBuffer`.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Add `paint(CellBufferBuilder buffer, Offset offset)` to the `RenderObject` base class. For `RenderText`, split the content into lines, then for each character create an immutable `Cell` carrying the character and style flags, and write it to the builder using the builder's coordinate helpers. Skip characters whose coordinates exceed the render object's computed width or height. `RenderRoot` calls `child.paint(buffer, offset + child.offset)`. The pipeline creates a `CellBufferBuilder` with terminal dimensions, calls `root.paint(builder, Offset.zero)`, and then builds the immutable target `CellBuffer`.

## Why

Paint is the final content-producing stage before diffing. Getting it correct for `RenderText` first provides a foundation for more complex widgets and ensures the diff engine has a well-formed target buffer to compare against.
