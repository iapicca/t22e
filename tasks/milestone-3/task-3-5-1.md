# task-3-5-1

## Identity

| Field        | Value                              |
|--------------|------------------------------------|
| Type         | Task                               |
| Title        | Integrate Pipeline and Stdout Writer |
| Parent Story | task-3-5                           |

## Objective

Orchestrate the full render pipeline and flush the generated ANSI output to `dart:io` stdout.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/engine/stdout_writer.dart`:
  - Define a `StdoutWriter` class wrapping `dart:io` stdout.
  - Provide a `write(String ansi)` method that appends to the sink and flushes.
  - Accept an `IOSink` in the constructor to allow test injection.

- `lib/src/engine/pipeline.dart`:
  - Define a `Pipeline` class that owns the buffers, `AnsiWriter`, and `StdoutWriter`.
  - Implement `void render(Widget root, TuiSize size)` or similar that runs:
    1. Build pass from `root` to root `Node`.
    2. Layout pass with terminal-size constraints.
    3. Paint pass into a fresh target `CellBuffer`.
    4. Diff pass against the current buffer.
    5. ANSI generation and stdout flush.
    6. Copy target buffer into current buffer.

- `lib/src/engine/scheduler.dart`:
  - Define a simple `Scheduler` that accepts frame requests and invokes a callback.
  - For this milestone, a synchronous or microtask-based scheduler is sufficient.

Out of scope (to be handled in later tasks):

- Reading stdin or parsing ANSI input events.
- Frame throttling or vsync timing.
- Real provider-driven state invalidation.

## API References

- Dart API: https://api.dart.dev/stable/dart-io/Stdout-class.html
- Dart API: https://api.dart.dev/stable/dart-io/IOSink-class.html
- Existing types: `lib/src/engine/cell_buffer.dart`, `lib/src/engine/diff_engine.dart`, `lib/src/engine/ansi_writer.dart`

## Acceptance Criteria

- `StdoutWriter` writes and flushes an ANSI string to the provided `IOSink`.
- `Pipeline.render` executes build, layout, paint, diff, ANSI generation, and flush in order.
- After rendering, the current buffer matches the target buffer.
- `Scheduler` can request a frame and invoke a callback.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Implement `StdoutWriter` as a thin wrapper around an `IOSink` (defaulting to `stdout`). `Pipeline` constructs the target and current buffers, `AnsiWriter`, and `StdoutWriter`. In `render`, it creates a `TuiContext`, runs the build step, calls `layout` on the root node, creates a target buffer of the given size and calls `paint`, runs the diff engine to produce operations, converts them to an ANSI string, writes the string via `StdoutWriter`, and finally copies the target buffer values into the current buffer. `Scheduler` holds a queue of frame callbacks and drains them using `scheduleMicrotask` or a simple loop.

## Why

Pipeline integration is the last piece of the rendering engine. It turns the individual passes from a collection of components into a working system that can render widgets to the terminal, which is the central deliverable of Milestone 3.
