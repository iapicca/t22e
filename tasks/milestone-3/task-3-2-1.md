# task-3-2-1

## Identity

| Field        | Value                       |
|--------------|-----------------------------|
| Type         | Task                        |
| Title        | Implement Two-Pass Constraint Layout |
| Parent Story | task-3-2                    |

## Objective

Compute integer-cell sizes and offsets for render objects using a two-pass constraint layout.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/models/constraints.dart`:
  - Ensure `Constraints` exposes integer `minWidth`, `maxWidth`, `minHeight`, and `maxHeight`.
  - Provide helpers such as `tighten` or `enforce` if useful.

- `lib/src/models/size.dart`, `lib/src/models/offset.dart`:
  - Ensure `Size` and `Offset` are usable for layout results and offsets.

- `lib/src/engine/render_object.dart`:
  - Add a `Size layout(Constraints constraints)` contract to `RenderObject`.
  - Implement `performLayout(Constraints constraints)` for `RenderText` and `RenderRoot`.

- `lib/src/engine/pipeline.dart`:
  - Implement the layout step that invokes `layout` on the root render object with terminal-size constraints.

Out of scope (to be handled in later tasks):

- Multi-child layout and positioning.
- Flex, Row, Column, or alignment widgets.
- Fractional sizes or complex constraint negotiation.
- Scrollable or overflow behavior beyond clipping.

## API References

- Dart API: https://api.dart.dev/stable/dart-core/String/split.html
- Dart API: https://api.dart.dev/stable/dart-math/dart-math-library.html
- Existing types: `lib/src/models/constraints.dart`, `lib/src/models/size.dart`, `lib/src/models/offset.dart`

## Acceptance Criteria

- `RenderObject.layout` accepts `Constraints` and returns a `Size`.
- `RenderText` returns a size matching its content within given constraints.
- `RenderRoot` sizes its child to the terminal bounds and assigns offset `(0, 0)`.
- The pipeline layout step seeds the root with terminal dimensions.
- Offsets are assigned to render objects for later painting.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Implement `layout(Constraints)` on `RenderObject` as the public entry point that delegates to `performLayout(Constraints)`. Subclasses set `this.size` during `performLayout`. `RenderText` splits its string on newlines, computes width as the longest line and height as the line count, and clamps both by the constraints. `RenderRoot` receives tight terminal constraints, calls `child.layout(constraints)`, and sets `child.offset` to `Offset(0, 0)`. The pipeline starts the pass by calling `root.layout(Constraints.tight(terminalSize))`.

## Why

Layout determines where each render object will paint. Adopting Flutter's two-pass constraint protocol from the start ensures the API can grow into real layout widgets later without a breaking redesign.
