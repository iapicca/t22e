# Task 1.2.2: Raw Mode via FFI to libc

**Story:** Raw Mode & Terminal I/O
**Estimate:** M

## Description

Implement full raw mode setup using Dart FFI to libc's `tcgetattr`/`tcsetattr`. Provides granular control: disable ECHO, ICANON, ISIG, IEXTEN, ICRNL, set VMIN=1, VTIME=0.

## Implementation

```dart
import 'dart:ffi';
import 'package:ffi/ffi.dart';

// termios struct definition
// tcgetattr(0, &termios) → read current
// modify flags
// tcsetattr(0, TCSANOW, &termios) → apply

final termiosSize = 60; // platform-specific, should be computed
final cIflag = 0;
final cOflag = ...;
final cCflag = ...;
final cLflag = ...;
final cCc = ...;

const vmin = 1;
const vtime = 0;
```

## Acceptance Criteria

- Disables: ECHO, ICANON, ISIG, IEXTEN, ICRNL
- Sets VMIN=1, VTIME=0
- Saves original termios for restoration
- Handles errors gracefully (throws descriptive exception)
- Unix-only (Linux, macOS); graceful fallback to dart:io on Windows
