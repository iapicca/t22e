# Task 4.3.1: Scrollable Viewport

**Story:** Interactive Widgets
**Estimate:** L

## Description

Implement a scrollable viewport widget. Wraps a child that may be larger than the visible area. Supports vertical and/or horizontal scrolling, scrollbar indicators, mouse wheel and keyboard control.

## Implementation

```dart
class Scrollable extends Model<Scrollable> {
  int scrollX, scrollY;
  final Widget child;
  final Axis axis; // vertical, horizontal, both
  final int viewportWidth, viewportHeight;

  (Scrollable, Cmd?) update(Msg msg) {
    // KeyMsg: Up/Down/Left/Right, PageUp/Down, Home/End
    // MouseWheel: scroll by N lines
  }

  View view() {
    // clip child content to viewport, offset by scroll position
    // render scrollbar indicators on edges
  }
}
```

## Acceptance Criteria

- Scroll offset is clamped to content bounds
- Scrollbar is shown as a thin track with indicator showing position
- Keyboard: arrows scroll by 1, PageUp/Down by viewport size, Home/End to extremes
- Mouse wheel scrolls by 3 lines (configurable)
- Scroll position is preserved on widget rebuild (unless content size changes)
- Smooth scroll (optional): animate to target position
- Unit tests: scroll clamping, scrollbar rendering, keyboard navigation
