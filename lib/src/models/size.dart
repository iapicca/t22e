import 'offset.dart';

/// An immutable integer size in terminal-cell units.
extension type const Size._((int width, int height) _value) implements Offset {
  /// Creates a size from explicit width and height values.
  const Size(int width, int height) : this._((width, height));

  /// The width.
  int get width => _value.$1;

  /// The height.
  int get height => _value.$2;

  /// The total number of cells.
  int get area => width * height;

  /// True when either dimension is zero.
  bool get isEmpty => width == 0 || height == 0;

  /// Returns a new size clamped to non-negative values and [maxSize].
  Size constrain(Size maxSize) =>
      Size(width.clamp(0, maxSize.width), height.clamp(0, maxSize.height));
}
