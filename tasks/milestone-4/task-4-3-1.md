# task-4-3-1

## Identity

| Field        | Value                  |
|--------------|------------------------|
| Type         | Task                   |
| Title        | Implement StdoutWriter |
| Parent Story | task-4-3               |

## Objective

Implement the `StdoutWriter` that writes ANSI output to `dart:io` `stdout` and flushes it.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/io/stdout_writer.dart`:
  - Define a `StdoutWriter` class with an injectable `IOSink`.
  - Provide a `write(String output)` method that writes and flushes.
  - Handle errors gracefully by surfacing them through the sink's future.

Out of scope (to be handled in later tasks):

- ANSI sequence generation.
- Frame scheduling or throttling.
- Raw mode or alternate buffer commands.

## API References

- Dart API: https://api.dart.dev/stable/dart-io/Stdout-class.html
- Dart API: https://api.dart.dev/stable/dart-io/IOSink-class.html

## Acceptance Criteria

- `StdoutWriter` writes the exact string passed to `write`.
- The sink is flushed immediately after each write.
- The writer can be constructed with a custom `IOSink` for unit testing.
- Errors from the underlying sink are not silently swallowed.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Store the `IOSink` in the constructor (defaulting to `stdout`). In `write`, call `sink.write(output)` followed by `sink.flush()`. Consider returning the flush `Future` so callers can await completion if needed. Do not buffer or split frames; the pipeline already produces minimal updates.

## Why

`StdoutWriter` is the final egress point of the rendering pipeline. By making it injectable, tests can capture output without touching the real terminal, and the engine can remain independent of `dart:io` details.
