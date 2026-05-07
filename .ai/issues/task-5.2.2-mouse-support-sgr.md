# Task 5.2.2: Mouse Support (SGR)

**Story:** Advanced Input
**Estimate:** M

## Description

Implement SGR mouse mode. Enable on start, disable on exit. Supports click, release, drag, and wheel events. Coordinates reported in (row, col) format.

## Implementation

```dart
// Enable: \x1b[?1000h\x1b[?1002h\x1b[?1006h
// Disable: \x1b[?1000l\x1b[?1002l\x1b[?1006l
//
// SGR event: \x1b[<button;x;y{M/m}
// button: 0=left, 1=middle, 2=right, 32=drag, 64=wheel_up, 65=wheel_down
// M=press, m=release

enum MouseButton { left, middle, right, wheelUp, wheelDown }
enum MouseAction { press, release, drag, move }
```

## Acceptance Criteria

- Mouse events parsed from SGR sequences (CSI < ... M/m)
- Button, action, coordinates extracted correctly
- Drag tracking (1002 mode): button down + move = drag events
- Wheel events: up/down produce scroll events (not click)
- Coordinates: 1-based, clamped to terminal dimensions
- Graceful degradation: mouse events not available in basic terminals
- Mouse mode is enabled/disabled with terminal lifecycle
