# Task 4.4.2: Spinner Widget

**Story:** Visual & Composite Widgets
**Estimate:** S

## Description

Implement an animated spinner widget with configurable frame sets. Default braille spinner (⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏), plus common alternatives.

## Implementation

```dart
class Spinner extends Model<Spinner> {
  int _frame = 0;
  final List<String> frames;
  final Duration interval;
  final String? label;

  (Spinner, Cmd?) update(Msg msg) {
    // TickMsg: advance to next frame
  }

  View view() {
    // render current frame character + optional label
  }
}
```

## Acceptance Criteria

- Default frame set: braille dots (⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏)
- Alternative presets: line (─╌╱╳╲), dots (⡀⡄⡆⡇⣇⣧⣷⣿), clock (🕐-🕐)
- Animation driven by TickMsg from the event loop
- Configurable speed (default 80ms per frame)
- Optional label displayed next to spinner
- Automatically starts/stops with model lifecycle
