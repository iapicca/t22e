# AI Guidelines — t22e

## Pre-flight reading

Before planning or building, read:

- `.ai/project.md` — architecture and scope
- `.ai/coding-standards.md` — style and conventions

## Generated files

Never read, modify, delete, or otherwise interact with generated files (`*.g.dart`, `*.freezed.dart`). They are build artifacts produced by `build_runner` and must not be edited by hand.

## Research and references

- When looking up package or Dart language behavior, prefer official documentation
  (e.g. `https://pub.dev/packages/<package>` and `https://dart.dev`) over reading
  files from the local `.pub-cache`.

## TODO comments

Never delete a TODO comment unless the user specifically instructs you to do so.
TODO comments are intentional markers for future work and should be preserved.

## Post-build hand-off

After completing work, do **not** directly append to `.ai/project.md` or `.ai/coding-standards.md`. Instead, present the proposed additions to the user and wait for approval before writing them.
