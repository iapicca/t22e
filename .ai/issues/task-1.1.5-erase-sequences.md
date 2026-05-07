# Task 1.1.5: Erase Sequences

**Story:** ANSI Escape Code Definitions
**Estimate:** S

## Description

Implement erase/clear functions: clear entire display, clear line variants (to end, to start, entire line), and clear to end of screen/start of screen.

## Implementation

```dart
// ansi/erase.dart
String eraseDisplay(int mode) => '\x1b[${mode}J';  // 0=to end, 1=to start, 2=entire
String eraseLine(int mode) => '\x1b[${mode}K';    // 0=to end, 1=to start, 2=entire
String eraseScreen() => '\x1b[2J';
String eraseSavedLines() => '\x1b[3J';
```

## Acceptance Criteria

- All standard erase variants are implemented
- Functions are pure with clear names
- Unit tests for each variant
