import 'package:protocol/protocol.dart' show Defaults;

/// A 2D point (x=column, y=row) on the terminal grid.
class Point {
  /// Column (0-based).
  final int x;
  /// Row (0-based).
  final int y;

  const Point(this.x, this.y);

  /// Adds two points component-wise.
  Point operator +(Point other) => Point(x + other.x, y + other.y);
  /// Subtracts two points component-wise.
  Point operator -(Point other) => Point(x - other.x, y - other.y);

  /// Returns a copy with x replaced.
  Point withX(int x) => Point(x, y);
  /// Returns a copy with y replaced.
  Point withY(int y) => Point(x, y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Point && x == other.x && y == other.y);

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'Point($x, $y)';
}

/// An axis-aligned rectangle.
class Rect {
  /// Left edge column.
  final int x;
  /// Top edge row.
  final int y;
  /// Width in columns.
  final int width;
  /// Height in rows.
  final int height;

  const Rect(this.x, this.y, this.width, this.height)
    : assert(width >= 0),
      assert(height >= 0);

  /// Creates a Rect from left, top, width, height.
  const Rect.fromLTWH(int left, int top, int w, int h)
    : x = left,
      y = top,
      width = w,
      height = h;

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Rect &&
          x == other.x &&
          y == other.y &&
          width == other.width &&
          height == other.height);

  @override
  int get hashCode => Object.hash(x, y, width, height);

  @override
  String toString() => 'Rect($x, $y, $width, $height)';
}

/// Offsets for each edge (used for padding and margins).
class Insets {
  /// Left inset.
  final int left;
  /// Top inset.
  final int top;
  /// Right inset.
  final int right;
  /// Bottom inset.
  final int bottom;

  const Insets(this.left, this.top, this.right, this.bottom);

  /// Same inset on all four sides.
  const Insets.all(int value)
    : left = value,
      top = value,
      right = value,
      bottom = value;

  /// Symmetric inset: horizontal and vertical separately.
  const Insets.symmetric({int horizontal = 0, int vertical = 0})
    : left = horizontal,
      right = horizontal,
      top = vertical,
      bottom = vertical;

  /// Specify individual sides.
  const Insets.only({int left = 0, int top = 0, int right = 0, int bottom = 0})
    : this(left, top, right, bottom);

  /// Creates from left, top, right, bottom values.
  const Insets.fromLTRB(int l, int t, int r, int b) : this(l, t, r, b);

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Insets &&
          left == other.left &&
          top == other.top &&
          right == other.right &&
          bottom == other.bottom);

  @override
  int get hashCode => Object.hash(left, top, right, bottom);

  @override
  String toString() => 'Insets($left, $top, $right, $bottom)';
}
