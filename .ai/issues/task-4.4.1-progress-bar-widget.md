# Task 4.4.1: Progress Bar Widget

**Story:** Visual & Composite Widgets
**Estimate:** S

## Description

Implement a progress bar widget with determinate (percentage) and indeterminate (animated) modes.

## Implementation

```dart
class ProgressBar extends Model<ProgressBar> {
  double? fraction; // null = indeterminate, 0.0-1.0 = determinate
  String? label;
  TextStyle style;

  (ProgressBar, Cmd?) update(Msg msg) {
    // TickMsg: animate indeterminate bar
  }

  View view() {
    // render progress bar: [#####····] 60%
    // indeterminate: [===-=--=---=] animated
  }
}
```

## Acceptance Criteria

- Determinate: filled portion proportional to fraction
- Indeterminate: moving bar/pulse animation (animated via TickMsg)
- Optional label shown inside or next to bar
- Customizable fill char, empty char, colors
- Configurable width (default: stretch to container)
