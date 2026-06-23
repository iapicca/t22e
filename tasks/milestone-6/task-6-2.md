# task-6-2

## Identity

| Field          | Value                                  |
|----------------|----------------------------------------|
| Type           | Story                                  |
| Title          | Mark Engine Internals as @internal     |
| Parent Feature | task-6                                 |
| Children Tasks | task-6-2-1, task-6-2-2, task-6-2-3     |

## Logical Flow

Most of the framework is implementation detail. This story applies the `@internal` annotation from `package:meta` to engine, buffer, ANSI, and I/O classes so that direct `src/` imports are clearly unsupported while the public barrel remains clean.

```mermaid
graph TD
    A[lib/t22e.dart] -->|exports only| B[Public Symbols]
    C[lib/src/engine/] -->|@internal| D[Engine Classes]
    E[lib/src/io/] -->|@internal| F[Terminal Wrappers]
    G[lib/src/async_value/] -.->|public or internal| A
```

## Objective

Apply `@internal` annotations to all framework internals that are not part of the public API.

## Scope Boundary

- Deliverable this story introduces:
  - `@internal` markers on engine classes in `lib/src/engine/`.
  - `@internal` markers on terminal I/O classes in `lib/src/io/`.
  - `@internal` markers on internal models, buffer helpers, and ANSI writers as needed.

Out of scope (to be handled in child tasks):

- Adding runtime enforcement of internal visibility.
- Changing public behavior of any class.
- Writing extensive documentation about internal usage.

## Acceptance Criteria

- All children tasks are completed and accepted.
- Every class, mixin, and top-level function in `lib/src/engine/` and `lib/src/io/` that is not explicitly public is marked `@internal`.
- Internal-only models and helpers in other `lib/src/` subdirectories are reviewed and annotated.
- Static analysis passes with the configured `analysis_options.yaml`.
- Tests still compile and pass; no public symbol is accidentally hidden.

## How

Walk through `lib/src/engine/`, `lib/src/io/`, `lib/src/models/`, and other `lib/src/` subdirectories. Add `@internal` from `package:meta` to classes, constructors, methods, and top-level functions that are implementation details. Ensure that any symbol re-exported by `lib/t22e.dart` as public is intentionally left unannotated or explicitly documented. Run `dart analyze` to confirm there are no new issues.

## Why

`@internal` communicates the stability contract of the framework. It protects users from relying on implementation details that will change, and it clarifies which symbols the maintainers must keep backward-compatible.
