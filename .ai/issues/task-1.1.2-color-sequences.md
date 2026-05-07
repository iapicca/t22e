# Task 1.1.2: Color Sequences

**Story:** ANSI Escape Code Definitions
**Estimate:** S

## Description

Implement functions that produce ANSI color sequences: truecolor (24-bit), 256-color palette, and ANSI 16 colors, for both foreground and background.

## Implementation

```dart
// ansi/color.dart
String setForegroundRgb(int r, int g, int b) => '\x1b[38;2;$r;$g;${b}m';
String setBackgroundRgb(int r, int g, int b) => '\x1b[48;2;$r;$g;${b}m';
String setForeground256(int index) => '\x1b[38;5;${index}m';
String setBackground256(int index) => '\x1b[48;5;${index}m';
// ... ANSI 16 colors, reset colors
```

## Acceptance Criteria

- All color functions are pure (no I/O, no state)
- Truecolor, 256-palette, and ANSI 16 variants exist for fg and bg
- Reset/normal color function exists
- Each function has a unit test verifying exact output
