# task-6-3-2

## Identity

| Field        | Value                                |
|--------------|--------------------------------------|
| Type         | Task                                 |
| Title        | Write Smoke Test Scenarios           |
| Parent Story | task-6-3                             |

## Objective

Define and implement the test scenarios that prove full-screen text rendering and stdin-driven updates.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `test/smoke_test.dart` (continued from task-6-3-1):
  - Scenario A: initial render of a full-screen `Text` widget.
  - Scenario B: render updates after a simulated stdin event changes the ViewModel state.
  - Assertions on captured stdout text and/or ANSI sequences.

Out of scope (to be handled in later tasks):

- Multiple stdin events, complex input sequences, or edge cases around line buffering.
- Performance assertions.

## API References

- `package:test`: https://pub.dev/packages/test
- `expect` matcher: https://pub.dev/documentation/test/latest/expect/expect.html

## Acceptance Criteria

- The initial render scenario asserts that the expected full-screen text appears in the captured output.
- The update scenario feeds a stdin event, schedules a frame, and asserts that the output changes to the new text.
- Assertions are deterministic and do not depend on real terminal dimensions.
- Tests compile, run, and report clear failures if the pipeline regresses.

## How

Extend the harness from task-6-3-1 with focused test cases. For the initial render, build the tree once and flush the pipeline; verify the captured output contains the expected text. For the update case, add a stdin byte sequence that the ViewModel translates into a new model, request a frame, and verify the new text appears. Where possible, assert that the diff engine only rewrites the changed region rather than redrawing the entire screen.

## Why

Scenarios turn the harness into a meaningful regression test. They encode the definition of done for the first phase: the framework can render text and respond to input.
