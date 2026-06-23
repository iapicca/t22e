# task-4-2-1

## Identity

| Field        | Value                                    |
|--------------|------------------------------------------|
| Type         | Task                                     |
| Title        | Define Input Event Types and Tokenizer   |
| Parent Story | task-4-2                                 |

## Objective

Establish the typed input event model and a byte tokenizer that splits raw input into recognizable ANSI/VT100 tokens.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/io/ansi_parser.dart`:
  - Define a sealed `InputEvent` class and concrete subtypes such as `CharEvent`, `KeyEvent`, and `UnknownEvent`.
  - Define a `Key` enum or constants for recognized keys (arrows, enter, escape, etc.).
  - Implement a tokenizer that scans a `List<int>` and produces tokens: plain character run, escape sequence, or control character.

Out of scope (to be handled in later tasks):

- Stateful parser that reassembles split sequences across chunk boundaries.
- Mapping every possible CSI sequence.
- Mouse or focus events.

## API References

- Dart API: https://api.dart.dev/stable/dart-core/String-class.html
- Dart API: https://api.dart.dev/stable/dart-core/List-class.html
- ANSI escape codes: https://en.wikipedia.org/wiki/ANSI_escape_code

## Acceptance Criteria

- Event classes are immutable and equality-comparable.
- The tokenizer correctly identifies the start of an escape sequence (`0x1B`) and consumes until a recognized final byte.
- Plain printable bytes are emitted as character tokens.
- Common control bytes (e.g., `0x0D`, `0x7F`) are emitted as control tokens.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Create a small tokenizer function that walks the byte list. When it sees `0x1B`, it attempts to read a CSI sequence (`ESC [` followed by parameter bytes and a final letter) or a simple two-byte sequence. Otherwise, group consecutive printable bytes into a character token and emit individual control bytes. Keep the token model private to the parser file so the public API remains the typed event stream.

## Why

Splitting byte recognition from parser state management lets each part be tested independently. The tokenizer handles the shape of escape sequences, while the parser state machine handles chunk boundaries and sequence-to-event mapping.
