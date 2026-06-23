# task-5-1-3

## Identity

| Field        | Value                |
|--------------|----------------------|
| Type         | Task                 |
| Title        | Define Widget-to-Node Build Contract |
| Parent Story | task-5-1             |

## Objective

Wire the widget compile step into the engine build pass so a widget tree produces a node tree.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/view/widget.dart` and `lib/src/engine/pipeline.dart`:
  - Ensure each widget can compile to a node given a `TuiContext`.
  - Add a build/compile entry point on the pipeline or root widget.
  - Recursively compile child widgets into child nodes.

Out of scope (to be handled in later tasks):

- Provider-driven rebuilds.
- Layout and paint correctness for concrete widgets.
- Frame scheduling and diff engine integration.

## API References

- Project: Milestone 3 rendering pipeline classes.
- Project: `TuiContext` from task-5-4.

## Acceptance Criteria

- A root widget can be compiled into a root node.
- Child widgets are recursively compiled into child nodes.
- The resulting tree structure mirrors the widget tree.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Define the compile method signature as `Node compile(TuiContext context)`. Parent node compilation should call `compile` on each child widget and attach the resulting child nodes. Update the engine pipeline's build pass to start compilation from the root widget with a `TuiContext`. For now, the pipeline may construct the root widget itself or accept it as a parameter. Verify tree structure with a test using stub widgets.

## Why

The build contract is the first step of every frame. Nailing down how widgets become nodes makes the rest of the pipeline deterministic and testable.
