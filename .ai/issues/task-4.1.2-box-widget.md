# Task 4.1.2: Box Widget (Border + Padding)

**Story:** Basic Widgets
**Estimate:** M

## Description

Implement the Box widget — a bordered container with optional title, padding, and background fill. Supports multiple border styles (single, double, rounded, thick).

## Implementation

```dart
enum BorderStyle { single, double, rounded, thick }

class Box extends Widget {
  final Widget? child;
  final BorderStyle borderStyle;
  final EdgeInsets padding;
  final String? title;
  final TextStyle? titleStyle;
  final TextStyle? borderStyle_;
  final Color? background;

  Size layout(Constraints constraints) {
    // border takes 1 cell on each edge, add padding, then child layout
  }

  void paint(PaintingContext context) {
    // draw border, fill background, render child in content area
  }
}
```

## Acceptance Criteria

- Border characters depend on style: single (┌┐└┘│─), double (╔╗╚╝║═), rounded (╭╮╰╯│─), thick (┏┓┗┛┃━)
- Title rendered in top border, centered or left-aligned, styled
- Padding is applied between border and child
- Background fill fills content area (not border)
- `layout()` accounts for border (2 cells) + padding + child size
- Unit tests: each border style, with/without title, with/without child
