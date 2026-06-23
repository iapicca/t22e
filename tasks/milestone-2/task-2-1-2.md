# task-2-1-2

## Identity

| Field        | Value                              |
|--------------|------------------------------------|
| Type         | Task                               |
| Title        | Add AsyncValue Transformation Helpers |
| Parent Story | task-2-1                           |

## Objective

Add synchronous transformation helpers to `AsyncValue<T>` so ViewModels and widgets can read the current state in a concise, type-safe way.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/async_value/async_value.dart`:
  - Implement `when<R>({required R Function(T data) data, required R Function(Object error, StackTrace? stackTrace) error, required R Function() loading})`.
  - Implement `maybeWhen<R>({R Function(T data)? data, R Function(Object error, StackTrace? stackTrace)? error, R Function()? loading, required R Function() orElse})`.
  - Implement `map<R>({required R Function(AsyncData<T> data) data, required R Function(AsyncError<T> error) error, required R Function(AsyncLoading<T> loading) loading})`.
  - Implement `maybeMap<R>(...)` as the optional-counterpart to `map`.
  - Add a `hasValue`, `hasError`, and `isLoading` getter if not already present.

Out of scope (to be handled in later tasks):

- Async/`Future`-based helpers such as `whenData` or `future`.
- `copyWith` on variants unless trivially needed.

## API References

- Dart API: https://dart.dev/language/patterns
- Reference API: https://pub.dev/documentation/riverpod/latest/riverpod/AsyncValue-class.html

## Acceptance Criteria

- `when` and `maybeWhen` correctly dispatch to the matching branch for each state.
- `map` and `maybeMap` expose the full variant objects to callbacks.
- `hasValue`, `hasError`, and `isLoading` return the expected booleans.
- All helpers have unit tests covering data, loading, and error inputs.
- All new code follows the existing project style and passes static analysis.

## How

Implement the helpers as synchronous methods on the sealed base class, with each variant overriding to call the appropriate callback. Keep the signatures close to Riverpod's API for familiarity but avoid adding methods the framework does not yet need. Use exhaustive `switch` expressions on `runtimeType` or direct method overrides depending on the chosen sealed-class pattern.

## Why

ViewModels and widgets need a uniform way to branch on `AsyncValue` states. These helpers eliminate boilerplate `if/else` chains and reduce the chance of missing a state transition in the UI layer.
