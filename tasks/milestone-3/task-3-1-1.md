# task-3-1-1

## Identity

| Field        | Value                                    |
|--------------|------------------------------------------|
| Type         | Task                                     |
| Title        | Define RenderObject, RenderText, RenderRoot, and SingleChildRenderObject |
| Parent Story | task-3-1                                 |

## Objective

Implement the render tree abstractions needed by the rendering pipeline.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/engine/render_object.dart`:
  - Define a mutable base `RenderObject` class.
  - Define a `ParentData` abstraction and `BoxParentData` for offsets.
  - Define a `SingleChildRenderObject` mixin/base for one-child render objects.
  - Define `RenderText`, a leaf render object that carries string content and style.
  - Define `RenderRoot`, a single-child render object that owns a child.

- `lib/src/models/size.dart`, `lib/src/models/offset.dart`:
  - Ensure `Size` and `Offset` are usable for layout results and offsets.

- `lib/src/models/constraints.dart`:
  - Ensure `Constraints` exposes integer `minWidth`, `maxWidth`, `minHeight`, and `maxHeight`.

Out of scope (to be handled in later tasks):

- Layout and paint algorithms.
- Diff engine or ANSI output.
- Widget/Element/BuildContext abstractions (Milestone 5).
- Multi-child render objects.

## API References

- Dart API: https://dart.dev/language/class-modifiers#abstract
- Existing types: `lib/src/models/constraints.dart`, `lib/src/models/size.dart`, `lib/src/models/offset.dart`

## Acceptance Criteria

- `RenderObject` exposes `Size size`, `Offset offset`, `RenderObject? parent`, and child accessors.
- `RenderText` is a leaf render object with no children.
- `RenderRoot` is a single-child render object that owns a child.
- `SingleChildRenderObject` manages child assignment and `BoxParentData` updates.
- The render tree can be constructed and traversed manually.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Model `RenderObject` as a mutable base class with `Size size`, `Offset offset` backed by `BoxParentData`, and `RenderObject? parent`. Introduce a `SingleChildRenderObject` helper for nodes with exactly one child, managing `child` assignment and `BoxParentData` updates. `RenderText` stores the string and style and has no children. `RenderRoot` stores a single child and will later layout that child to match the terminal size and paint it at the origin. Keep the API aligned with Flutter's `RenderObject` surface so the future Widget/Element layer can attach to it without changes.

## Why

The render tree is the stable, long-lived counterpart to the short-lived widget tree that will be introduced later. Defining it first lets the pipeline operate on real layout/paint objects while the widget layer is still being designed.
