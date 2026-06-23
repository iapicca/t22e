# task-5-5-1

## Identity

| Field        | Value                |
|--------------|----------------------|
| Type         | Task                 |
| Title        | Implement Consumer Widget |
| Parent Story | task-5-5             |

## Objective

Create the public `Consumer` widget that reads a provider and builds a child widget from the provider value.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/view/components/consumer.dart`:
  - Define a `Consumer` widget class.
  - Accept a provider and a builder function.
  - Compile to a `ConsumerNode` that evaluates the builder.

Out of scope (to be handled in later tasks):

- Rebuild listener registration.
- Multi-provider consumers.
- Selective rebuild optimization.

## API References

- Riverpod: https://riverpod.dev/docs/concepts/providers#reading-a-provider
- Project: `Widget` base class from task-5-1-1.

## Acceptance Criteria

- `Consumer` is an immutable widget.
- It accepts a `ProviderListenable<T>` and a builder `(TuiContext, T) => Widget`.
- It compiles to a node by reading the provider and evaluating the builder.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Create `lib/src/view/components/consumer.dart`. Define `class Consumer<T> extends Widget` with fields for the provider and builder. In `compile`, read the provider from the supplied `TuiContext`, call `builder(context, value)` to obtain a child widget, and compile that child into a node. Store the child node as the consumer node's only child. The builder signature can mirror Flutter's `Consumer` or be adapted to accept `TuiContext`.

## Why

`Consumer` is the canonical pattern for provider-driven UI. It keeps widgets pure functions of provider state and avoids manual subscription management in application code.
