# task-5-4-2

## Identity

| Field        | Value                |
|--------------|----------------------|
| Type         | Task                 |
| Title        | Bridge Riverpod Container to TuiContext |
| Parent Story | task-5-4             |

## Objective

Instantiate `TuiContext` with the application's Riverpod container and make it available at the start of the build pass.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/view/context.dart` and engine entry points:
  - Create a `TuiContext` from the active `ProviderContainer`.
  - Ensure the context is passed into the root widget compilation.

Out of scope (to be handled in later tasks):

- Provider override scopes.
- Disposal of the container (managed by application).
- Watch/listen-based rebuild triggers.

## API References

- Riverpod: https://riverpod.dev/docs/concepts/providers#providercontainer
- Project: `TuiContext` from task-5-4-1.

## Acceptance Criteria

- A `TuiContext` can be created from a `ProviderContainer`.
- The context reaches the root widget's compile call.
- Provider reads through the context return the expected values.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Where the engine or binding creates the root widget, also create a `TuiContext` from the `ProviderContainer` held by the application. Pass this context as an argument to the root widget's `compile` method and store it on the root node so descendant widgets can access it during their own compilation. Write a test that creates a `ProviderContainer` with a simple `StateProvider`, builds a `TuiContext`, and reads the value.

## Why

The bridge is what makes the rest of the framework provider-aware. Without it, `Consumer` widgets and provider-driven state cannot function.
