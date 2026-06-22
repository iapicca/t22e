/// DA1 (Device Attributes 1) terminal identification and feature codes.
final class Da1Codes {
  Da1Codes._();

  /// Default DA1 response (no attributes).
  static const int da1TerminalIdDefault = 0;

  /// DA1 attribute: 256-color support.
  static const int da1AttrIndexed256 = 22;

  /// DA1 attribute: truecolor support.
  static const int da1AttrTrueColor = 28;
}
