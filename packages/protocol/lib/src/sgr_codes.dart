/// SGR (Select Graphic Rendition) attribute codes, color base indices,
/// and extended color selectors.
final class SgrCodes {
  SgrCodes._();

  /// Reset all SGR attributes.
  static const int sgrReset = 0;

  /// Bold / increased intensity.
  static const int sgrBold = 1;

  /// Faint / decreased intensity.
  static const int sgrFaint = 2;

  /// Italicized text.
  static const int sgrItalic = 3;

  /// Underlined text.
  static const int sgrUnderline = 4;

  /// Blinking text.
  static const int sgrBlink = 5;

  /// Reverse/inverse video.
  static const int sgrReverse = 7;

  /// Strikethrough text.
  static const int sgrStrikethrough = 9;

  /// Overlined text.
  static const int sgrOverline = 53;

  /// Turn off bold and faint.
  static const int sgrNoBoldFaint = 22;

  /// Turn off italic.
  static const int sgrNoItalic = 23;

  /// Turn off underline.
  static const int sgrNoUnderline = 24;

  /// Turn off blink.
  static const int sgrNoBlink = 25;

  /// Turn off reverse.
  static const int sgrNoReverse = 27;

  /// Turn off strikethrough.
  static const int sgrNoStrikethrough = 29;

  /// Turn off overline.
  static const int sgrNoOverline = 55;

  /// Foreground ANSI 16-color base index.
  static const int sgrFgAnsiBase = 30;

  /// Background ANSI 16-color base index.
  static const int sgrBgAnsiBase = 40;

  /// Foreground bright ANSI base index.
  static const int sgrFgBrightBase = 90;

  /// Background bright ANSI base index.
  static const int sgrBgBrightBase = 100;

  /// Extended foreground color prefix.
  static const int sgrFgExtended = 38;

  /// Extended background color prefix.
  static const int sgrBgExtended = 48;

  /// Reset foreground to default.
  static const int sgrFgReset = 39;

  /// Reset background to default.
  static const int sgrBgReset = 49;

  /// Indexed 256-color selector for extended sequences.
  static const int sgrColor256 = 5;

  /// RGB color selector for extended sequences.
  static const int sgrColorRgb = 2;
}
