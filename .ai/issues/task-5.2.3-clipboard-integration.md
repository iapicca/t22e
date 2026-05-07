# Task 5.2.3: Clipboard Integration

**Story:** Advanced Input
**Estimate:** S

## Description

Implement clipboard read/write via OSC 52. This allows the TUI to read from and write to the system clipboard.

## Implementation

```dart
// Write clipboard: \x1b]52;c;base64_data\x07
// Read clipboard: \x1b]52;c;?\x07
// Response: \x1b]52;c;base64_data\x07
// c = clipboard (0-9), usually c for "clipboard", p for "primary"

class Clipboard {
  static Future<String?> read(TerminalIo io) async { ... }
  static Future<void> write(TerminalIo io, String text) async { ... }
}
```

## Acceptance Criteria

- Write: encodes text as base64, sends OSC 52 sequence
- Read: sends query, parses response (base64 decode)
- Primary clipboard and system clipboard are distinguished (c vs p)
- Permission: some terminals require user confirmation
- Graceful degradation: returns null on unsupported terminals
- Timeout: if no response within 500ms, assume unsupported
