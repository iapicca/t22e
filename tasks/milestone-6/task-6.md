# task-6

## Identity

| Field            | Value                                                   |
|------------------|---------------------------------------------------------|
| Type             | Feature                                                 |
| Title            | Public API and Smoke Test                               |
| Children Stories | task-6-1, task-6-2, task-6-3, task-6-4                  |

## Logical Flow

This feature closes the first phase by sealing the public API surface, hiding engine internals, and proving the framework end-to-end with a runnable smoke test. Application code interacts only with Riverpod providers and declarative widgets exported from `package:t22e/t22e.dart`, while the rendering engine and terminal wrappers remain internal implementation details.

```mermaid
graph TD
    A[Application Code] -->|imports| B[package:t22e/t22e.dart]
    B --> C[Public Providers]
    B --> D[Declarative Widgets]
    C --> E[ViewModel Notifiers]
    D --> F[Build / Layout / Paint]
    E --> F
    F --> G[Diff Engine]
    G --> H[stdout]

    I[Engine Internals] -.->|@internal| B
```

## Objective

Close the first phase with a runnable, provider-driven full-screen text widget:
- Public API exposed primarily through Riverpod providers.
- Engine internals marked `@internal` from `package:meta`.
- Smoke test rendering full-screen text and updating on stdin events.
- Public barrel file `lib/t22e.dart` updated to export only the intended public surface.

## Scope Boundary

- Public provider-based API for framework services and state access.
- Application of `@internal` annotations to engine, buffer, ANSI, and I/O classes.
- End-to-end smoke test covering stdin → state → widget → render pipeline.
- Public barrel export cleanup and verification.

Out of scope (to be handled in child stories and later milestones):

- Integration test suite, example application, or documentation site.
- Additional widgets beyond `Text` and the full-screen root.
- Raw terminal mode, mouse, alternate buffer, or resize handling.
- Performance benchmarking or GC hypothesis validation.

## Acceptance Criteria

- All children stories are completed and accepted.
- A developer can import `package:t22e/t22e.dart` and build a provider-driven full-screen `Text` widget.
- Engine, buffer, ANSI, and terminal I/O classes carry `@internal` annotations.
- A smoke test demonstrates the program reading stdin, updating state, and rendering through the diff engine.
- All unit tests pass and static analysis is clean.

## How

Promote Riverpod providers to the primary public API surface for accessing framework services (e.g., stdin event stream, terminal size) and application state. Walk through `lib/src/` and apply `@internal` to classes and functions that are not part of the public contract. Update `lib/t22e.dart` to re-export only public symbols, leaving direct `src/` imports unsupported. Finally, write a smoke test that wires a simulated stdin byte sequence through the ANSI parser, `StreamValueNotifier`, a Riverpod ViewModel, a `Consumer`, the full-screen root widget, and the diff engine, asserting that the rendered output updates correctly.

## Why

This milestone proves the architecture described in the refined specifications is real and usable. By exposing functionality through providers, hiding implementation details with `@internal`, and validating the full pipeline with a smoke test, the framework reaches a stable first-phase deliverable that developers can import and extend.
