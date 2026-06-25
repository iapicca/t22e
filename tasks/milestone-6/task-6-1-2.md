# task-6-1-2

## Identity

| Field        | Value                                    |
|--------------|------------------------------------------|
| Type         | Task                                     |
| Title        | Define Public Providers                  |
| Parent Story | task-6-1                                 |

## Objective

Implement the public Riverpod providers identified in task-6-1-1.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/providers.dart` (new file) or appropriate existing `lib/src/view/` files:
  - Define public providers for terminal input events, terminal size, and `TuiContext` access.
  - Keep each provider as a thin wrapper around the existing engine classes.
- `lib/t22e.dart`:
  - Re-export the new public provider symbols.

Out of scope (to be handled in later tasks):

- Provider families, scoped overrides, or selective rebuild optimizations.
- Internal provider wiring changes inside the engine.

## API References

- Riverpod `Provider`: https://riverpod.dev/docs/providers/provider
- Riverpod `StateProvider`: https://riverpod.dev/docs/providers/state_provider
- Riverpod `StreamProvider`: https://riverpod.dev/docs/providers/stream_provider

## Acceptance Criteria

- Public providers compile without errors.
- Each provider returns or exposes the expected framework service.
- The providers can be read from a `ProviderContainer` and from `TuiContext`.
- `Consumer` widgets rebuild when watched provider values change.
- `lib/t22e.dart` re-exports the new provider symbols.
- Static analysis passes.

## How

Create `lib/src/providers.dart` if it does not exist, or add the public providers to the most natural existing file (for example, `TuiContext` providers belong near `lib/src/view/context.dart`). Use standard Riverpod provider types such as `Provider`, `StateProvider`, or `StreamProvider` as appropriate. Each provider should construct or obtain its underlying service from the internal engine classes rather than duplicating logic. Export the new symbols from `lib/t22e.dart`.

## Why

Public providers are the contract between the framework and application developers. Defining them explicitly makes the supported entry points discoverable and lets the rest of the codebase be treated as internal implementation detail.
