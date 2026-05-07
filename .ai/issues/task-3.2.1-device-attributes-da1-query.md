# Task 3.2.1: Device Attributes (DA1) Query

**Story:** Terminal Capability Detection
**Estimate:** M

## Description

Implement the first probe in the pipeline: query terminal identity via Primary Device Attributes (CSI c). Parse the response to determine terminal type and supported features.

## Implementation

```dart
class Da1Result {
  final int terminalId;
  final List<int> supportedAttributes; // e.g., [1, 2, 4, 6, 9, 18, 22]
}

QueryResult<Da1Result> probeDa1(TerminalIo io) {
  io.write('\x1b[c'); // or \x1b[0c
  // wait for response with timeout
  // parse \x1b[?1;2c → terminalId=1, attrs=[2]
}
```

## Acceptance Criteria

- Sends DA1 query and parses response (e.g., `\x1b[?1;2c`)
- Distinguishes between VT100, VT220, VT320, VT420, xterm, kitty, etc.
- Returns `Unavailable` on timeout (no response within 1 second)
- Returns terminal ID and supported attribute flags
- Used by later probes to determine available features
- Unit tests: mock DA1 responses for known terminals
