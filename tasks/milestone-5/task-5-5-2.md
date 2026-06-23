# task-5-5-2

## Identity

| Field        | Value                |
|--------------|----------------------|
| Type         | Task                 |
| Title        | Implement Provider Read in Consumer Build |
| Parent Story | task-5-5             |

## Objective

Ensure `Consumer` reads the current provider value during compilation and produces the correct subtree.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/view/components/consumer.dart`:
  - Read the provider value from `TuiContext` inside `Consumer.compile`.
  - Pass the value to the builder.
  - Compile the returned widget with the same context.

Out of scope (to be handled in later tasks):

- Listening for provider changes.
- Rebuilding on provider notifications.
- Handling provider errors or loading states.

## API References

- Riverpod: https://riverpod.dev/docs/concepts/providers#reading-a-provider
- Project: `TuiContext` from task-5-4-1.

## Acceptance Criteria

- `Consumer.compile` reads the provider value synchronously.
- The builder receives the current value and the `TuiContext`.
- The compiled subtree matches the builder output for the current value.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

In `Consumer.compile`, call `context.read<T>(provider)` to obtain the current value. Invoke `builder(context, value)` to get the child widget. Then call `childWidget.compile(context)` and return the resulting node. This makes the consumer node a transparent wrapper around whatever the builder returns for the current snapshot.

## Why

Reading the provider value at compile time is the first half of `Consumer` behavior. It ensures the initial frame reflects the current application state before any listener-driven rebuilds are implemented.
