# task-6-3-3

## Identity

| Field        | Value                                |
|--------------|--------------------------------------|
| Type         | Task                                 |
| Title        | Run and Stabilize Smoke Test         |
| Parent Story | task-6-3                             |

## Objective

Execute the smoke test, diagnose failures, and stabilize it so it passes reliably.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `test/smoke_test.dart`:
  - Run the test locally with `dart test`.
  - Fix timing, buffering, or pipeline integration issues exposed by the test.
- Related source files:
  - Make minimal fixes to the framework code if the smoke test reveals real bugs.

Out of scope (to be handled in later tasks):

- Expanding smoke coverage beyond the first-phase scope.
- Refactoring engine internals unless required to make the test pass.

## API References

- `dart test`: https://dart.dev/tools/dart-test
- `package:test` asynchronous testing: https://pub.dev/documentation/test/latest/

## Acceptance Criteria

- `dart test` runs the smoke test successfully.
- The smoke test passes consistently across repeated runs.
- Any framework fixes are minimal, tested separately if possible, and do not change public APIs.
- Static analysis passes after any source changes.

## How

Run `dart test test/smoke_test.dart` and inspect the output. If the test fails, determine whether the failure is in the test setup (for example, missing frame scheduling or incorrect provider wiring) or in the framework (for example, the diff engine not flushing, or the parser not emitting events). Fix test setup issues in the test file; fix real framework bugs in the relevant source file with the smallest change possible. Re-run until the test is green and stable.

## Why

A passing smoke test is the final validation of the first phase. Stabilizing it ensures the framework pipeline works in practice, not just in unit isolation.
