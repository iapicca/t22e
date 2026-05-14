import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:protocol/protocol.dart' show Defaults;

part 'geometry.freezed.dart';

/// A 2D point (x=column, y=row) on the terminal grid.
@freezed
abstract class Point with _$Point {
  const Point._();

  const factory Point(int x, int y) = _Point;

  /// Adds two points component-wise.
  Point operator +(Point other) => Point(x + other.x, y + other.y);
  /// Subtracts two points component-wise.
  Point operator -(Point other) => Point(x - other.x, y - other.y);
}

/// An axis-aligned rectangle.
@freezed
abstract class Rect with _$Rect {
  const Rect._();

  @Assert('width >= 0', 'width must be non-negative')
  @Assert('height >= 0', 'height must be non-negative')
  const factory Rect(int x, int y, int width, int height) = _Rect;

  factory Rect.fromLTWH(int left, int top, int w, int h) => Rect(left, top, w, h);

  /// Left edge column.
  int get left => x;
  /// Top edge row.
  int get top => y;
  /// Right edge column (exclusive).
  int get right => x + width;
  /// Bottom edge row (exclusive).
  int get bottom => y + height;

  /// True if either dimension is zero.
  bool get isEmpty => width == 0 || height == 0;

  /// True if the point lies inside this rectangle.
  bool contains(Point p) =>
      p.x >= left && p.x < right && p.y >= top && p.y < bottom;

  /// Returns the intersection of two rectangles.
  Rect intersect(Rect other) {
    final l = left > other.left ? left : other.left;
    final t = top > other.top ? top : other.top;
    final r = right < other.right ? right : other.right;
    final b = bottom < other.bottom ? bottom : other.bottom;
    if (l >= r || t >= b) return const Rect(0, 0, 0, 0);
    return Rect(l, t, r - l, b - t);
  }

  /// Returns the smallest rectangle containing both.
  Rect union(Rect other) {
    final l = left < other.left ? left : other.left;
    final t = top < other.top ? top : other.top;
    final r = right > other.right ? right : other.right;
    final b = bottom > other.bottom ? bottom : other.bottom;
    return Rect(l, t, r - l, b - t);
  }

  /// Shrinks the rectangle by the given insets.
  Rect inset(Insets insets) {
    final l = left + insets.left;
    final t = top + insets.top;
    final r = right - insets.right;
    final b = bottom - insets.bottom;
    if (l >= r || t >= b) return const Rect(0, 0, 0, 0);
    return Rect(l, t, r - l, b - t);
  }

  /// Expands the rectangle by dx/dy (clamped to avoid overflow).
  Rect inflate(int dx, int dy) {
    final l = left - dx;
    final t = top - dy;
    final r = (right + dx).clamp(l, Defaults.unbounded);
    final b = (bottom + dy).clamp(t, Defaults.unbounded);
    return Rect(l, t, r - l, b - t);
  }
}

/// Offsets for each edge (used for padding and margins).
@freezed
abstract class Insets with _$Insets {
  const Insets._();

  const factory Insets(int left, int top, int right, int bottom) = _Insets;

  /// Same inset on all four sides.
  factory Insets.all(int value) => Insets(value, value, value, value);

  /// Symmetric inset: horizontal and vertical separately.
  factory Insets.symmetric({int horizontal = 0, int vertical = 0}) =>
      Insets(horizontal, vertical, horizontal, vertical);

  /// Specify individual sides.
  factory Insets.only({int left = 0, int top = 0, int right = 0, int bottom = 0}) =>
      Insets(left, top, right, bottom);

  /// Creates from left, top, right, bottom values.
  factory Insets.fromLTRB(int l, int t, int r, int b) => Insets(l, t, r, b);

  /// Total horizontal inset (left + right).
  int get horizontal => left + right;
  /// Total vertical inset (top + bottom).
  int get vertical => top + bottom;

  /// Adds two insets component-wise.
  Insets add(Insets other) => Insets(
    left + other.left,
    top + other.top,
    right + other.right,
    bottom + other.bottom,
  );
}
