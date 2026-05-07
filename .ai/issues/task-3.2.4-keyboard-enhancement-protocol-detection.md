# Task 3.2.4: Keyboard Enhancement Protocol Detection

**Story:** Terminal Capability Detection
**Estimate:** M

## Description

Probe for Kitty keyboard protocol support. This enables proper modifier reporting (Ctrl+letter sends actual key code instead of ASCII control char) and key repeat detection.

## Implementation

```dart
KeyboardProtocol detectKeyboardProtocol(TerminalIo io) {
  // Try Kitty protocol: \x1b[>1u (push kitty protocol)
  // Use push/pop pattern so we can restore if unsupported
  // Expect flags response: \x1b[? flags u
  // If no response within 100ms, pop protocol and return basic
}
```

## Acceptance Criteria

- Kitty keyboard protocol is probed via push (CSI > 1 u)
- If terminal responds with flags, protocol is fully enabled
- On timeout, protocol is popped (CSI < 1 u) and basic mode is used
- Results classify: basic, kitty (with flags)
- Protocol level affects which key events the parser produces
