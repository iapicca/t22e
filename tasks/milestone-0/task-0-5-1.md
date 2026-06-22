# task-0-5-1

## Identity

| Field        | Value                          |
|--------------|--------------------------------|
| Type         | Task                           |
| Title        | Create README.md               |
| Parent Story | task-0-5                       |

## Objective

Create a minimal but accurate `README.md` for the `t22e` project.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `README.md`: create the project readme at the repository root.

Out of scope (to be handled in later tasks):

- Detailed API documentation.
- Code examples using widgets or providers.
- `CHANGELOG.md` (explicitly excluded from Milestone 0).

## API References

- Dart API: not applicable
- Package API: not applicable

## Acceptance Criteria

- `README.md` exists at the repository root.
- The file includes a project title and a brief description of `t22e` as a pure-Dart TUI framework.
- The file lists the Dart SDK prerequisite and the basic commands (`dart pub get`, `dart analyze`).
- The file includes a note that the project is in Milestone 0 and the public API is not yet available.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Write the README in Markdown. Keep the tone concise and factual. Do not include example code that depends on unimplemented features. Mention the current milestone status and point readers to the refined specification for architectural details.

## Why

The README provides context for anyone browsing the repository. Creating it during bootstrap ensures the project is approachable from day one, even before any framework code is written.
