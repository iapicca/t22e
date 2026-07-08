import 'package:meta/meta.dart' show internal;

/// Color-palette and SGR byte/value constants used by `color_extensions.dart`.
///
/// File-scoped: every consumer lives in `color_extensions.dart`. When a
/// constant gains a second consumer it is promoted to `t22eSymbols`.
@internal
final class ColorExtensionsSymbols {
  const ColorExtensionsSymbols._();

  /// Lower bound of the 256-color cube region (index 16).
  static const int indexedColorCubeStart = 16;

  /// Start index of the 256-color grayscale ramp (index 232).
  static const int indexedColorGrayStart = 232;

  /// Number of entries in the 256-color grayscale ramp.
  static const int indexedColorGrayCount = 24;

  /// Edge length of the 256-color 6x6x6 cube.
  static const int indexedColorCubeSize = 6;

  /// Maximum value of an RGB component (255).
  static const int rgbComponentMax = 255;

  /// Step between adjacent values in the 6x6x6 color cube.
  static const int cubeStep =
      rgbComponentMax ~/ (indexedColorCubeSize - 1);

  /// Step between adjacent entries in the grayscale ramp.
  static const int grayStep = 10;

  /// Base brightness of the grayscale ramp.
  static const int grayBase = 8;

  /// SGR base parameter for the ANSI 16-color foreground range (30–37).
  static const int sgrFgAnsiBase = 30;

  /// SGR base parameter for the ANSI 16-color background range (40–47).
  static const int sgrBgAnsiBase = 40;

  /// Offset added to a base for the bright (90–97 / 100–107) ranges.
  static const int sgrBrightOffset = 60;

  /// Threshold below which an ANSI code uses the dark range; brights start at 8.
  static const int sgrAnsiDarkThreshold = 8;

  /// SGR parameter prefix selecting an extended foreground (`38`).
  static const int sgrExtendedFg = 38;

  /// SGR parameter prefix selecting an extended background (`48`).
  static const int sgrExtendedBg = 48;

  /// SGR parameter choosing the 256-color palette within an extended prefix.
  static const int sgrColor256 = 5;

  /// SGR parameter choosing the 24-bit RGB triple within an extended prefix.
  static const int sgrColorRgb = 2;
}