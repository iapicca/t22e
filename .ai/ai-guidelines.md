# AI Guidelines — t22e

## Pre-flight reading

Before planning or building, read:

- `.ai/refined-project-specifications.md` — architecture and scope
- `.ai/coding-standards.md` — style and conventions
- `./tasks/task-template.md` — task hierarchy format
- Relevant task files under `./tasks/`

## Generated files

Ignore the content of generated files (`*.g.dart`, `*.freezed.dart`). They are build artifacts and must not be edited by hand.

## Post-build hand-off

After completing work, do **not** directly append to `.ai/project.md` or `.ai/coding-standards.md`. Instead, present the proposed additions to the user and wait for approval before writing them.
