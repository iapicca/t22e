import '../well_known.dart' show WellKnown;

/// A 2D integer point (x=column, y=row)
class Point {
  final int x;
  final int y;

  const Point(this.x, this.y);

  Point operator +(Point other) => Point(x + other.x, y + other.y);
  Point operator -(Point other) => Point(x - other.x, y - other.y);

  Point withX(int x) => Point(x, y);
  Point withY(int y) => Point(x, y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Point && x == other.x && y == other.y);

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'Point($x, $y)';
}

/// An integer rectangle with position and size (x, y, width, height)
class Rect {
  final int x;
  final int y;
  final int width;
  final int height;

  const Rect(this.x, this.y, this.width, this.height)
      : assert(width >= 0),
        assert(height >= 0);

  const Rect.fromLTWH(int left, int top, int w, int h)
      : x = left,
        y = top,
        width = w,
        height = h;

  int get left => x;
  int get top => y;
  int get right => x + width;
  int get bottom => y + height;

  bool get isEmpty => width == 0 || height == 0;

  bool contains(Point p) =>
      p.x >= left && p.x < right && p.y >= top && p.y < bottom;

  Rect intersect(Rect other) {
    final l = left > other.left ? left : other.left;
    final t = top > other.top ? top : other.top;
    final r = right < other.right ? right : other.right;
    final b = bottom < other.bottom ? bottom : other.bottom;
    if (l >= r || t >= b) return const Rect(0, 0, 0, 0);
    return Rect(l, t, r - l, b - t);
  }

  Rect union(Rect other) {
    final l = left < other.left ? left : other.left;
    final t = top < other.top ? top : other.top;
    final r = right > other.right ? right : other.right;
    final b = bottom > other.bottom ? bottom : other.bottom;
    return Rect(l, t, r - l, b - t);
  }

  Rect inset(Insets insets) {
    final l = left + insets.left;
    final t = top + insets.top;
    final r = right - insets.right;
    final b = bottom - insets.bottom;
    if (l >= r || t >= b) return const Rect(0, 0, 0, 0);
    return Rect(l, t, r - l, b - t);
  }

  Rect inflate(int dx, int dy) {
    final l = left - dx;
    final t = top - dy;
    final r = (right + dx).clamp(l, WellKnown.unbounded);
    final b = (bottom + dy).clamp(t, WellKnown.unbounded);
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

/// Padding or margin insets for a rectangle (left, top, right, bottom)
class Insets {
  final int left;
  final int top;
  final int right;
  final int bottom;

  const Insets(this.left, this.top, this.right, this.bottom);

  const Insets.all(int value)
      : left = value,
        top = value,
        right = value,
        bottom = value;

  const Insets.symmetric({int horizontal = 0, int vertical = 0})
      : left = horizontal,
        right = horizontal,
        top = vertical,
        bottom = vertical;

  const Insets.only({int left = 0, int top = 0, int right = 0, int bottom = 0})
      : this(left, top, right, bottom);

  const Insets.fromLTRB(int l, int t, int r, int b) : this(l, t, r, b);

  int get horizontal => left + right;
  int get vertical => top + bottom;

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
