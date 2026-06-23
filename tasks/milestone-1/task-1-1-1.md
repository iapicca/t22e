# task-1-1-1

## Identity

| Field        | Value                                      |
|--------------|--------------------------------------------|
| Type         | Task                                       |
| Title        | Define Color and Style Flag Value Types  |
| Parent Story | task-1-1                                   |

## Objective

Define the small, immutable value types that describe a terminal cell's color and style flags, matching the ANSI 16 / ANSI 256 / RGB color model used by the reference `ansi` package.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/engine/cell.dart` (or `lib/src/engine/color.dart` if you prefer a separate file):
  - Define `TuiColor` as a sealed/union type supporting:
    - ANSI 16 color index (`ansi16`, index 0-15)
    - ANSI 256 color index (`ansi256`, index 0-255)
    - RGB color (`rgb`, with integer r/g/b components 0-255)
  - Define `CellStyle` as an immutable value type holding flags for `bold`, `italic`, `underline`, and `inverse`.

Out of scope (to be handled in later tasks):

- The `Cell` record itself.
- ANSI escape sequence generation.
- Validation beyond reasonable bounds where non-trivial.

## API References

- Dart API: https://dart.dev/language/class-modifiers#sealed
- Package API: https://pub.dev/packages/freezed
- Reference implementation: https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/color.dart

## Acceptance Criteria

- `TuiColor` supports ANSI 16, ANSI 256, and RGB constructors and is equality-comparable.
- `CellStyle` defaults all flags to `false` and supports `copyWith`.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Use `freezed_annotation` with a `@freezed`/`sealed` union for `TuiColor` so each variant carries exactly the data it needs. Use a single Freezed class for `CellStyle` with named boolean parameters defaulting to `false`. Keep the types const-friendly and avoid runtime validation that is not required for correct in-memory behavior.

## Why

These value types are the building blocks of `Cell`. Defining them first keeps the `Cell` record declaration focused and lets the diff engine rely on structural equality for colors and styles without custom comparison logic.
