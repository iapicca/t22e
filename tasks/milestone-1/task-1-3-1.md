# task-1-3-1

## Identity

| Field        | Value                         |
|--------------|-------------------------------|
| Type         | Task                          |
| Title        | Define Freezed Constraints Record |
| Parent Story | task-1-3                      |

## Objective

Define the immutable `Constraints` record that represents the bounding box of sizes a widget may occupy.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/models/constraints.dart`:
  - Define `Constraints` as a Freezed object with integer fields:
    - `minWidth`, `maxWidth`, `minHeight`, `maxHeight`
  - Provide factory constructors:
    - `Constraints.tight(TuiSize size)` → min and max equal to the given size.
    - `Constraints.loose(TuiSize size)` → min 0, max equal to the given size.
  - Provide a `TuiSize constrain(TuiSize size)` method that clamps width and height to the constraint range.
  - Provide a `bool get isTight` getter where min == max for both axes.

Out of scope (to be handled in later tasks):

- Layout pass integration.
- Constraint propagation through a widget tree.
- Non-box constraints or flexible sizing.

## API References

- Dart API: https://dart.dev/language/classes
- Package API: https://pub.dev/packages/freezed

## Acceptance Criteria

- `Constraints` is Freezed-generated and supports const construction and value equality.
- `tight` and `loose` factories produce the expected min/max values.
- `constrain` clamps width and height independently and respects minima.
- `isTight` returns true only when both axes are tight.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Use a `@freezed` class with four integer fields. Implement factories and `constrain` as pure, side-effect-free operations. Keep the type simple and predictable so future layout code can rely on it without surprises.

## Why

`Constraints` is the data contract between the layout pass and widgets. A well-defined constraints type lets parents describe available space unambiguously and lets children report a size that respects those limits.
