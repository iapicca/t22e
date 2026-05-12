import '../well_known.dart' show WellKnown;

/// The color model used: no color, ANSI, indexed 256, or true color RGB
enum ColorKind { noColor, ansi, indexed, rgb }

/// Supported terminal color profiles
enum ColorProfile { noColor, ansi16, indexed256, trueColor }

/// A terminal color value that can convert between color models
class Color {
  /// The color model kind
  final ColorKind kind;
  /// The packed color value: index for ansi/indexed, packed RGB for rgb
  final int value;

  /// TODO: Private constructor for creating Color instances internally
  // ignore: unused_element
  const Color._(this.kind, this.value);

  /// No color (default terminal color)
  const Color.noColor() : kind = ColorKind.noColor, value = 0;

  /// Standard ANSI color (0–15)
  const Color.ansi(int color)
      : assert(color >= 0 && color <= 15),
        kind = ColorKind.ansi,
        value = color;

  /// 256-color palette index (0–255)
  const Color.indexed(int index)
      : assert(index >= 0 && index <= 255),
        kind = ColorKind.indexed,
        value = index;

  /// True color via red, green, blue components (0–255 each)
  const Color.rgb(int r, int g, int b)
      : assert(r >= 0 && r <= 255),
        assert(g >= 0 && g <= 255),
        assert(b >= 0 && b <= 255),
        kind = ColorKind.rgb,
        value = (r << 16) | (g << 8) | b;

  /// Red component (0–255) for RGB colors
  int get red => (value >> 16) & 0xFF;
  /// Green component (0–255) for RGB colors
  int get green => (value >> 8) & 0xFF;
  /// Blue component (0–255) for RGB colors
  int get blue => value & 0xFF;

  /// The color profile this color belongs to
  ColorProfile get profile {
    switch (kind) {
      case ColorKind.noColor:
        return ColorProfile.noColor;
      case ColorKind.ansi:
        return ColorProfile.ansi16;
      case ColorKind.indexed:
        return ColorProfile.indexed256;
      case ColorKind.rgb:
        return ColorProfile.trueColor;
    }
  }

  /// Converts this color to the target color model (downgrades if needed)
  Color convert(ColorKind target) {
    if (target == kind) return this;

    switch (target) {
      case ColorKind.noColor:
        return const Color.noColor();
      case ColorKind.ansi:
        return _toAnsi();
      case ColorKind.indexed:
        return _toIndexed();
      case ColorKind.rgb:
        return this;
    }
  }

  Color _toAnsi() {
    switch (kind) {
      case ColorKind.noColor:
        return this;
      case ColorKind.ansi:
        return this;
      case ColorKind.indexed:
        return _indexedToAnsi(value);
      case ColorKind.rgb:
        return _toIndexed()._toAnsi();
    }
  }

  Color _toIndexed() {
    switch (kind) {
      case ColorKind.noColor:
        return this;
      case ColorKind.ansi:
        return this;
      case ColorKind.indexed:
        return this;
      case ColorKind.rgb:
        return _rgbToIndexed(red, green, blue);
    }
  }

  static Color _indexedToAnsi(int index) {
    if (index < 16) return Color.ansi(index);
    const map = [
      0, 4, 2, 6, 1, 5, 3, 7, 8, 12, 10, 14, 9, 13, 11, 15,
    ];
    final gray = index - 232;
    if (gray >= 0 && gray <= 23) {
      if (gray < 12) return const Color.ansi(8);
      return const Color.ansi(15);
    }
    final cube = index - 16;
    final cubeR = cube ~/ 36;
    final cubeG = (cube % 36) ~/ 6;
    final cubeB = cube % 6;
    final ansiR = cubeR < 3 ? 0 : 1;
    final ansiG = cubeG < 3 ? 0 : 1;
    final ansiB = cubeB < 3 ? 0 : 1;
    final ansiIdx = ansiR * 4 + ansiG * 2 + ansiB;
    final bright = (ansiR + ansiG + ansiB) >= 2;
    return Color.ansi(bright ? 8 + ansiIdx : map[ansiIdx]);
  }

  static Color _rgbToIndexed(int r, int g, int b) {
    var bestDist = double.infinity;
    var bestIdx = 0;

    for (var i = 16; i < 232; i++) {
      final cr = ((i - 16) ~/ 36) * 51;
      final cg = (((i - 16) % 36) ~/ 6) * 51;
      final cb = ((i - 16) % 6) * 51;
      final dist = _redmeanDistance(r, g, b, cr, cg, cb);
      if (dist < bestDist) {
        bestDist = dist;
        bestIdx = i;
      }
    }

    for (var i = 0; i < 24; i++) {
      final gray = i * 10 + 8;
      final dist = _redmeanDistance(r, g, b, gray, gray, gray);
      if (dist < bestDist) {
        bestDist = dist;
        bestIdx = 232 + i;
      }
    }

    return Color.indexed(bestIdx);
  }

  static double _redmeanDistance(int r1, int g1, int b1, int r2, int g2, int b2) {
    // sRGB redmean distance: perceptually weighted Euclidean distance
    final rBar = (r1 + r2) ~/ 2;
    final dr = r1 - r2;
    final dg = g1 - g2;
    final db = b1 - b2;
    return (2 + rBar / 256) * dr * dr + 4 * dg * dg + (2 + (255 - rBar) / 256) * db * db;
  }

  /// Builds the SGR escape sequence for this color (foreground or background)
  String sgrSequence({bool background = false}) {
    final prefix = background ? WellKnown.sgrBgExtended : WellKnown.sgrFgExtended;
    switch (kind) {
      case ColorKind.noColor:
        return background ? '${WellKnown.csi}${WellKnown.sgrBgReset}m' : '${WellKnown.csi}${WellKnown.sgrFgReset}m';
      case ColorKind.ansi:
        final off = background ? WellKnown.sgrBgAnsiBase : WellKnown.sgrFgAnsiBase;
        if (value < WellKnown.ansiDarkThreshold) return '${WellKnown.csi}${off + value}m';
        return '${WellKnown.csi}${off + WellKnown.ansiBrightOffset + value - WellKnown.ansiDarkThreshold}m';
      case ColorKind.indexed:
        return '${WellKnown.csi}$prefix;5;${value}m';
      case ColorKind.rgb:
        return '${WellKnown.csi}$prefix;2;$red;$green;${blue}m';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Color && kind == other.kind && value == other.value);

  @override
  int get hashCode => Object.hash(kind, value);

  @override
  String toString() => 'Color($kind, $value)';
}
