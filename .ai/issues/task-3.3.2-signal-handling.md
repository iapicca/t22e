# Task 3.3.2: Signal Handling (SIGINT/SIGTERM/SIGTSTP)

**Story:** Lifecycle & Signal Handling
**Estimate:** M

## Description

Handle Unix signals: SIGINT (Ctrl+C from terminal), SIGTERM (kill request), and SIGTSTP (Ctrl+Z suspend). SIGINT is forwarded to the app as InterruptMsg; SIGTERM triggers clean shutdown; SIGTSTP restores terminal, suspends, and re-enters raw mode on resume.

## Implementation

```dart
void setupSignalHandling(TerminalGuard guard) {
  // SIGINT: send InterruptMsg to app, if unhandled → quit
  // SIGTERM: restore terminal, exit
  // SIGTSTP: restore terminal → raise(SIGTSTP) → on resume → re-enter raw mode
}

// Use ProcessSignal listeners
ProcessSignal.sigint.watch().listen((_) { ... });
ProcessSignal.sigterm.watch().listen((_) { ... });
ProcessSignal.sigtstp.watch().listen((_) { ... });
```

## Acceptance Criteria

- SIGINT sends InterruptMsg (app can handle it); if unhandled after N seconds, quit
- SIGTERM restores terminal immediately and exits with code 0
- SIGTSTP: restore terminal → suspend process → on resume: re-enter raw mode, redraw screen
- No double-restore if multiple signals arrive
- Works on Linux and macOS
- Signals are not ignored after first occurrence
