/// An immutable integer offset in terminal-cell coordinates.
extension type const Offset._((int x, int y) _value) {
  /// Creates an offset from explicit x and y values.
  const Offset(int x, int y) : this._((x, y));

  /// The x component.
  int get x => _value.$1;

  /// The y component.
  int get y => _value.$2;

  /// Returns a new offset offset by [other].
  Offset operator +(Offset other) => Offset(x + other.x, y + other.y);
}
