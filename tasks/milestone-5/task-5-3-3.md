# task-5-3-3

## Identity

| Field        | Value                |
|--------------|----------------------|
| Type         | Task                 |
| Title        | Wire Root to Engine Pipeline |
| Parent Story | task-5-3             |

## Objective

Connect the root widget to the engine frame scheduler so the engine can build a frame from a developer-supplied widget tree.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/engine/pipeline.dart` and `lib/src/engine/scheduler.dart`:
  - Accept a root widget builder or instance from the application.
  - Construct the root widget with the current terminal size.
  - Run build, layout, paint, diff, and flush on the root node tree.

Out of scope (to be handled in later tasks):

- Provider-driven frame invalidation.
- Terminal resize detection.
- Public application binding API.

## API References

- Project: Rendering pipeline from Milestone 3.
- Project: Root widget from task-5-3-1.

## Acceptance Criteria

- The engine can be given a widget tree root.
- Each frame builds the root with the current terminal size.
- The full pipeline (build → layout → paint → diff → flush) executes end-to-end.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Update the engine pipeline or scheduler to accept a `Widget root` or a builder that returns one. At frame time, read the current terminal size, construct the root widget with that size and the application child, compile it to a node tree, run layout, paint into the target `CellBuffer`, diff, and flush. Keep the integration minimal; the public binding API is refined in Milestone 6.

## Why

This task closes the loop between the declarative widget layer and the existing rendering pipeline. Without it, widgets would exist but never be rendered.
