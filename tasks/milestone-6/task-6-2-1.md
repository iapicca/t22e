# task-6-2-1

## Identity

| Field        | Value                              |
|--------------|------------------------------------|
| Type         | Task                               |
| Title        | Mark Engine Classes as @internal   |
| Parent Story | task-6-2                           |

## Objective

Apply the `@internal` annotation to every non-public class and top-level symbol in `lib/src/engine/`.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/engine/cell.dart`:
  - Mark the immutable `Cell` value type as `@internal` if it is not exported publicly.
- `lib/src/engine/cell_buffer.dart`:
  - Mark `CellBuffer` and helper functions as `@internal`.
- `lib/src/engine/diff_engine.dart`:
  - Mark the diff engine class and functions as `@internal`.
- `lib/src/engine/pipeline.dart`:
  - Mark the render pipeline class and functions as `@internal`.
- `lib/src/engine/scheduler.dart`:
  - Mark the frame scheduler as `@internal`.
- `lib/src/engine/ansi_writer.dart`:
  - Mark ANSI writer helpers as `@internal`.

Out of scope (to be handled in later tasks):

- Hiding symbols that are intentionally public (for example, color/style enums if exposed).
- Rewriting engine logic.

## API References

- `package:meta` `@internal`: https://pub.dev/documentation/meta/latest/meta/internal-constant.html

## Acceptance Criteria

- Every class, mixin, and top-level function in `lib/src/engine/` that is not part of the public API is marked `@internal`.
- Imports of `package:meta/meta.dart` are added where needed.
- Static analysis passes without new warnings.
- Existing tests still compile and pass.

## How

Open each file under `lib/src/engine/`, add `import 'package:meta/meta.dart';`, and annotate classes, constructors, and top-level functions with `@internal`. If a symbol is re-exported publicly from `lib/t22e.dart`, leave it unannotated and record it for task-6-4 instead.

## Why

The engine is the largest internal surface of the framework. Marking it `@internal` makes the stability contract explicit and discourages users from coupling to classes that will evolve frequently.
