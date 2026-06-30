import 'dart:math' show max, min;

import 'offset.dart';

/// An immutable axis-aligned rectangle in terminal-cell coordinates.
///
/// [right] and [bottom] are exclusive, following half-open semantics.
extension type const Rect._((int left, int top, int right, int bottom) _value) {
  /// Creates a rectangle from left, top, right, and bottom values.
  const Rect(int left, int top, int right, int bottom)
    : this._((left, top, right, bottom));

  /// The left edge.
  int get left => _value.$1;

  /// The top edge.
  int get top => _value.$2;

  /// The exclusive right edge.
  int get right => _value.$3;

  /// The exclusive bottom edge.
  int get bottom => _value.$4;

  /// The rectangle width.
  int get width => right - left;

  /// The rectangle height.
  int get height => bottom - top;

  /// True when the rectangle has zero or negative area.
  bool get isEmpty => width <= 0 || height <= 0;

  /// True when [point] lies inside the half-open rectangle.
  bool contains(Offset point) =>
      point.x >= left && point.x < right && point.y >= top && point.y < bottom;

  /// Returns the overlapping rectangle, or a zero-area rect if there is none.
  Rect intersect(Rect other) => Rect(
    max(left, other.left),
    max(top, other.top),
    min(right, other.right),
    min(bottom, other.bottom),
  );
}
