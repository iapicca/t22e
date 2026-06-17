import 'dart:ffi';

import 'pointer_extensions.dart';
import 'termios.dart';

/// macOS termios layout (tcflag_t = 8 bytes, struct = 72 bytes).
final class MacosTermios extends Termios {
  const MacosTermios();

  @override
  int get termiosStructSize => 72;

  @override
  int get termiosOffsetIFlag => 0;

  @override
  int get termiosOffsetOFlag => 8;

  @override
  int get termiosOffsetCFlag => 16;

  @override
  int get termiosOffsetLFlag => 24;

  @override
  int get termiosOffsetCCMin => 48;

  @override
  int get termiosOffsetCCTime => 49;

  @override
  int readFlag(Pointer<Uint8> buf, int offset) => buf.read64(offset);

  @override
  void writeFlag(Pointer<Uint8> buf, int offset, int value) {
    buf.write64(offset, value);
  }
}
