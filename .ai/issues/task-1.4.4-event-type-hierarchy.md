# Task 1.4.4: Event Type Hierarchy

**Story:** Input Parser (VT500)
**Estimate:** M

## Description

Define the complete event type hierarchy consumed by the TEA event loop. Events are produced by semantic parsers and dispatched to the application's `update()` function.

## Implementation

```dart
abstract class Event {}

class InputEvent extends Event {
  // KeyEvent, MouseEvent, PasteEvent, RawKeyEvent
}

class ResponseEvent extends Event {
  // CursorPositionEvent, ColorQueryEvent, FocusEvent,
  // PrimaryDeviceAttributesEvent, KeyboardEnhancementFlagsEvent,
  // WindowResizeEvent, QuerySyncUpdateEvent, etc.
}

class ErrorEvent extends Event {
  final String message;
  final Object? cause;
}

class InternalEvent extends Event {
  // Timer tick, system events
}
```

## Acceptance Criteria

- `KeyEvent` carries: `KeyCode`, `KeyModifiers` (ctrl/shift/alt/meta), `Runes` (actual chars), `KeyEventType` (down/up/repeat)
- `MouseEvent` carries: `MouseButton`, `MouseAction` (press/release/move/drag), position (x, y)
- `PasteEvent` carries: bracketed paste content string
- `ResponseEvent` subtypes carry typed payloads (no string parsing by consumer)
- All events are immutable, equatable
- Serialization/toString for debugging
