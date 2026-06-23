# task-6-4-2

## Identity

| Field        | Value                                |
|--------------|--------------------------------------|
| Type         | Task                                 |
| Title        | Update lib/t22e.dart Barrel          |
| Parent Story | task-6-4                             |

## Objective

Apply the export cleanup decided in task-6-4-1 and update `lib/t22e.dart` to export only the public API.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/t22e.dart`:
  - Remove exports of files whose symbols are now `@internal`.
  - Add exports for new public providers from task-6-1-2.
  - Use `show` clauses where a file mixes public and internal symbols.

Out of scope (to be handled in later tasks):

- Creating a separate internal barrel.
- Reorganizing source files to separate public and internal symbols.

## API References

- Dart `export` directive: https://dart.dev/language/libraries#exporting
- Dart `show` combinator: https://dart.dev/language/libraries#importing-only-part-of-a-library

## Acceptance Criteria

- `lib/t22e.dart` exports only the intended public symbols.
- No `@internal` class or function is re-exported from the public barrel.
- New public providers and widgets are exported.
- Static analysis passes with no export-related warnings.

## How

Edit `lib/t22e.dart` according to the audit from task-6-4-1. Replace broad file exports with `show` clauses when a file contains both public and internal symbols, or remove the export entirely if the file is wholly internal. Add `export` directives for `lib/src/providers.dart` or other new public surfaces. Run `dart analyze` to verify the barrel compiles cleanly.

## Why

This task finalizes the import contract. A clean barrel is what application developers see when they `import 'package:t22e/t22e.dart';`, so it must match the supported public surface exactly.
