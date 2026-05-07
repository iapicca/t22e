# Task 3.3.1: Terminal Auto-Restore on Crash

**Story:** Lifecycle & Signal Handling
**Estimate:** M

## Description

Implement robust terminal restoration that guarantees the terminal is returned to its original state even if the application crashes. Uses `Zone.runGuarded`, `try/finally`, and Process signal listeners.

## Implementation

```dart
class TerminalGuard {
  Termios _savedState;
  bool _restored = false;

  void arm() { /* save state */ }
  void disarm() { /* mark as restored */ }
  void restore() {
    if (!_restored) {
      // restore termios, leave alt screen, show cursor
      _restored = true;
    }
  }
}

// Usage: runGuarded with restore in finally
```

## Acceptance Criteria

- Terminal is restored on: normal exit, unhandled exception, `asynchronous gap` error
- `restore()` is idempotent (safe to call multiple times)
- Works with both dart:io and FFI raw mode
- Registered as a `Zone.run` finalizer
- Tested by simulating crashes in integration tests
