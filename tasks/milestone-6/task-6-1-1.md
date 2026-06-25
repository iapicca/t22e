# task-6-1-1

## Identity

| Field        | Value                          |
|--------------|--------------------------------|
| Type         | Task                           |
| Title        | Audit Public API Surface       |
| Parent Story | task-6-1                       |

## Objective

Identify every framework service that application code must be able to reach through Riverpod providers.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- Review of existing `lib/src/` providers, notifiers, and services from milestones 0–5.
- Documentation of which services are intended to be public and which should remain internal.
- A short decision record, either as comments or as a scratch file, listing the public provider surface.

Out of scope (to be handled in later tasks):

- Writing or modifying provider implementations.
- Updating `lib/t22e.dart`.
- Adding tests.

## API References

- Riverpod docs: https://riverpod.dev/docs/concepts/providers
- Dart API: https://api.dart.dev/stable/dart-core/Object/hashCode.html

## Acceptance Criteria

- A clear list of public providers exists, including at minimum:
  - stdin event provider,
  - terminal size provider,
  - `TuiContext` / provider container access.
- Each listed provider has a one-sentence rationale.
- Internal-only services are explicitly excluded.
- The audit is shared or recorded in a way that task-6-1-2 can consume it.

## How

Open each `lib/src/` subdirectory created in earlier milestones and read the provider-related code. Ask whether an application developer would reasonably need to read or watch the service from a widget or ViewModel. If yes, add it to the public list. If no, note it as internal. Do not change source files during this audit.

## Why

Before implementing public providers, the framework needs a stable inventory of what should be public. This prevents scope creep and avoids exposing implementation details that would later have to be hidden again.
