# task-0-2-1

## Identity

| Field        | Value                          |
|--------------|--------------------------------|
| Type         | Task                           |
| Title        | Create directory skeleton      |
| Parent Story | task-0-2                       |

## Objective

Create the `lib/src/` directory skeleton defined in Section 4 of the refined specification.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/engine/`: create directory and `.gitkeep`.
- `lib/src/models/`: create directory and `.gitkeep`.
- `lib/src/async_value/`: create directory and `.gitkeep`.
- `lib/src/view/`: create directory and `.gitkeep`.
- `lib/src/view/components/`: create directory and `.gitkeep`.
- `lib/src/io/`: create directory and `.gitkeep`.

Out of scope (to be handled in later tasks):

- Creating Dart source files in any of these directories.
- Implementing the classes that will eventually live here.
- Modifying `lib/t22e.dart` to export anything.

## API References

- Dart API: https://dart.dev/tools/pub/package-layout
- Package API: not applicable

## Acceptance Criteria

- All directories from the refined specification exist under `lib/src/`.
- Each leaf directory contains a `.gitkeep` file so it is tracked by git.
- No unintended files or directories are created.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Use shell commands or the IDE to create the directory tree. Add a `.gitkeep` file to every leaf directory. Avoid creating placeholder `.dart` files unless the analyzer requires them; the intent is to preserve structure without introducing implementation.

## Why

A well-defined source layout communicates the framework's architecture to contributors and tooling. Creating the skeleton now lets later milestones add files in the correct locations without restructuring.
