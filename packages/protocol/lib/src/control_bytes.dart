/// Terminal control bytes: C0/C1, escape sequence introducers,
/// entry bytes, and parameter delimiters.
final class ControlBytes {
  ControlBytes._();

  /// ESC control byte.
  static const int escapeByte = 0x1B;

  /// BEL (bell) control byte.
  static const int bellByte = 0x07;

  /// LF (line feed) control byte.
  static const int lineFeedByte = 0x0A;

  /// CR (carriage return) control byte.
  static const int carriageReturnByte = 0x0D;

  /// ST (string terminator) byte.
  static const int stringTerminatorByte = 0x9C;

  /// CSI introducer byte (8-bit form).
  static const int csiIntroducerByte = 0x9B;

  /// OSC introducer byte (8-bit form).
  static const int oscIntroducerByte = 0x9D;

  /// DCS introducer byte (8-bit form).
  static const int dcsIntroducerByte = 0x90;

  /// ESC character string.
  static const String esc = '\x1b';

  /// CSI sequence prefix string.
  static const String csi = '\x1b[';

  /// OSC sequence prefix string.
  static const String osc = '\x1b]';

  /// DCS sequence prefix string.
  static const String dcs = '\x1bP';

  /// String terminator sequence.
  static const String st = '\x1b\\';

  /// BEL character string.
  static const String bel = '\x07';

  /// '[' byte that starts a CSI sequence.
  static const int csiEntryByte = 0x5B;

  /// ']' byte that starts an OSC sequence.
  static const int oscEntryByte = 0x5D;

  /// 'P' byte that starts a DCS sequence.
  static const int dcsEntryByte = 0x50;

  /// '\' byte that ends a DCS sequence.
  static const int dcsStByte = 0x5C;

  /// 'O' byte that starts an SS3 sequence.
  static const int ss3Byte = 0x4F;

  /// '?' prefix for DEC private parameters.
  static const int decPrivatePrefix = 0x3F;

  /// Semicolon byte separating CSI parameters.
  static const int semicolonByte = 0x3B;

  /// '<' byte prefixing extended CSI intermediate.
  static const int intermediatePrefixByte = 0x3C;

  /// 8-bit shift value.
  static const int bitShift8 = 8;

  /// 16-bit shift value.
  static const int bitShift16 = 16;

  /// 24-bit shift value.
  static const int bitShift24 = 24;

  /// Mask for extracting a single byte.
  static const int byteMask = 0xFF;
}
