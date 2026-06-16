import 'dart:ffi';
import 'dart:io';

import 'pointer_extensions.dart';

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

  static bool get _isMacOS => Platform.operatingSystem == 'macos';

  /// Size of tcflag_t in bytes (unsigned long on macOS, unsigned int on Linux).
  static int get _tcflagSize => _isMacOS ? 8 : 4;

  /// Size of termios struct in bytes.
  static int get termiosStructSize => _isMacOS ? 72 : 60;

  /// Byte offset of c_iflag in termios struct.
  static int get termiosOffsetIFlag => 0;

  /// Byte offset of c_oflag in termios struct.
  static int get termiosOffsetOFlag => _tcflagSize;

  /// Byte offset of c_cflag in termios struct.
  static int get termiosOffsetCFlag => _tcflagSize * 2;

  /// Byte offset of c_lflag in termios struct.
  static int get termiosOffsetLFlag => _tcflagSize * 3;

  /// Starting byte offset of c_cc array.
  static int get _ccOffset => _isMacOS ? 32 : 17;

  /// VMIN index within c_cc array.
  static int get _vminIndex => _isMacOS ? 16 : 6;

  /// VTIME index within c_cc array.
  static int get _vtimeIndex => _isMacOS ? 17 : 5;

  /// Byte offset of VMIN in c_cc array.
  static int get termiosOffsetCCMin => _ccOffset + _vminIndex;

  /// Byte offset of VTIME in c_cc array.
  static int get termiosOffsetCCTime => _ccOffset + _vtimeIndex;

  /// Value for VMIN in raw mode (read at least 1 byte).
  static const int termiosVminRaw = 1;

  /// Value for VTIME in raw mode (no timeout).
  static const int termiosVtimeRaw = 0;

  /// TCSANOW: apply termios changes immediately.
  static const int tcsaNow = 0;

  /// File descriptor for stdin.
  static const int stdinFd = 0;

  /// Reads a tcflag_t value from [buf] at [offset] using platform-appropriate width.
  static int readFlag(Pointer<Uint8> buf, int offset) =>
      _isMacOS ? buf.read64(offset) : buf.read32(offset);

  /// Writes a tcflag_t [value] to [buf] at [offset] using platform-appropriate width.
  static void writeFlag(Pointer<Uint8> buf, int offset, int value) {
    if (_isMacOS) {
      buf.write64(offset, value);
    } else {
      buf.write32(offset, value);
    }
  }
}
