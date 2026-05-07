# Task 1.4.2: CSI Semantic Parser

**Story:** Input Parser (VT500)
**Estimate:** L

## Description

Implement the CSI (Control Sequence Introducer) semantic parser. Translates CSI sequence data from the engine into specific input events: arrow keys, function keys, Home/End, Insert/Delete, Kitty keyboard protocol, SGR mouse events, cursor position reports, device attributes responses.

## Implementation

```dart
class CsiParser {
  Event? parse(CsiSequenceData data) {
    // based on final byte and params, dispatch to specific handlers
  }
}
```

## Acceptance Criteria

- Arrows with modifiers (Ctrl/Shift/Alt+Arrow) produce correct KeyEvents
- F-keys F1-F24 are recognized
- Home/End, Insert/Delete, PageUp/PageDown with modifiers
- Kitty keyboard protocol sequences produce correct KeyCode + modifiers
- SGR mouse events produce MouseEvent with button, action, x, y
- CPR responses produce CursorPositionEvent
- DA1 responses produce PrimaryDeviceAttributesEvent
- Unknown CSI sequences produce UnhandledEvent (not crash)
- Unit tests for each sequence category
