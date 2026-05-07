# Task 4.4.4: Dialog/Overlay Widget

**Story:** Visual & Composite Widgets
**Estimate:** M

## Description

Implement a modal dialog widget that renders as an overlay with backdrop dimming, title bar, content area, and button bar. Supports Escape to dismiss and focus management.

## Implementation

```dart
class Dialog extends Model<Dialog> {
  String title;
  Widget content;
  List<DialogButton> buttons;
  bool dismissible; // Escape to dismiss

  (Dialog, Cmd?) update(Msg msg) {
    // KeyMsg: Enter → confirm, Escape → dismiss, Tab → cycle buttons
  }

  View view() {
    // render backdrop (dimmed)
    // render dialog box centered: title bar, content, button bar
  }
}
```

## Acceptance Criteria

- Backdrop: rest of screen dimmed (or cleared)
- Dialog box centered horizontally, 1/3 from top vertically
- Title bar with optional close '×' button
- Content area renders child widget
- Button bar: buttons arranged horizontally, focused button highlighted
- Enter/Return: activates focused button
- Escape: dismisses dialog (if dismissible)
- Tab/Shift+Tab: cycles focus through buttons
- Overlay compositing: dialog renders on top of existing screen content
- Animation: optional fade-in
