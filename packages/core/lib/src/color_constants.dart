/// Color profile metadata, indexed palette offsets, link color,
/// and RGB component constants.
final class ColorConstants {
  ColorConstants._();

  /// Total indexed 256-color palette entries.
  static const int colorProfileIndexedCount = 256;

  /// Starting index of the 6x6x6 color cube.
  static const int indexedColorCubeStart = 16;

  /// Size of one dimension of the color cube.
  static const int indexedColorCubeSize = 6;

  /// Starting index of the grayscale ramp.
  static const int indexedColorGrayStart = 232;

  /// Number of grayscale ramp entries.
  static const int indexedColorGrayCount = 24;

  /// Offset from standard to bright ANSI SGR param.
  static const int ansiBrightOffset = 60;

  /// Maximum valid ANSI color index.
  static const int ansiColorMax = 15;

  /// Threshold below which ANSI colors are "dark".
  static const int ansiDarkThreshold = 8;

  /// Red component of default link color.
  static const int linkColorRed = 0;

  /// Green component of default link color.
  static const int linkColorGreen = 102;

  /// Blue component of default link color.
  static const int linkColorBlue = 204;

  /// Maximum value for an RGB component.
  static const int rgbComponentMax = 255;
}
