# task-4-2-2

## Identity

| Field        | Value                               |
|--------------|-------------------------------------|
| Type         | Task                                |
| Title        | Implement ANSI Parser State Machine |
| Parent Story | task-4-2                            |

## Objective

Implement the parser state machine that consumes byte tokens across chunk boundaries and emits `InputEvent` objects on a stream.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/io/ansi_parser.dart`:
  - `AnsiParser` class exposing `Stream<InputEvent> get events`.
  - Internal state machine that buffers incomplete sequences between `add` calls.
  - Mapping of completed tokens to `InputEvent` instances.
  - Flushing the buffer on stream completion.

Out of scope (to be handled in later tasks):

- `StdinReader` implementation details.
- Mouse, focus, or resize events.
- Full UTF-8 multi-byte decoding beyond single-code-unit characters handled by the tokenizer.

## API References

- Dart API: https://api.dart.dev/stable/dart-async/StreamController-class.html
- Dart API: https://api.dart.dev/stable/dart-core/List-class.html
- ANSI CSI sequences: https://en.wikipedia.org/wiki/ANSI_escape_code#CSI_sequences

## Acceptance Criteria

- The parser emits `CharEvent` for plain characters.
- Arrow keys and common CSI sequences map to `KeyEvent`.
- Incomplete escape sequences at the end of a chunk are held until the next chunk or completion.
- Invalid or unrecognized sequences are emitted as `UnknownEvent` with raw bytes.
- The parser stream closes when `close()` is called.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Create a `StreamController<InputEvent>` and an internal byte buffer. Provide an `add(List<int> bytes)` method that appends to the buffer, then repeatedly calls the tokenizer. When a token is complete, map it to an event and add it to the controller. If the buffer ends mid-sequence, leave it for the next `add`. On `close()`, flush any remaining plain bytes as events and close the controller. Use a simple enum for parser state (`ground`, `escape`, `csi`) to avoid complexity.

## Why

The state machine turns byte chunks into a reliable stream of typed events. Buffering incomplete sequences is essential because `stdin` may deliver a single escape sequence split across multiple OS reads.
