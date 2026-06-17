/// Box-drawing glyphs, border sets, and UI character constants.
final class WidgetChars {
  WidgetChars._();

  /// Full block character for solid fill.
  static const String charFullBlock = '\u2588';

  /// Light shade character for partial fill.
  static const String charLightShade = '\u2591';

  /// Bullet character for lists.
  static const String charBullet = '\u2022';

  /// Check mark character.
  static const String charCheckMark = '\u2713';

  /// Right-pointing triangle for sort indicators.
  static const String charRightTriangle = '\u25B6';

  /// Up-pointing triangle for sort indicators.
  static const String charUpTriangle = '\u25B2';

  /// Down-pointing triangle for sort indicators.
  static const String charDownTriangle = '\u25BC';

  /// Single-line border characters (vertical, horizontal, TL, TR, BL, BR).
  static const String borderSingle = '│─┌┐└┘';

  /// Double-line border characters.
  static const String borderDouble = '║═╔╗╚╝';

  /// Rounded-corner border characters.
  static const String borderRounded = '│─╭╮╰╯';

  /// Heavy/thick border characters.
  static const String borderThick = '┃━┏┓┗┛';
}
