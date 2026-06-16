/// termios structure flags, offsets, and raw mode configuration.
final class Termios {
  Termios._();

  /// ECHO flag: enable input echo.
  static const int termiosEcho = 0x00000008;

  /// ICANON flag: canonical (line) mode.
  static const int termiosICanon = 0x00000002;

  /// ISIG flag: signal handling (SIGINT etc.).
  static const int termiosISig = 0x00000001;

  /// IEXTEN flag: extended input processing.
  static const int termiosIExten = 0x00008000;

  /// Size of termios struct in bytes (on most platforms).
  static const int termiosStructSize = 60;

  /// Byte offset of c_iflag in termios struct.
  static const int termiosOffsetIFlag = 0;

  /// Byte offset of c_oflag in termios struct.
  static const int termiosOffsetOFlag = 4;

  /// Byte offset of c_cflag in termios struct.
  static const int termiosOffsetCFlag = 8;

  /// Byte offset of c_lflag in termios struct.
  static const int termiosOffsetLFlag = 12;

  /// Byte offset of VMIN in c_cc array.
  static const int termiosOffsetCCMin = 17;

  /// Byte offset of VTIME in c_cc array.
  static const int termiosOffsetCCTime = 18;

  /// Value for VMIN in raw mode (read at least 1 byte).
  static const int termiosVminRaw = 1;

  /// Value for VTIME in raw mode (no timeout).
  static const int termiosVtimeRaw = 0;

  /// TCSANOW: apply termios changes immediately.
  static const int tcsaNow = 0;

  /// File descriptor for stdin.
  static const int stdinFd = 0;
}
