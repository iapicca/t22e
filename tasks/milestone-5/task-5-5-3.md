# task-5-5-3

## Identity

| Field        | Value                |
|--------------|----------------------|
| Type         | Task                 |
| Title        | Add Consumer Widget Tests |
| Parent Story | task-5-5             |

## Objective

Write unit tests that verify `Consumer` reads providers and compiles the expected subtree.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `test/view/components/consumer_test.dart`:
  - Test that `Consumer` reads a `StateProvider` value.
  - Test that the builder is called with the current value.
  - Test that the compiled subtree reflects the provider value.

Out of scope (to be handled in later tasks):

- Listener-driven rebuild tests (deferred until frame-request integration).
- Async provider tests.
- Multi-provider consumer tests.

## API References

- Riverpod test helpers or `ProviderContainer`.
- Project: `TuiContext` from task-5-4-1.
- Project: `Consumer` from task-5-5-1.

## Acceptance Criteria

- Tests create a `ProviderContainer` and `TuiContext`.
- Tests compile a `Consumer` and assert the builder output.
- Tests verify the compiled node tree reflects the provider value.
- All tests pass and static analysis succeeds.

## How

Create a test file with a simple `StateProvider<int>` and a `Consumer<int>` that builds a `Text` widget showing the value. Build a `TuiContext` from a `ProviderContainer`, compile the `Consumer`, and assert that the resulting node is a `TextNode` with the expected content. Add a second test that updates the provider state, recompiles, and verifies the new subtree.

## Why

`Consumer` is the critical bridge between application state and the view layer. Tests prove that provider changes propagate into the widget tree correctly, which is the defining feature of the framework's architecture.
