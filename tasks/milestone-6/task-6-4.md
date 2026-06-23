# task-6-4

## Identity

| Field          | Value                                  |
|----------------|----------------------------------------|
| Type           | Story                                  |
| Title          | Update Public Barrel Exports           |
| Parent Feature | task-6                                 |
| Children Tasks | task-6-4-1, task-6-4-2, task-6-4-3     |

## Logical Flow

`lib/t22e.dart` is the single supported entry point for application developers. This story audits all `lib/src/` exports, keeps only the public contract in the barrel, and verifies that no internal symbol leaks accidentally.

```mermaid
graph TD
    A[lib/src/] -->|audit| B[Public vs Internal]
    B --> C[lib/t22e.dart]
    C --> D[Application Import]
    B -->|@internal| E[Direct src/ imports unsupported]
```

## Objective

Update `lib/t22e.dart` to export exactly the public API needed for the first-phase deliverable.

## Scope Boundary

- Deliverable this story introduces:
  - Cleaned public exports from `lib/t22e.dart`.
  - Removal of accidental internal re-exports.
  - Verification that the smoke test and public provider API compile through the barrel.

Out of scope (to be handled in child tasks):

- Generating API documentation.
- Creating a separate `internal.dart` barrel.
- Reorganizing source files.

## Acceptance Criteria

- All children tasks are completed and accepted.
- `lib/t22e.dart` exports only the intended public symbols.
- No `@internal` class or function is re-exported from the public barrel.
- The smoke test imports only `package:t22e/t22e.dart` and compiles successfully.
- Static analysis passes without export-related warnings.

## How

Review every `export` directive in `lib/t22e.dart` and compare it against the public API decisions made in task-6-1 and task-6-2. Remove exports of files or symbols that are now marked `@internal`. Ensure that public widgets, providers, models, and the `AsyncValue` clone are available. Run `dart analyze` and the smoke test to confirm the barrel is correct.

## Why

A clean public barrel is the boundary between supported usage and unsupported internal imports. Finalizing it now prevents accidental coupling to engine internals and establishes the import contract for all future milestones.
