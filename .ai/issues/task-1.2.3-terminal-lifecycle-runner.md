# Task 1.2.3: Terminal Lifecycle Runner

**Story:** Raw Mode & Terminal I/O
**Estimate:** M

## Description

Build a lifecycle manager that safely enters and restores terminal raw mode. Uses `Zone.run` or `try/finally` to guarantee restoration even on exceptions. Integrates with signal handling for SIGINT/SIGTERM.

## Implementation

```dart
class TermRunner {
  bool _rawModeEnabled = false;

  void enter() { /* enable raw mode */ _rawModeEnabled = true; }
  void exit() { /* restore terminal */ _rawModeEnabled = false; }

  void run(void Function() body) {
    enter();
    try {
      body();
    } finally {
      exit();
    }
  }
}
```

## Acceptance Criteria

- Terminal state is always restored on normal exit, exception, or signal
- Idempotent — calling `exit()` multiple times is safe
- Works with both dart:io and FFI raw mode implementations
- Can be extended to manage alternate screen buffer
