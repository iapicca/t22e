# task-1-2-1

## Identity

| Field        | Value         |
|--------------|---------------|
| Type         | Task          |
| Title        | Define TuiOffset |
| Parent Story | task-1-2      |

## Objective

Define the immutable integer offset type used for terminal-cell positions.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/models/geometry.dart`:
  - Define `TuiOffset` as a Freezed object with integer `dx` and `dy` fields.
  - Provide a `const TuiOffset.zero()` factory.
  - Add an `operator +` for combining offsets if useful.

Out of scope (to be handled in later tasks):

- `TuiSize` and `TuiRect` definitions.
- Layout or paint integration.

## API References

- Dart API: https://dart.dev/language/operators
- Package API: https://pub.dev/packages/freezed

## Acceptance Criteria

- `TuiOffset` is Freezed-generated and supports const construction and value equality.
- `TuiOffset.zero` is available and tested.
- Offset addition behaves as expected when implemented.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Use a simple `@freezed` class with two named integer parameters. Add `const TuiOffset.zero()` via a redirecting factory. Keep behavior minimal; this is a pure data holder.

## Why

`TuiOffset` is the foundational position type for every rectangle, buffer coordinate, and eventual widget placement. Defining it first keeps the geometry file organized and the size/rect tasks unblocked.
