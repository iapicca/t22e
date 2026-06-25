# task-5-5

## Identity

| Field          | Value                       |
|----------------|-----------------------------|
| Type           | Story                       |
| Title          | Consumer Widget             |
| Parent Feature | task-5                      |
| Children Tasks | task-5-5-1, task-5-5-2, task-5-5-3 |

## Logical Flow

A `Consumer` widget observes a Riverpod provider. When the provider value changes, the framework requests a new frame and rebuilds the consumer subtree, producing an updated node tree.

```mermaid
graph TD
    A[Provider Value Change] --> B[Frame Request]
    B --> C[Consumer Rebuilds]
    C --> D[Builder Function Called]
    D --> E[New Widget / Node]
    ```

## Objective

Implement a `Consumer`-like widget that reads a Riverpod provider and rebuilds its subtree when the provider notifies listeners.

## Scope Boundary

- Deliverable this story introduces:
  - `Consumer` widget class in `lib/src/view/components/consumer.dart`.
  - Builder function that receives the provider value and returns a widget.
  - Rebuild trigger tied to provider state changes.
  - Unit tests verifying rebuild behavior.

Out of scope (to be handled in child tasks):

- Multi-provider consumers.
- Selective rebuild optimization.
- Provider family or scoped overrides.

## Acceptance Criteria

- All children tasks are completed and accepted.
- `Consumer` reads a provider value through `TuiContext`.
- The builder function is invoked during build.
- A provider update triggers a new frame request and rebuild.
- Unit tests verify rebuild and output changes.

## How

Define a `Consumer<P, T>` widget that holds a provider and a builder function `(BuildContext-like, T value) => Widget`. During compilation it reads the provider from `TuiContext`, calls the builder, and compiles the resulting child widget. Register a listener on the provider so that when it changes, the framework requests a new frame. For this milestone a simple listener-to-frame-request bridge is sufficient; selective element reuse is deferred.

## Why

`Consumer` is the main pattern for provider-driven UI. It lets application widgets stay pure functions of provider state, which is the core of the framework's declarative, MVVM-driven design.
