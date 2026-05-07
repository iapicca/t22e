# Task 4.3.2: TextInput Widget

**Story:** Interactive Widgets
**Estimate:** L

## Description

Implement a text input widget with full editing capabilities: cursor with blink, character insertion/deletion, selection, clipboard paste, password mode, validator, and cursor movement.

## Implementation

```dart
class TextInput extends Model<TextInput> {
  String value;
  int cursorPosition;
  int? selectionStart;
  EchoMode echoMode; // normal, password, noEcho
  String? Function(String)? validator;

  (TextInput, Cmd?) update(Msg msg) {
    // KeyMsg: character insertion, backspace, delete
    // Arrow keys: cursor movement
    // Shift+arrows: selection
    // Ctrl+V: paste, Ctrl+U: clear line, etc.
    // TickMsg: blink cursor
  }

  View view() {
    // render text with cursor at position
    // render selection with highlight
    // mask text in password mode
  }
}
```

## Acceptance Criteria

- Cursor blinks at configured interval (default 500ms)
- Characters inserted at cursor position
- Backspace deletes before cursor, Delete deletes after
- Home/End: jump to start/end
- Arrow keys: move cursor by 1 character (grapheme cluster aware)
- Shift+arrows: extend/shrink selection
- Paste (Ctrl+V / bracketed paste): inserts at cursor
- Password mode: renders `*` instead of characters
- Validator: callback receives current value, returns error message
- Max length: optional configurable limit
- Cursor style: block (default) or bar, blinking
- Unit tests: insertion, deletion, cursor movement, selection, masking, validation
