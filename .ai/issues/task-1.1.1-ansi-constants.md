# Task 1.1.1: ANSI Constants (ESC, CSI, OSC, DCS, ST, BEL)

**Story:** ANSI Escape Code Definitions
**Estimate:** S

## Description

Define the fundamental ANSI control sequence introducers as Dart constants. These are the building blocks for all other ANSI sequences.

## Implementation

```dart
// ansi/codes.dart
const esc = '\x1b';
const csi = '\x1b[';
const osc = '\x1b]';
const dcs = '\x1bP';
const st = '\x1b\\';
const bel = '\x07';
const sgrEnd = 'm';
```

## Acceptance Criteria

- All 6 constants are defined and exported
- Unit tests verify exact byte values
- Pure string constants, no runtime computation
