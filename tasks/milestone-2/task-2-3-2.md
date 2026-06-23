# task-2-3-2

## Identity

| Field        | Value                              |
|--------------|------------------------------------|
| Type         | Task                               |
| Title        | Bridge Tests and Public Exports    |
| Parent Story | task-2-3                           |

## Objective

Add unit tests for the integrated bridge and export the public API through the package barrel file.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `test/async_value/`:
  - Add tests for `AsyncValue<T>` equality and helpers.
  - Add tests for `StreamValueNotifier<T>` lifecycle and event propagation.
  - Add tests for Riverpod provider integration with a controlled stream.

- `lib/t22e.dart`:
  - Export `AsyncValue`, `AsyncData`, `AsyncLoading`, `AsyncError` (or a unified export).
  - Export the public provider helper/factory.
  - Keep engine-internal bridge classes marked `@internal` or unexported.

- `analysis_options.yaml` / `pubspec.yaml` (if already present):
  - No changes unless tests reveal missing dev dependencies.

Out of scope (to be handled in later tasks):

- Integration tests with real stdin/stdout.
- Documentation beyond task files and inline doc comments.

## API References

- Package API: https://pub.dev/documentation/riverpod/latest/riverpod/ProviderContainer-class.html
- Package API: https://pub.dev/packages/test

## Acceptance Criteria

- Unit tests cover data, loading, and error transitions for the full bridge pipeline.
- Provider disposal is tested and verified to cancel the stream subscription.
- `lib/t22e.dart` exports only the intended public bridge symbols.
- All tests pass and static analysis succeeds.
- `@internal` markers from `package:meta` are applied to any exported-but-unsupported symbols.

## How

Use `ProviderContainer` from `riverpod` to test provider disposal and updates. Use a `StreamController<T>` to drive controlled stream events in tests. In `lib/t22e.dart`, add `export 'src/async_value/async_value.dart';` and `export 'src/async_value/provider_bridge.dart';` (or equivalent), while leaving internal implementation files unexported. Run `dart test` and `dart analyze` to verify.

## Why

Tests prove that the synchronous bridge contract holds end-to-end, and the barrel file defines the public surface that downstream milestones will build on. Without this task, the bridge would be implemented but not safely consumable by the rest of the framework.
