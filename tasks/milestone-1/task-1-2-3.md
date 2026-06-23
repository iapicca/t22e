# task-1-2-3

## Identity

| Field        | Value         |
|--------------|---------------|
| Type         | Task          |
| Title        | Define TuiRect |
| Parent Story | task-1-2      |

## Objective

Define the immutable integer rectangle type used for terminal-cell regions.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/models/geometry.dart`:
  - Define `TuiRect` as a Freezed object with `TuiOffset offset` and `TuiSize size` fields.
  - Provide convenience accessors: `left`, `right`, `top`, `bottom`, `width`, `height`.
  - Provide helper methods: `contains(TuiOffset)`, `intersect(TuiRect)`, and a `fromLTWH` factory.

Out of scope (to be handled in later tasks):

- Layout or clipping integration.
- Mutable rectangle variants.

## API References

- Dart API: https://dart.dev/language/classes
- Package API: https://pub.dev/packages/freezed

## Acceptance Criteria

- `TuiRect` is Freezed-generated and supports const construction and value equality.
- `left`/`right`/`top`/`bottom` are computed correctly.
- `contains` and `intersect` handle edge cases (empty intersection, zero-size rect).
- `fromLTWH` factory creates a rect from integer left/top/width/height.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Compose `TuiOffset` and `TuiSize` into a single `@freezed` class. Implement helpers as immutable calculations that return new `TuiRect` or `bool` values. Keep rectangle logic deterministic and free of terminal I/O concerns.

## Why

`TuiRect` represents the bounds of widgets, paint regions, and buffer windows. A solid, tested rectangle primitive simplifies the later layout pass and any clipping the engine may need.
