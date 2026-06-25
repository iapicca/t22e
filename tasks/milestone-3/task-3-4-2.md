# task-3-4-2

## Identity

| Field        | Value                       |
|--------------|-----------------------------|
| Type         | Task                        |
| Title        | Implement ANSI Writer       |
| Parent Story | task-3-4                    |

## Objective

Convert diff operations and cell styles into ANSI escape sequences suitable for terminal output.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/engine/ansi_writer.dart`:
  - Generate CSI cursor positioning sequences from `(x, y)` coordinates.
  - Generate SGR sequences from `Cell` style flags (bold, dim, italic, underline, etc.) and foreground/background colors.
  - Maintain an active style state to avoid redundant SGR resets.
  - Build the final ANSI byte string from a list of diff operations.

- `lib/src/engine/cell.dart`:
  - Ensure `Cell` exposes the style and color fields needed by the writer.

Out of scope (to be handled in later tasks):

- Writing the generated string to stdout.
- Terminal capability detection or 256/true-color support.
- Complex color space conversions.

## API References

- ANSI CSI: https://en.wikipedia.org/wiki/ANSI_escape_code#CSI_sequences
- ANSI SGR: https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_(Select_Graphic_Rendition)_parameters
- Dart API: https://api.dart.dev/stable/dart-core/StringBuffer-class.html

## Acceptance Criteria

- Cursor positioning produces the correct `CSI row;colH` sequence (1-indexed).
- Style changes produce valid SGR sequences based on `Cell` flags and colors.
- A reset sequence is emitted when transitioning from styled to default text.
- The writer builds a single ANSI string from a list of diff operations.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Implement `AnsiWriter` with a method `String write(List<DiffOp> ops, Size size)`. Maintain mutable state for the active foreground, background, and style flags. For each operation, append the appropriate escape sequence: cursor moves use `\x1B[{y+1};{x+1}H`; style changes compute the SGR parameter list from the cell's style and colors, emitting `\x1B[{params}m`; write operations append the cell character directly. When the active style changes to default, emit the reset sequence `\x1B[0m`. Keep color support limited to the 16 standard ANSI colors in this task.

## Why

The ANSI writer translates logical cell changes into the actual bytes a terminal understands. Isolating it from the diff engine keeps each component testable and makes it straightforward to extend color support or cursor commands later.
