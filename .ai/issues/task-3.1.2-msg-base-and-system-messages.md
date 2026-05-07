# Task 3.1.2: Msg Base Class and System Messages

**Story:** TEA Event Loop
**Estimate:** M

## Description

Define the Msg type hierarchy. System messages handle lifecycle events (quit, interrupt, suspend, resume, window resize). Input messages wrap parser events. Custom messages are user-defined.

## Implementation

```dart
abstract class Msg {}

// System messages
class QuitMsg extends Msg {}
class InterruptMsg extends Msg {}
class SuspendMsg extends Msg {}
class ResumeMsg extends Msg {}
class WindowSizeMsg extends Msg { final int width, height; }
class ClearScreenMsg extends Msg {}
class EnterAltScreenMsg extends Msg {}
class ExitAltScreenMsg extends Msg {}
class HideCursorMsg extends Msg {}
class ShowCursorMsg extends Msg {}
class PrintLineMsg extends Msg { final String line; }
class ExecMsg extends Msg { final String exe; final List<String> args; }

// Input messages (bridge from parser events)
// KeyMsg, MouseMsg, FocusMsg, BlurMsg, PasteMsg
```

## Acceptance Criteria

- All system messages are defined with clear purpose
- Input messages wrap parser events but are independent types (no parser dependency in model)
- Custom messages can extend Msg without modifying core
- Messages are immutable
- `==` and `hashCode` for equality comparison (useful in tests)
