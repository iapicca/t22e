# Task 1.4.3: ESC/OSC/DCS Semantic Parsers

**Story:** Input Parser (VT500)
**Estimate:** L

## Description

Implement semantic parsers for ESC (Escape), OSC (Operating System Command), and DCS (Device Control String) sequences.

- **ESC Parser**: SS3 sequences (F-keys from xterm), terminal reset, screen save/restore
- **OSC Parser**: Color queries (OSC 10/11), clipboard (OSC 52), terminal title (OSC 0/1/2), hyperlinks (OSC 8), notifications (OSC 9)
- **DCS Parser**: Kitty graphics protocol (stub), other device control sequences

## Implementation

```dart
class EscParser { Event? parse(EscSequenceData data); }
class OscParser { Event? parse(OscSequenceData data); }
class DcsParser { Event? parse(DcsSequenceData data); }
```

## Acceptance Criteria

- ESC Parser: SS3 F-keys, RIS, DECSC/DECRC
- OSC Parser: color query responses, clipboard content, title changes, hyperlink IDs
- DCS Parser: Kitty graphics protocol (basic recognition, stub implementation)
- Unknown sequences produce UnhandledEvent
- Unit tests with captured sequences from xterm, kitty, Windows Terminal
