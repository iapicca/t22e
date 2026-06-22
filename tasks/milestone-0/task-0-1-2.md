# task-0-1-2

## Identity

| Field        | Value                                |
|--------------|--------------------------------------|
| Type         | Task                                 |
| Title        | Create analysis_options.yaml         |
| Parent Story | task-0-1                             |

## Objective

Create an `analysis_options.yaml` file that enables the recommended Dart lints for the project.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `analysis_options.yaml`: create the analysis configuration extending `package:lints/recommended.yaml`.

Out of scope (to be handled in later tasks):

- Adding a large custom rule set.
- Configuring linter exclusions for generated files (will be needed once Freezed generation runs).
- Resolving analyzer warnings in source code (no source code exists yet).

## API References

- Dart API: https://dart.dev/tools/analysis-options
- Package API: https://pub.dev/packages/lints

## Acceptance Criteria

- `analysis_options.yaml` exists at the repository root.
- The file includes `include: package:lints/recommended.yaml`.
- Any additional project-specific rules are minimal and justified.
- The analyzer can load the configuration without errors.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Create the analysis options file and include the recommended lint set. Optionally add a small number of project-wide rules (for example, requiring public API documentation or discouraging `print` calls) that align with the framework's quality goals. Keep the file short and avoid premature tuning.

## Why

Consistent static analysis catches common mistakes early and keeps the codebase uniform as more contributors and milestones are added. Starting from `package:lints/recommended.yaml` provides a well-known, community-supported baseline.
