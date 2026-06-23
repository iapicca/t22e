# task-6-2-3

## Identity

| Field        | Value                                      |
|--------------|--------------------------------------------|
| Type         | Task                                       |
| Title        | Audit and Annotate Remaining Internal Symbols |
| Parent Story | task-6-2                                   |

## Objective

Review `lib/src/models/`, `lib/src/async_value/`, and internal helpers in `lib/src/view/` and apply `@internal` where appropriate.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/models/constraints.dart` and `lib/src/models/geometry.dart`:
  - Mark internal geometry/constraint types as `@internal` unless intentionally public.
- `lib/src/async_value/async_value.dart` and `lib/src/async_value/stream_notifier.dart`:
  - Mark the `AsyncValue` clone and `StreamValueNotifier` as `@internal` if they are not exported publicly.
- `lib/src/view/widget.dart`, `lib/src/view/context.dart`, and `lib/src/view/components/`:
  - Mark internal base classes or node types as `@internal`; leave public widgets (`Text`, `Consumer`, root widget) unannotated.

Out of scope (to be handled in later tasks):

- Re-annotating symbols already covered in task-6-2-1 or task-6-2-2.
- Moving files between directories.

## API References

- `package:meta` `@internal`: https://pub.dev/documentation/meta/latest/meta/internal-constant.html

## Acceptance Criteria

- All internal models, async value helpers, and view-layer internals are reviewed.
- `@internal` is applied consistently to symbols that are not re-exported publicly.
- No public widget or public model is accidentally hidden.
- Static analysis passes and all tests compile.

## How

Walk through the remaining `lib/src/` subdirectories file by file. Compare each symbol against the public API inventory from task-6-1-1 and the planned `lib/t22e.dart` exports. Annotate internals, leave publics untouched, and run `dart analyze` to catch any unintended visibility changes.

## Why

Engine and I/O classes are only part of the internal surface. Models, async value clones, and node abstractions also need visibility markers so the public API boundary is complete and consistent.
