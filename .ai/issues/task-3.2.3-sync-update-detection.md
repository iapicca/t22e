# Task 3.2.3: Sync Update Support Detection

**Story:** Terminal Capability Detection
**Estimate:** S

## Description

Probe for synchronized update support by querying DECRPM on ?2026. If the terminal responds positively, wrap all render output in sync markers for flicker-free updates.

## Implementation

```dart
bool detectSyncSupport(TerminalIo io) {
  // Send DECRPM: \x1b[?2026$p
  // Expect DECRPM response: \x1b[?2026;1$y (supported) or \x1b[?2026;2$y (unsupported)
  io.write('\x1b[?2026$p');
  // read response with timeout
}
```

## Acceptance Criteria

- Sends DECRPM query for ?2026
- Parses response: `\x1b[?2026;1$y` means supported
- Returns false on timeout or negative response
- Result is cached and available to the renderer
