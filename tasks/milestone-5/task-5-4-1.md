# task-5-4-1

## Identity

| Field        | Value                |
|--------------|----------------------|
| Type         | Task                 |
| Title        | Define TuiContext Class |
| Parent Story | task-5-4             |

## Objective

Create the `TuiContext` class that wraps provider access for the build pass.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/view/context.dart`:
  - Define a `TuiContext` class.
  - Store a reference to a Riverpod `ProviderContainer` or equivalent.
  - Expose a typed `read` method.

Out of scope (to be handled in later tasks):

- `watch`/`listen` rebuild semantics.
- Provider overrides or scoping.
- Passing the context through the node tree.

## API References

- Riverpod: https://riverpod.dev/docs/concepts/providers#reading-a-provider
- Dart API: https://api.dart.dev/stable/dart-core/Object-class.html

## Acceptance Criteria

- `TuiContext` is defined and immutable.
- It exposes a `read(ProviderListenable<T>)` method returning `T`.
- It delegates reads to the underlying provider container.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Create `lib/src/view/context.dart`. Define `class TuiContext` with a final `ProviderContainer container` field and a constructor that accepts it. Add a method `T read<T>(ProviderListenable<T> provider) => container.read(provider);`. If the project uses a custom provider store instead of `ProviderContainer`, adapt the field and method names accordingly. Keep the context a thin, testable wrapper.

## Why

`TuiContext` decouples widgets from direct provider-container imports and gives the framework a single place to add build-time services later (e.g., theme, focus, screen size).
