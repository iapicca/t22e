# task-5-4-3

## Identity

| Field        | Value                |
|--------------|----------------------|
| Type         | Task                 |
| Title        | Pass TuiContext Through Build Pass |
| Parent Story | task-5-4             |

## Objective

Ensure every widget compilation receives the same `TuiContext` so provider reads work anywhere in the tree.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/view/widget.dart` and concrete widget files:
  - Update the `compile` signature to accept `TuiContext`.
  - Forward the context to child widget compilations.
  - Store the context on nodes that need it for paint or layout.

Out of scope (to be handled in later tasks):

- Context scoping per subtree.
- Mutable context state.
- Provider watch rebuild registration.

## API References

- Project: `TuiContext` from task-5-4-1.

## Acceptance Criteria

- All widget `compile` methods accept a `TuiContext` parameter.
- Parent widgets pass the context to child `compile` calls unchanged.
- Nodes can access the context if needed.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Update the abstract `Widget` base class so that `compile` takes `TuiContext context`. Update `Root`, `Text`, and any stub widgets to forward the context. In parent nodes, when compiling children, pass the same `TuiContext` instance. Optionally store the context on the node base class so nodes can read providers during layout or paint, though reads during build are preferred for this milestone.

## Why

Consistent context propagation is required for any widget to read providers. A single shared context instance is sufficient for the first milestone and avoids premature complexity around scoping.
