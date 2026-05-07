# Task 5.2.1: Kitty Keyboard Protocol

**Story:** Advanced Input
**Estimate:** M

## Description

Implement full Kitty keyboard protocol support. When enabled, Ctrl+letter combinations send the actual key code rather than ASCII control characters. Also enables proper key repeat and release detection.

## Implementation

```dart
// Protocol:
// Push: \x1b[>1u   (enable progressive enhancement)
// Pop:  \x1b[<1u   (restore to default)
//
// Response format: \x1b[?flags u
// Flags: 1=disambiguate escape codes, 2=report event types, 4=report alternates, 8=report all keys
//
// Key event: \x1b[code;modifiers;text;baseline;focused u
```

## Acceptance Criteria

- Protocol push/pop with automatic restoration on exit
- Disambiguate: Ctrl+I ≠ Tab, Ctrl+[ ≠ Escape, Ctrl+M ≠ Enter
- Event types: distinguish press, repeat, release
- Modifier reporting: Ctrl, Shift, Alt, Meta, Hyper, Super
- All keys reportable: including modifiers as standalone keys
- Graceful degradation: if probe fails, use basic mode
- Parser updated to handle Kitty-formatted key sequences
