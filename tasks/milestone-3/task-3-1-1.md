# task-3-1-1

## Identity

| Field        | Value                                    |
|--------------|------------------------------------------|
| Type         | Task                                     |
| Title        | Define Widget, Node, TextNode, and Build Pass |
| Parent Story | task-3-1                                 |

## Objective

Implement the widget-to-node build pass and the runtime node abstractions needed by the rendering pipeline.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/view/widget.dart`:
  - Define an immutable base `Widget` class.
  - Define a `Node` base class returned by widget compilation.
  - Provide a contract (e.g., `Node compile(TuiContext context)`) for converting widgets to nodes.

- `lib/src/view/components/text.dart`:
  - Define a `Text` widget holding a string and optional style flags.
  - Define a `TextNode` carrying the same data as the runtime node.

- `lib/src/engine/pipeline.dart`:
  - Implement the `build` step that accepts a root widget and `TuiContext` and returns the root `Node`.

- `lib/src/view/context.dart`:
  - Ensure `TuiContext` exposes the provider container to widgets during the build pass.

Out of scope (to be handled in later tasks):

- Layout, paint, diff, or ANSI output.
- Multi-child widgets.
- Real provider-driven state changes.

## API References

- Dart API: https://dart.dev/language/class-modifiers#abstract
- Dart API: https://api.dart.dev/stable/dart-core/Object/operator_equals.html
- Riverpod API: https://pub.dev/documentation/riverpod/latest/riverpod/ProviderContainer-class.html

## Acceptance Criteria

- `Widget` and `Node` base classes are immutable and equality-comparable.
- `Text` widget compiles to a `TextNode` with matching content and style.
- The build step accepts a root widget and `TuiContext` and returns the root node.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Model `Widget` as an abstract immutable class with a single `Node compile(TuiContext context)` method. `Node` is an abstract immutable base class carrying an optional key and style. `Text` extends `Widget` and returns a `TextNode`. The build step is a recursive function that walks the widget tree, calling `compile` on each widget and collecting the resulting nodes. Because only `Text` is in scope for this milestone, the initial node tree is shallow.

## Why

The build pass is the first stage of the rendering pipeline. Establishing the widget/node split now lets later stories focus on layout and paint without mixing declarative API concerns with engine runtime concerns.
