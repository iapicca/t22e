# task-0-3-1

## Identity

| Field        | Value                          |
|--------------|--------------------------------|
| Type         | Task                           |
| Title        | Create lib/t22e.dart           |
| Parent Story | task-0-3                       |

## Objective

Create the unified public API export barrel `lib/t22e.dart`.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/t22e.dart`: create the public barrel file with a library documentation comment.

Out of scope (to be handled in later tasks):

- Exporting any engine, model, or widget symbols.
- Marking exports as `@internal`.
- Adding code beyond the barrel file itself.

## API References

- Dart API: https://dart.dev/tools/pub/package-layout
- Package API: not applicable

## Acceptance Criteria

- `lib/t22e.dart` exists at the package root.
- The file contains a library doc comment describing the package's purpose and public API convention.
- The file passes static analysis.
- No internal `src/` files are exported.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Write the barrel file by hand. Include a comment explaining that `package:t22e/t22e.dart` is the intended public import and that direct imports of `src/` files are unsupported. Do not add `export` directives yet; they will be added as public classes and providers are implemented in subsequent milestones.

## Why

The barrel file is the public face of the package. Creating it now establishes the import convention and prepares the package for later public API additions without requiring importers to change their import statements.
