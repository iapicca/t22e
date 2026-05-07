# Task 1.2.1: Raw Mode via dart:io

**Story:** Raw Mode & Terminal I/O
**Estimate:** S

## Description

Implement a fallback raw mode setup using `dart:io`'s built-in `stdin.echoMode` and `stdin.lineMode`. This provides basic raw mode on all platforms without FFI.

## Implementation

```dart
void enableRawMode() {
  stdin.echoMode = false;
  stdin.lineMode = false;
}

void disableRawMode() {
  stdin.echoMode = true;
  stdin.lineMode = true;
}
```

## Acceptance Criteria

- echoMode and lineMode are toggled off/on
- Works on all platforms (Linux, macOS, Windows via dart:io)
- Tested in integration test with actual terminal
