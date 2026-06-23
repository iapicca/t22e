# task-5-4

## Identity

| Field          | Value                       |
|----------------|-----------------------------|
| Type           | Story                       |
| Title          | TuiContext and Provider Access |
| Parent Feature | task-5                      |
| Children Tasks | task-5-4-1, task-5-4-2, task-5-4-3 |

## Logical Flow

The build pass must allow widgets to read Riverpod providers. A `TuiContext` object wraps the provider container and is passed down the widget tree. Widgets use it to read model snapshots and compile provider-driven nodes.

```mermaid
graph TD
    A[ProviderContainer] --> B[TuiContext]
    B --> C[Build Pass]
    C --> D[Widget.read(provider)]
    D --> E[Model Snapshot]
    E --> F[Compiled Node]
```

## Objective

Create a `TuiContext` that exposes provider access during the widget build pass.

## Scope Boundary

- Deliverable this story introduces:
  - `TuiContext` class in `lib/src/view/context.dart`.
  - Bridge to the Riverpod `ProviderContainer` or equivalent provider store.
  - Mechanism to pass the context through the build pass.
  - Read-only provider access for widgets.

Out of scope (to be handled in child tasks):

- Watch/listen semantics and automatic rebuild registration.
- Provider override or scoping inside subtrees.
- Direct Riverpod `StateController` mutations from widgets.

## Acceptance Criteria

- All children tasks are completed and accepted.
- `TuiContext` can read any provider from the underlying container.
- The context is available throughout the build pass.
- Widgets that read providers receive the current snapshot value.
- Unit tests verify provider reads through a fake or real container.

## How

Define `TuiContext` as a thin wrapper around a Riverpod `ProviderContainer`. Expose a `read(ProviderListenable<T>)` method that delegates to the container. Pass the context as a parameter to the widget build/compile method and store it on the resulting node so descendant widgets can reuse it. Keep the API read-only for now; `watch` behavior is implemented later via `Consumer` and frame invalidation.

## Why

Provider access is the primary way application state reaches the view layer. Encapsulating it in `TuiContext` keeps widgets testable and avoids leaking the provider container into every widget constructor.
