# Task 5.3.2: Widget Test Utilities

**Story:** Testing & Quality
**Estimate:** M

## Description

Build test utilities for widget testing: render a widget tree into a virtual terminal, simulate key events, and assert on the resulting cell grid.

## Implementation

```dart
class WidgetTester {
  final VirtualTerminal vt = VirtualTerminal();

  void pumpWidget(Widget root, {int width = 80, int height = 24}) {
    // layout → paint into virtual terminal surface → render via ANSI → vt.write()
  }

  void sendKeyEvent(KeyCode key, {KeyModifiers modifiers}) {
    // simulate key event → update model → re-render
  }

  void expectCell(int row, int col, {String? char, TextStyle? style}) {
    // assert specific cell state
  }

  void expectPlainText(String expected) {
    // assert plain text output
  }
}
```

## Acceptance Criteria

- `pumpWidget()`: builds, lays out, paints, and renders a widget into the virtual terminal
- `sendKeyEvent()`: simulates a key event and reprocesses the widget tree
- `expectCell()`: asserts char, style, or both at a specific cell
- `expectPlainText()`: asserts the entire screen as plain text
- `expectStyledText()`: asserts with ANSI codes included
- Works with all built-in widgets
- Tests run in standard `dart test` without any terminal emulation dependency
- Example test: `testWidgets('Text renders correctly', (tester) => ...)`
