import 'dart:ffi';

import 'pointer_extensions.dart';
import 'termios.dart';

/// Linux termios layout (tcflag_t = 4 bytes, struct = 60 bytes).
final class LinuxTermios extends Termios {
  const LinuxTermios();

  @override
  int get termiosStructSize => 60;

  @override
  int get termiosOffsetIFlag => 0;

  @override
  int get termiosOffsetOFlag => 4;

  @override
  int get termiosOffsetCFlag => 8;

  @override
  int get termiosOffsetLFlag => 12;

  @override
  int get termiosOffsetCCMin => 23;

  @override
  int get termiosOffsetCCTime => 22;

  @override
  int readFlag(Pointer<Uint8> buf, int offset) => buf.read32(offset);

  @override
  void writeFlag(Pointer<Uint8> buf, int offset, int value) {
    buf.write32(offset, value);
  }
}
