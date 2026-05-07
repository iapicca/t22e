# Task 1.1.4: Cursor Sequences

**Story:** ANSI Escape Code Definitions
**Estimate:** S

## Description

Implement functions for cursor manipulation: absolute positioning, show/hide, save/restore, and cursor style (block/bar/underline, blinking/steady).

## Implementation

```dart
// ansi/cursor.dart
String moveTo(int row, int col) => '\x1b[${row};${col}H';
String moveUp(int n) => '\x1b[${n}A';
String moveDown(int n) => '\x1b[${n}B';
String moveRight(int n) => '\x1b[${n}C';
String moveLeft(int n) => '\x1b[${n}D';
String hide() => '\x1b[?25l';
String show() => '\x1b[?25h';
String savePosition() => '\x1b[s';
String restorePosition() => '\x1b[u';
// cursor style: blinking block, steady block, blinking bar, etc.
String setStyle(CursorStyle style) => '\x1b[${style.value} q';
```

## Acceptance Criteria

- Absolute, relative, save/restore, and show/hide all implemented
- Cursor style sequences for block/bar/underline with blink variants
- All functions pure, unit-tested
