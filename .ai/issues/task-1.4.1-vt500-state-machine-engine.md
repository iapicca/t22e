# Task 1.4.1: VT500 State Machine Engine

**Story:** Input Parser (VT500)
**Estimate:** XL

## Description

Implement the core VT500 13-state state machine that processes bytes one-at-a-time. This is the most complex and critical piece of the parser. States: GROUND, ESCAPE, ESCAPE_INTERMEDIATE, CSI_ENTRY, CSI_PARAM, CSI_INTERMEDIATE, CSI_IGNORE, OSC_STRING, DCS_ENTRY, DCS_PARAM, DCS_INTERMEDIATE, DCS_IGNORE, DCS_PASSTHROUGH.

## Implementation

```dart
class Vt500Engine {
  int _state = State.ground;
  final _params = <int>[];
  final _intermediates = <int>[];
  StringBuffer _oscBuffer = StringBuffer();

  SequenceData? advance(int byte) {
    // transition per state table
    // emit SequenceData when complete sequence is recognized
  }
}
```

## Acceptance Criteria

- All 13 states are implemented with correct transitions per VT500 spec
- State table is a dense 2D array or switch-based (optimized for performance)
- Emits `CharData`, `CsiSequenceData`, `OscSequenceData`, `DcsSequenceData`, `EscSequenceData`
- Handles invalid bytes gracefully (transition to GROUND, emit ErrorEvent)
- Processes single bytes at O(1) per byte
- Fuzz-tested against known VT500 sequences
- Performance target: >1M bytes/sec processing
