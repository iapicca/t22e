import 'dart:ffi';

/// termios structure flags, offsets, and raw mode configuration.
abstract base class Termios {
  const Termios();

  /// ECHO flag: enable input echo.
  static const int termiosEcho = 0x00000008;

  /// ICANON flag: canonical (line) mode.
  static const int termiosICanon = 0x00000002;

  /// ISIG flag: signal handling (SIGINT etc.).
  static const int termiosISig = 0x00000001;

  /// IEXTEN flag: extended input processing.
  static const int termiosIExten = 0x00008000;

  /// Value for VMIN in raw mode (read at least 1 byte).
  static const int termiosVminRaw = 1;

  /// Value for VTIME in raw mode (no timeout).
  static const int termiosVtimeRaw = 0;

  /// TCSANOW: apply termios changes immediately.
  static const int tcsaNow = 0;

  /// File descriptor for stdin.
  static const int stdinFd = 0;

  /// Size of termios struct in bytes.
  int get termiosStructSize;

  /// Byte offset of c_iflag in termios struct.
  int get termiosOffsetIFlag;

  /// Byte offset of c_oflag in termios struct.
  int get termiosOffsetOFlag;

  /// Byte offset of c_cflag in termios struct.
  int get termiosOffsetCFlag;

  /// Byte offset of c_lflag in termios struct.
  int get termiosOffsetLFlag;

  /// Byte offset of VMIN in c_cc array.
  int get termiosOffsetCCMin;

  /// Byte offset of VTIME in c_cc array.
  int get termiosOffsetCCTime;

  /// Reads a tcflag_t value from [buf] at [offset] using platform-appropriate width.
  int readFlag(Pointer<Uint8> buf, int offset);

  /// Writes a tcflag_t [value] to [buf] at [offset] using platform-appropriate width.
  void writeFlag(Pointer<Uint8> buf, int offset, int value);
}
