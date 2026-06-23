# task-6-3-1

## Identity

| Field        | Value                                |
|--------------|--------------------------------------|
| Type         | Task                                 |
| Title        | Build Smoke Test Harness             |
| Parent Story | task-6-3                             |

## Objective

Create a test harness that wires the complete framework pipeline from stdin bytes to stdout output.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `test/smoke/full_screen_text_test.dart` or `test/smoke_test.dart`:
  - Construct a mock or controller-based stdin byte stream.
  - Wire it through the ANSI parser and `StreamValueNotifier`.
  - Provide a Riverpod `Notifier` ViewModel that consumes input events.
  - Instantiate the rendering pipeline with a fixed terminal size and a capturing stdout writer.

Out of scope (to be handled in later tasks):

- Writing assertions for specific output sequences.
- Testing resize, mouse, or raw mode behavior.

## API References

- `package:test`: https://pub.dev/packages/test
- `dart:io` `StreamController<List<int>>`: https://api.dart.dev/stable/dart-async/StreamController-class.html

## Acceptance Criteria

- The harness compiles and runs without errors.
- A simulated stdin byte sequence reaches the ViewModel.
- The ViewModel emits an updated model that the widget tree can observe.
- The rendering pipeline produces output that can be captured and inspected.
- No real terminal or stdin is required to run the harness.

## How

Create a new smoke test file and build the pipeline using test doubles where necessary. Use a `StreamController<List<int>>` as the stdin source and a custom `StdoutWriter` or `StringBuffer` as the stdout sink. Connect the parser output to the `StreamValueNotifier`, connect the notifier to a Riverpod ViewModel, and expose the ViewModel through a public provider. Build the widget tree inside a fixed-size root and run the engine pipeline. Leave the assertion step for task-6-3-2.

## Why

A working harness is the prerequisite for the smoke test. It proves the pieces fit together and gives a controlled environment in which to assert end-to-end behavior.
