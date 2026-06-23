# task-2-2-1

## Identity

| Field        | Value                              |
|--------------|------------------------------------|
| Type         | Task                               |
| Title        | Implement StreamValueNotifier Core |
| Parent Story | task-2-2                           |

## Objective

Implement the core `StreamValueNotifier<T>` class that listens to a stream and exposes its state as a `ValueNotifier<AsyncValue<T>>`.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/async_value/stream_notifier.dart`:
  - Define `StreamValueNotifier<T>` with a constructor that accepts a `Stream<T>`.
  - Hold a private `ValueNotifier<AsyncValue<T>>` initialized to `AsyncLoading`.
  - Subscribe to the stream and update the notifier:
    - `onData` -> `AsyncValue<T>.data(event)`
    - `onError` -> `AsyncValue<T>.error(error, stackTrace)`
  - Expose the notifier via a `ValueNotifier<AsyncValue<T>> get notifier` getter.
  - Provide `dispose()` to cancel the subscription and dispose the notifier.

Out of scope (to be handled in later tasks):

- Error recovery or retry logic.
- Pause/resume behavior on the subscription.
- Riverpod provider wrappers.

## API References

- Dart API: https://api.dart.dev/stable/dart-async/StreamSubscription-class.html
- Dart API: https://api.dart.dev/stable/dart-foundation/ValueNotifier-class.html
- Package API: https://pub.dev/packages/riverpod (for behavioral reference)

## Acceptance Criteria

- `StreamValueNotifier<T>` can be constructed with any `Stream<T>`.
- The notifier starts at `AsyncLoading`.
- Each stream event synchronously updates the notifier to `AsyncData<T>` with the event value.
- Stream errors synchronously update the notifier to `AsyncError<T>`.
- `dispose()` cancels the subscription and disposes the notifier without throwing.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Store the subscription obtained from `stream.listen(...)`. In the `onData` and `onError` callbacks, assign a new `AsyncValue` to `notifier.value`. Keep the class `final`/`immutable` in intent even though it manages mutable subscription state. Avoid exposing the subscription directly; only expose `dispose()` and the notifier getter.

## Why

The core bridge object is the minimal unit needed to turn any `Stream<T>` into a synchronous `ValueNotifier`. By implementing it first, later tasks can focus on provider integration and lifecycle concerns without reimplementing the subscription logic.
