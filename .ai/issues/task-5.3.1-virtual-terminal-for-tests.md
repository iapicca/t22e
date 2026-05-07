# Task 5.3.1: Virtual Terminal for Tests

**Story:** Testing & Quality
**Estimate:** M

## Description

Build an in-memory virtual terminal that processes ANSI escape sequences and maintains a cell grid. Enables deterministic widget testing without a real terminal.

## Implementation

```dart
class VirtualTerminal {
  List<List<Cell>> grid;
  int cursorX, cursorY;
  TextStyle currentStyle;
  bool altScreen;

  void write(String ansi) {
    // parse and apply ANSI sequences to grid
    // support: SGR, cursor movement, erase, line feeds, scroll
  }

  String plainText() { /* extract plain text from grid */ }
  String styledText() { /* extract styled text (for assertion) */ }
  Cell cellAt(int row, int col) { /* inspect individual cell */ }
}
```

## Acceptance Criteria

- Supports: SGR colors/attributes, cursor absolute/relative movement, erase screen/line, line feed, carriage return, scroll up
- Supports: alternate screen buffer
- Cell inspection: `cellAt(row, col)` returns full Cell (char + style)
- `plainText()`: returns grid as plain text string with newlines
- `styledText()`: returns grid with inline ANSI codes for assertions
- Resize support: virtual terminal can be resized
- No real terminal required — all operations are in-memory
- Unit tests: verify the virtual terminal correctly processes known ANSI patterns
