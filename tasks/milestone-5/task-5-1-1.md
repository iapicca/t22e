# task-5-1-1

## Identity

| Field        | Value                |
|--------------|----------------------|
| Type         | Task                 |
| Title        | Define Widget Base Class |
| Parent Story | task-5-1             |

## Objective

Define the immutable base class for all declarative widgets in the framework.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/view/widget.dart`:
  - Define an abstract `Widget` base class.
  - Make widgets immutable (e.g., `const` constructors and `@immutable`).
  - Declare a method that creates the corresponding engine `Element`/`Node`.
  - Provide equality/hashCode suitable for immutable value types.

Out of scope (to be handled in later tasks):

- Concrete widget implementations.
- Build context and provider access integration.
- Element lifecycle and dirty tracking.

## API References

- Dart API: https://api.dart.dev/stable/dart-core/Object/hashCode.html
- Dart API: https://api.dart.dev/stable/meta/Immutable-class.html

## Acceptance Criteria

- `Widget` is an abstract, immutable base class.
- Subclasses can be declared `const`.
- The create-element/compile method is typed and overridable.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Create `lib/src/view/widget.dart` and define `abstract class Widget` with `@immutable` from `package:meta`. Add a `const Widget()` constructor and an abstract method such as `Element createElement()` or `Node compile()` that returns the runtime node. Override `operator ==` and `hashCode` (or rely on a code-generated base) so widget instances can be compared by value. Keep the class minimal; only add fields and methods required by all widgets.

## Why

A stable widget base class is the foundation of the declarative API. Immutability and value equality let the engine detect changes between frames without complex identity tracking.
