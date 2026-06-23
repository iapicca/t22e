# task-1-1-2

## Identity

| Field        | Value                    |
|--------------|--------------------------|
| Type         | Task                     |
| Title        | Define Freezed Cell Record |
| Parent Story | task-1-1                 |

## Objective

Compose the color and style value types into a single immutable `Cell` record that represents one terminal cell.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/engine/cell.dart`:
  - Define `Cell` as a Freezed object with:
    - `String character` (non-null; default to a single space)
    - `TuiColor? foreground` (nullable, null means default terminal color)
    - `TuiColor? background` (nullable, null means default terminal color)
    - `CellStyle style` (default to all flags false)
  - Provide a const factory `Cell.blank()` or equivalent default constructor.

Out of scope (to be handled in later tasks):

- Buffer read/write operations.
- String rendering, ANSI encoding, or character width handling.

## API References

- Dart API: https://dart.dev/language/records (for comparison, not implementation)
- Package API: https://pub.dev/packages/freezed

## Acceptance Criteria

- `Cell` is generated with Freezed and includes `copyWith` and value equality.
- A blank/default cell has character `' '`, null colors, and all style flags false.
- `copyWith` correctly overrides character, colors, and style fields.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Add the `@freezed` class after `TuiColor` and `CellStyle` in the same file. Use a named private constructor or factory pattern for the blank cell. Keep the class uncluttered by avoiding business logic; `Cell` is a pure data holder.

## Why

`Cell` is the atomic unit of every frame the engine will paint and diff. A clean, immutable, equality-comparable definition makes the buffer and diff engine straightforward to implement and reason about.
