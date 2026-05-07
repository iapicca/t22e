# Task 2.1.3: Geometry Types (Rect, Point, Insets)

**Story:** 2D Cell Grid (Surface)
**Estimate:** S

## Description

Define the geometry primitives used throughout the rendering pipeline: `Rect`, `Point`, and `Insets`. These provide clear, typed representations of positions, bounding boxes, and padding/margin.

## Implementation

```dart
class Point {
  final int x, y;
  Point(this.x, this.y);
  Point operator +(Point other) => Point(x + other.x, y + other.y);
}

class Rect {
  final int x, y, width, height;
  bool contains(Point p) => ...;
  Rect inset(Insets i) => ...;
}

class Insets {
  final int left, top, right, bottom;
  Insets.all(int value);
  Insets.symmetric({int horizontal, int vertical});
}
```

## Acceptance Criteria

- Point has + operator and distance calculation
- Rect has: contains, intersection, union, inset, inflate
- Rect edges: left= x, top= y, right= x+width, bottom= y+height
- Insets can be constructed via named constructors (all, symmetric, only, fromLTRB)
- All classes are immutable with `==` and `hashCode`
- No negative width/height in Rect (clamp to 0)
