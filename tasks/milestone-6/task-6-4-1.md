# task-6-4-1

## Identity

| Field        | Value                                |
|--------------|--------------------------------------|
| Type         | Task                                 |
| Title        | Audit Current Barrel Exports         |
| Parent Story | task-6-4                             |

## Objective

Review `lib/t22e.dart` and produce a definitive list of public exports matching the first-phase API.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/t22e.dart`:
  - List every current `export` directive.
  - Mark each export as keep, remove, or split (public part vs internal part).
- Cross-reference with task-6-1-1 public provider audit and task-6-2 `@internal` annotations.

Out of scope (to be handled in later tasks):

- Actually editing `lib/t22e.dart`.
- Moving or renaming source files.

## API References

- Dart `export` directive: https://dart.dev/language/libraries#exporting

## Acceptance Criteria

- A written audit exists showing every current export and its intended disposition.
- Every symbol kept in the barrel is either a public widget, public provider, public model, or the public `AsyncValue` type.
- Every symbol removed is either marked `@internal` or explicitly out of scope for the first phase.
- The audit is approved or accepted before task-6-4-2 begins.

## How

Open `lib/t22e.dart` and read every `export` line. For each exported file, determine which symbols it contains and whether those symbols should be public based on task-6-1 and task-6-2. Document the decision. If a file mixes public and internal symbols, note that it needs a split or selective re-export in task-6-4-2.

## Why

The public barrel is the most visible API boundary. Auditing before editing prevents accidental removal of public symbols and ensures the cleanup is intentional.
