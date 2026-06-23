# task-3-2-1

## Identity

| Field        | Value                       |
|--------------|-----------------------------|
| Type         | Task                        |
| Title        | Implement Simplified Layout Pass |
| Parent Story | task-3-2                    |

## Objective

Compute integer-cell sizes and offsets for engine nodes using a simplified layout pass.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/models/constraints.dart`:
  - Ensure `Constraints` exposes integer `minWidth`, `maxWidth`, `minHeight`, and `maxHeight`.
  - Provide helpers such as `tighten` or `enforce` if useful.

- `lib/src/models/geometry.dart`:
  - Ensure `TuiSize` and `TuiOffset` are usable for layout results and offsets.

- `lib/src/view/widget.dart` or `lib/src/engine/node.dart`:
  - Add a `TuiSize layout(Constraints constraints)` contract to `Node`.

- `lib/src/view/components/text.dart`:
  - Implement layout for `TextNode`: measure the string and return a size bounded by constraints.

- `lib/src/engine/pipeline.dart`:
  - Implement the layout step that invokes `layout` on the root node with terminal-size constraints.

Out of scope (to be handled in later tasks):

- Multi-child layout and positioning.
- Flex, Row, Column, or alignment widgets.
- Text wrapping beyond simple newline splitting.

## API References

- Dart API: https://api.dart.dev/stable/dart-core/String/split.html
- Dart API: https://api.dart.dev/stable/dart-math/dart-math-library.html
- Existing types: `lib/src/models/constraints.dart`, `lib/src/models/geometry.dart`

## Acceptance Criteria

- `Node.layout` accepts `Constraints` and returns a `TuiSize`.
- `TextNode` returns a size that fits within the provided constraints.
- The pipeline layout step seeds the root with terminal dimensions.
- Offsets are assigned to nodes for later painting.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Define `layout` as an abstract method on `Node` returning `TuiSize`. For `TextNode`, split the content on newlines, compute width as the longest line length and height as the number of lines, then clamp both dimensions by the constraints. The pipeline calls `root.layout(Constraints.tight(terminalSize))` to start the pass. Store the resulting size (and offset) on the node so the paint pass can read them without recomputing.

## Why

Layout must precede paint so that paint knows exactly where each character belongs. A simplified integer layout is sufficient for the first full-screen `Text` deliverable and can be extended later without changing the node contract.
