# Task 3.2.2: Color Capability Detection

**Story:** Terminal Capability Detection
**Estimate:** M

## Description

Query the terminal's true color support by using the color query protocol (OSC 10 for foreground, OSC 11 for background). Fall back to DA1 attribute parsing or $COLORTERM env var.

## Implementation

```dart
ColorProfile detectColorCapability(TerminalIo io, Da1Result? da1) {
  // 1. Check $COLORTERM env var
  // 2. Try OSC 10 query for truecolor response
  // 3. Fall back to DA1 color attributes
  // 4. Fall back to $TERM heuristic
  // Return: noColor, ansi16, indexed256, trueColor
}
```

## Acceptance Criteria

- OSC 10/11 queries attempt to detect truecolor support
- $COLORTERM=truecolor is recognized
- DA1 response: attribute 22 indicates 256 colors, attribute 28 indicates truecolor
- $TERM suffixes like -256color indicate indexed color
- Returns the highest reliably detected color profile (never over-detect)
- Probe has timeout and returns conservative estimate on failure
