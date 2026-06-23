# task-2-2-2

## Identity

| Field        | Value                              |
|--------------|------------------------------------|
| Type         | Task                               |
| Title        | Lifecycle and Listener Management  |
| Parent Story | task-2-2                           |

## Objective

Ensure `StreamValueNotifier<T>` can be safely used inside Riverpod providers by finalizing its lifecycle, listener cleanup, and edge-case behavior.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/async_value/stream_notifier.dart`:
  - Guard `dispose()` so it is idempotent (safe to call multiple times).
  - Ensure pending listeners on the `ValueNotifier` are dropped after disposal.
  - Optionally expose `bool get isDisposed` for diagnostics.
  - Ensure the subscription is not recreated if `dispose()` is called before any listener attaches.

Out of scope (to be handled in later tasks):

- Provider-level caching or auto-dispose policies.
- Integration with actual stdin streams.

## API References

- Dart API: https://api.dart.dev/stable/dart-async/StreamSubscription/cancel.html
- Dart API: https://api.dart.dev/stable/dart-foundation/ChangeNotifier/dispose.html

## Acceptance Criteria

- Calling `dispose()` more than once does not throw or cancel a null subscription.
- After disposal, the notifier no longer accepts updates from the stream.
- `isDisposed` (if provided) reflects the disposal state accurately.
- Unit tests cover disposal idempotency and post-disposal stream event handling.
- All new code follows the existing project style and passes static analysis.

## How

Track disposal with a private boolean. In `dispose()`, check the flag and return early if already disposed. Set the flag before canceling the subscription and disposing the notifier. In the `onData`/`onError` callbacks, short-circuit if disposed to prevent updates after cleanup. Keep the implementation simple and avoid over-engineering with pause/resume features.

## Why

Riverpod providers create and destroy objects as widgets come and go. A bridge that leaks subscriptions or crashes on double-disposal will cause flaky tests and runtime errors. Finalizing lifecycle behavior now prevents a class of bugs once the bridge is wired into the provider graph.
