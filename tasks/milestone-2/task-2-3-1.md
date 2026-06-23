# task-2-3-1

## Identity

| Field        | Value                              |
|--------------|------------------------------------|
| Type         | Task                               |
| Title        | Create Riverpod Provider Helpers   |
| Parent Story | task-2-3                           |

## Objective

Create the Riverpod provider wrappers that expose a stream-backed `AsyncValue<T>` to ViewModels.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/async_value/provider_bridge.dart` (or equivalent):
  - Define a factory function/provider builder that accepts a `Stream<T>` and returns a `StreamValueNotifier<T>`.
  - Expose a provider pattern that watches the notifier and yields `AsyncValue<T>`.
  - Use Riverpod's `Provider`/`StateProvider`/`AsyncNotifier` as appropriate for the chosen design.
  - Ensure the `StreamValueNotifier` is disposed when the provider is disposed.

- `lib/src/async_value/async_value.dart` and `lib/src/async_value/stream_notifier.dart`:
  - Apply any minor changes needed for public API cleanliness (e.g., `@internal` markers on engine-only members, if any).

Out of scope (to be handled in later tasks):

- Widget `Consumer` integration.
- Provider families or overrides for terminal-specific streams.
- Barrel export updates (covered in task-2-3-2).

## API References

- Package API: https://pub.dev/documentation/riverpod/latest/riverpod/Provider-class.html
- Package API: https://pub.dev/documentation/riverpod/latest/riverpod/StateProvider-class.html
- Package API: https://pub.dev/documentation/riverpod/latest/riverpod/AsyncNotifier-class.html

## Acceptance Criteria

- A provider can be created from a `Stream<T>` and exposes the current `AsyncValue<T>`.
- The `StreamValueNotifier` is created lazily and disposed when the provider is destroyed.
- ViewModels can `watch` the provider and receive synchronous updates on stream events.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Choose the simplest Riverpod primitive that fits the synchronous bridge model. One option is a `Provider<StreamValueNotifier<T>>` whose `dispose` calls the notifier's `dispose`, plus a dependent `Provider<AsyncValue<T>>` that reads `notifier.value` via `select` or a listenable. Another option is an `AsyncNotifier` subclass. Pick the approach that minimizes code and matches the framework's provider-driven public API conventions.

## Why

Provider helpers are the public face of the state bridge. They let ViewModels treat stream events as standard provider state, keeping the framework's API consistent and reducing the risk of memory leaks from manual subscription management.
