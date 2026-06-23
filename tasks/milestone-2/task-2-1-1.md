# task-2-1-1

## Identity

| Field        | Value                              |
|--------------|------------------------------------|
| Type         | Task                               |
| Title        | Define AsyncValue Sealed Type      |
| Parent Story | task-2-1                           |

## Objective

Define the sealed `AsyncValue<T>` class and its three variants: `AsyncData<T>`, `AsyncLoading<T>`, and `AsyncError<T>`.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/async_value/async_value.dart`:
  - Define `AsyncValue<T>` as a sealed base class.
  - Define `AsyncData<T>` holding a required `T value`.
  - Define `AsyncLoading<T>` as a state with no data.
  - Define `AsyncError<T>` holding a required `Object error` and optional `StackTrace? stackTrace`.
  - Implement `operator ==` and `hashCode` using `Object.hash`/`deepCollectionEquality` where appropriate.

Out of scope (to be handled in later tasks):

- Transformation helpers (`when`, `map`, etc.).
- `StreamValueNotifier<T>` implementation.
- Riverpod integration or provider wrappers.

## API References

- Dart API: https://dart.dev/language/class-modifiers#sealed
- Dart API: https://api.dart.dev/stable/dart-core/Object/hash.html
- Reference API: https://pub.dev/documentation/riverpod/latest/riverpod/AsyncValue-class.html

## Acceptance Criteria

- `AsyncValue<T>` is sealed and cannot be instantiated directly.
- Each variant can be constructed and holds the correct fields.
- Equality and hash code behave correctly across all variants, including nested values.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Use Dart's `sealed` class modifier with a private constructor on `AsyncValue<T>`. Make each variant `final` and immutable. Override `==` and `hashCode` for value equality; consider `DeepCollectionEquality` only when `T` may be a collection. Keep the file dependency-free except for `package:meta` if `@immutable` is desired and `package:collection` if deep equality is used.

## Why

The three-state `AsyncValue` model is the foundation of the bridge. Getting its shape, immutability, and equality correct first makes the `StreamValueNotifier` and downstream ViewModel logic straightforward and predictable.
