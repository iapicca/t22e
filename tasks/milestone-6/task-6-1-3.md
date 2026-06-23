# task-6-1-3

## Identity

| Field        | Value                                  |
|--------------|----------------------------------------|
| Type         | Task                                   |
| Title        | Test Public Provider API               |
| Parent Story | task-6-1                               |

## Objective

Add unit tests verifying that the public providers expose the correct values and notify listeners on change.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `test/providers_test.dart` (new file):
  - Test reading each public provider from a `ProviderContainer`.
  - Test that `StateProvider`-based providers notify watchers when updated.
  - Test that `Consumer` rebuilds when the provider it watches changes.

Out of scope (to be handled in later tasks):

- Testing internal engine behavior.
- Testing the full rendering pipeline (covered by the smoke test in task-6-3).

## API References

- `package:test`: https://pub.dev/packages/test
- Riverpod testing: https://riverpod.dev/docs/cookbooks/testing

## Acceptance Criteria

- Tests cover every public provider defined in task-6-1-2.
- Provider read operations return expected default or injected values.
- Watcher notifications fire when stateful providers are updated.
- `Consumer` rebuilds are verified at the widget node level if the widget layer supports it.
- All tests pass and static analysis is clean.

## How

Create a test file that constructs a `ProviderContainer`, overrides providers where useful, and reads each public provider. For `StateProvider` values, mutate the state and assert that listeners are notified. If the widget layer has a testable `Consumer` compile path, add a small test that rebuilds a node when the watched provider changes. Keep tests focused on provider behavior rather than engine internals.

## Why

Provider tests guard the public API contract. They ensure that future refactors of engine internals do not silently break the way application code reads framework services.
