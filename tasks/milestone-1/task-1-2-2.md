# task-1-2-2

## Identity

| Field        | Value         |
|--------------|---------------|
| Type         | Task          |
| Title        | Define TuiSize |
| Parent Story | task-1-2      |

## Objective

Define the immutable integer size type used for terminal-cell dimensions.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/models/geometry.dart`:
  - Define `TuiSize` as a Freezed object with integer `width` and `height` fields.
  - Provide a `const TuiSize.zero()` factory.
  - Add helpers such as `constrain(TuiSize other)` or `isEmpty` if useful.

Out of scope (to be handled in later tasks):

- `TuiRect` definition.
- Layout pass or constraint integration.

## API References

- Dart API: https://dart.dev/language/classes
- Package API: https://pub.dev/packages/freezed

## Acceptance Criteria

- `TuiSize` is Freezed-generated and supports const construction and value equality.
- `TuiSize.zero` is available and tested.
- Any convenience accessors/helpers are unit tested.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Add a `@freezed` class with `width` and `height` integer fields. Use a redirecting factory for `TuiSize.zero()`. Add simple helpers like `isEmpty` (`width == 0 || height == 0`) and `constrain` to clamp to another size, matching patterns expected by the simplified layout pass.

## Why

`TuiSize` describes terminal dimensions and widget bounds. Establishing it early lets `TuiRect` and `Constraints` build on a single size primitive.
