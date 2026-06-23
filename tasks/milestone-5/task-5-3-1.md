# task-5-3-1

## Identity

| Field        | Value                |
|--------------|----------------------|
| Type         | Task                 |
| Title        | Implement Root Scaffold Widget |
| Parent Story | task-5-3             |

## Objective

Create the public root widget that hosts a single child and binds it to the full terminal screen.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/view/components/root.dart`:
  - Define a root widget class (e.g., `TuiRoot` or `Root`).
  - Accept a terminal size and a single child widget.
  - Compile to a root element/node.

Out of scope (to be handled in later tasks):

- Resize handling.
- Alternate screen buffer integration.
- Engine-to-root lifecycle wiring.

## API References

- Project: `Widget` base class from task-5-1-1.
- Project: `TuiSize` from Milestone 1.

## Acceptance Criteria

- The root widget is immutable and accepts a child plus terminal size.
- It compiles to a root node.
- The child widget is compiled recursively.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Create `lib/src/view/components/root.dart`. Define a root widget with final fields for `TuiSize terminalSize` and `Widget child`. Provide a const constructor. Override the compile method to create a `RootNode` that stores the terminal size and compiles the child into its own node. Keep the root generic enough that the engine can construct it with the current terminal size each frame.

## Why

The root widget is the bridge between engine-controlled terminal dimensions and the developer's widget tree. It is required before any full-screen widget can be rendered.
