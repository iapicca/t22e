# task-5-1-2

## Identity

| Field        | Value                |
|--------------|----------------------|
| Type         | Task                 |
| Title        | Define Element/Node Abstraction |
| Parent Story | task-5-1             |

## Objective

Define the lightweight runtime node that represents a widget inside the engine pipeline.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/view/widget.dart` or a new `lib/src/engine/node.dart`:
  - Define the `Element`/`Node` base class.
  - Store the originating widget, parent/children references, size, and offset.
  - Declare `layout` and `paint` method signatures.

Out of scope (to be handled in later tasks):

- Layout and paint implementations for specific widgets.
- Build pass integration with `TuiContext`.
- Dirty tracking and element reuse.

## API References

- Dart API: https://api.dart.dev/stable/dart-core/List-class.html

## Acceptance Criteria

- `Element`/`Node` exists and references its originating widget.
- It stores children, size, and offset.
- It exposes typed `layout` and `paint` entry points.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Define a base `Element` or `Node` class with fields for `Widget widget`, `Element? parent`, `List<Element> children`, `TuiSize size`, and `TuiOffset offset`. Add abstract or stub methods `void layout(Constraints constraints)` and `void paint(CellBuffer buffer)`. Use the geometry types defined in Milestone 1. Keep the node mutable in its computed fields but treat its widget reference as immutable.

## Why

The node is the engine's view of the widget tree. Separating it from the widget lets the engine mutate runtime layout data while keeping the public widget API immutable and declarative.
