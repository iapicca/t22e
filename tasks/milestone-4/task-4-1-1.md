# task-4-1-1

## Identity

| Field        | Value                        |
|--------------|------------------------------|
| Type         | Task                         |
| Title        | Implement StdinReader        |
| Parent Story | task-4-1                     |

## Objective

Implement the `StdinReader` wrapper that exposes `dart:io` `stdin` as an async byte stream.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/io/stdin_reader.dart`:
  - Define a `StdinReader` class that accepts or defaults to `stdin`.
  - Expose a `Stream<List<int>> get bytes` derived from the input source.
  - Provide a `dispose()` method that cancels any active subscription.
  - Handle stream completion so downstream listeners are notified.

Out of scope (to be handled in later tasks):

- ANSI sequence parsing.
- Event typing.
- Raw mode or echo configuration.

## API References

- Dart API: https://api.dart.dev/stable/dart-io/Stdin-class.html
- Dart API: https://api.dart.dev/stable/dart-async/Stream-class.html

## Acceptance Criteria

- `StdinReader.bytes` yields the same byte chunks as the underlying source.
- Disposing the reader cancels the subscription and closes the exposed stream.
- The class works when given a fake `Stream<List<int>>` for unit testing.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Store the source stream and create a subscription that forwards events, errors, and done signals to a private `StreamController<List<int>>`. Expose the controller's stream publicly. On `dispose()`, cancel the subscription and close the controller. Avoid transforming the bytes; leave parsing to `AnsiParser`.

## Why

`StdinReader` is the framework's front door for terminal input. Keeping it trivial makes it reliable and easy to mock, which is essential for deterministic parser and state-bridge tests.
