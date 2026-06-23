# task-6-2-2

## Identity

| Field        | Value                                 |
|--------------|---------------------------------------|
| Type         | Task                                  |
| Title        | Mark Terminal I/O Classes as @internal |
| Parent Story | task-6-2                              |

## Objective

Apply the `@internal` annotation to every class and top-level symbol in `lib/src/io/`.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/io/stdin_reader.dart`:
  - Mark `StdinReader` and helpers as `@internal`.
- `lib/src/io/stdout_writer.dart`:
  - Mark `StdoutWriter` and helpers as `@internal`.
- `lib/src/io/ansi_parser.dart`:
  - Mark the parser, emitted event types if internal, and helper functions as `@internal`.

Out of scope (to be handled in later tasks):

- Public event types that widgets or ViewModels need to observe (verify against task-6-1-1 audit).
- Changes to parser behavior.

## API References

- `package:meta` `@internal`: https://pub.dev/documentation/meta/latest/meta/internal-constant.html

## Acceptance Criteria

- Every class and top-level function in `lib/src/io/` that is not explicitly public is marked `@internal`.
- Any public event type is left unannotated and documented in the task-6-1-1 audit.
- Static analysis passes.
- Existing tests still compile and pass.

## How

Open each file under `lib/src/io/`, import `package:meta/meta.dart`, and annotate internal classes and functions. Pay special attention to event classes: if the public API exposes parsed terminal events (for example, through a `StreamProvider`), the event base type may need to remain public while parser internals stay internal.

## Why

Terminal I/O is explicitly unsupported for direct use in the first phase. `@internal` makes it clear that `StdinReader`, `StdoutWriter`, and the ANSI parser are framework plumbing, not application APIs.
