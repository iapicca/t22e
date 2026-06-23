# task-6-4-3

## Identity

| Field        | Value                                          |
|--------------|------------------------------------------------|
| Type         | Task                                           |
| Title        | Verify Barrel Through Smoke Test               |
| Parent Story | task-6-4                                       |

## Objective

Ensure the smoke test and any public API tests compile using only `package:t22e/t22e.dart` and have no direct `src/` imports.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `test/smoke_test.dart` and `test/providers_test.dart`:
  - Replace any direct `package:t22e/src/...` imports with the public barrel import.
- `lib/t22e.dart`:
  - Confirm it exposes every symbol the tests need.

Out of scope (to be handled in later tasks):

- Adding new public symbols just to satisfy tests (tests should reflect the public API).
- Rewriting tests to avoid needing legitimately internal helpers.

## API References

- Dart library imports: https://dart.dev/language/libraries

## Acceptance Criteria

- The smoke test imports only `package:t22e/t22e.dart`.
- The provider test imports only `package:t22e/t22e.dart` and test packages.
- Both test files compile and pass.
- `dart analyze` reports no issues related to missing imports or private symbols.

## How

Open the test files and remove or replace any direct `src/` imports. If a test needs a symbol that is not in the public barrel, determine whether the symbol should be public (add it to the barrel) or whether the test should use a public alternative (update the test). Re-run the smoke test and provider tests, and run `dart analyze`, to confirm everything works through the public barrel.

## Why

The smoke test is the primary proof that the public API is sufficient. If it cannot be written using only the public barrel, the barrel is incomplete or the public API design needs adjustment.
