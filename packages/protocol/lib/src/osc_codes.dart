/// OSC (Operating System Command) PSN codes.
final class OscCodes {
  OscCodes._();

  /// OSC 0: set window and icon title.
  static const int oscTitle = 0;

  /// OSC 8: hyperlink specification.
  static const int oscHyperlink = 8;

  /// OSC 10: query/set foreground color.
  static const int oscFgQuery = 10;

  /// OSC 11: query/set background color.
  static const int oscBgQuery = 11;

  /// OSC 52: clipboard read/write.
  static const int oscClipboard = 52;
}
