# Task 3.1.1: Model Abstract Class

**Story:** TEA Event Loop
**Estimate:** S

## Description

Define the abstract `Model` class that all application models extend. Specifies the `update()` and `view()` interface.

## Implementation

```dart
abstract class Model<M extends Model<M>> {
  (M, Cmd?) update(Msg msg);
  dynamic view(); // returns widget tree or rendering instructions
}
```

## Acceptance Criteria

- `update()` receives a Msg and returns a tuple of (new Model, optional Cmd)
- `view()` returns the declarative representation for rendering
- Model is immutable by convention (all fields should be final)
- No side effects in `update()` or `view()` — side effects go through Cmd
- Type parameter enables chaining update returns in subclass
