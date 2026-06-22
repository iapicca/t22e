# task-0-1-1

## Identity

| Field        | Value                       |
|--------------|-----------------------------|
| Type         | Task                        |
| Title        | Create pubspec.yaml         |
| Parent Story | task-0-1                    |

## Objective

Create a valid `pubspec.yaml` file that declares the `t22e` package and its required dependencies.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `pubspec.yaml`: create the package manifest with name, version, description, SDK constraint, and the dependency list from the refined specification.

Out of scope (to be handled in later tasks):

- Running `dart pub get` (handled in task-0-4-1).
- Adding scripts or executables.
- Adding dev-only dependencies not listed in the specification.

## API References

- Dart API: https://dart.dev/tools/pub/pubspec
- Package API: https://pub.dev/packages/riverpod, https://pub.dev/packages/freezed

## Acceptance Criteria

- `pubspec.yaml` exists at the repository root.
- The file declares the package name as `t22e` and a sensible initial version.
- The SDK constraint targets the latest stable Dart SDK.
- The following dependencies are present:
  - `riverpod`
  - `freezed`
  - `freezed_annotation`
  - `build_runner`
  - `meta`
  - `test`
  - `mocktail`
- Dependency versions use caret constraints or explicit stable versions.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Write the `pubspec.yaml` manifest by hand. Place runtime dependencies under `dependencies:` and code-generation/testing tools under `dev_dependencies:`. Use caret ranges to allow compatible updates while remaining reproducible. Do not include any implementation code or scripts at this stage.

## Why

`pubspec.yaml` is the entry point for every Dart package. It must be in place before any source file can import third-party packages or before static analysis can validate the project.
