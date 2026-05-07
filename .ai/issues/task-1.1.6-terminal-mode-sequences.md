# Task 1.1.6: Terminal Mode Sequences

**Story:** ANSI Escape Code Definitions
**Estimate:** M

## Description

Implement terminal mode control sequences: alternate screen buffer, mouse modes (normal, SGR, SGR-pixels), synchronized updates, bracketed paste, keyboard protocol (Kitty), hyperlinks, notifications, terminal title, and color queries.

## Implementation

```dart
// ansi/term.dart
String enterAltScreen() => '\x1b[?1049h';
String exitAltScreen() => '\x1b[?1049l';
String enableSgrMouse() => '\x1b[?1000h\x1b[?1002h\x1b[?1006h';
String disableMouse() => '\x1b[?1000l\x1b[?1002l\x1b[?1006l';
String startSync() => '\x1b[?2026h';
String endSync() => '\x1b[?2026l';
String enableBracketedPaste() => '\x1b[?2004h';
String disableBracketedPaste() => '\x1b[?2004l';
String setTitle(String title) => '\x1b]0;${title}\x07';
String hyperlink(String uri, String text) => '\x1b]8;;${uri}\x07${text}\x1b]8;;\x07';
// ... etc
```

## Acceptance Criteria

- All common terminal modes have toggle pairs (enable/disable)
- Kitty keyboard protocol queries have enable/disable sequences
- Synchronized update (`?2026`) toggle implemented
- Hyperlink function produces correct OSC 8 sequence
- All functions pure, unit-tested
