# Task 3.3.3: Alternate Screen Mode Management

**Story:** Lifecycle & Signal Handling
**Estimate:** S

## Description

Manage the terminal's alternate screen buffer. Enter alt screen on program start, exit on shutdown. This preserves the user's terminal history when the TUI exits.

## Implementation

```dart
class AltScreenManager {
  bool _active = false;

  void enter() {
    stdout.write('\x1b[?1049h'); // enter alt screen
    _active = true;
  }

  void exit() {
    stdout.write('\x1b[?1049l'); // exit alt screen
    _active = false;
  }
}
```

## Acceptance Criteria

- Alternate screen is entered before first render
- Alternate screen is exited on shutdown (normal and crash)
- Cursor is hidden in alt screen, shown on exit
- Toggle is idempotent
- Integrated with TerminalGuard for crash safety
