import 'dart:ffi';
import 'dart:io';

import 'package:protocol/protocol.dart' show Defaults;
import 'platform_service.dart';

final DynamicLibrary _libc = PlatformService().library;

final int Function(int fd, Pointer<Uint8> buf) tcGetAttr = _libc
    .lookupFunction<
      Int32 Function(Int32, Pointer<Uint8>),
      int Function(int, Pointer<Uint8>)
    >('tcgetattr');

final int Function(int fd, int opt, Pointer<Uint8> buf) tcSetAttr = _libc
    .lookupFunction<
      Int32 Function(Int32, Int32, Pointer<Uint8>),
      int Function(int, int, Pointer<Uint8>)
    >('tcsetattr');

final class RawModeState {
  final Pointer<Uint8> buf;
  final int cIflag;
  final int cOflag;
  final int cCflag;
  final int cLflag;

  const RawModeState(
    this.buf,
    this.cIflag,
    this.cOflag,
    this.cCflag,
    this.cLflag,
  );
}

RawModeState? enableRawModeFfi() {
  if (Platform.isWindows) return null;
  final buf = _malloc(Defaults.termiosStructSize);
  final result = tcGetAttr(Defaults.stdinFd, buf);
  if (result != 0) {
    _free(buf);
    return null;
  }

  final saved = RawModeState(
    buf,
    _read32(buf, Defaults.termiosOffsetIFlag),
    _read32(buf, Defaults.termiosOffsetOFlag),
    _read32(buf, Defaults.termiosOffsetCFlag),
    _read32(buf, Defaults.termiosOffsetLFlag),
  );

  final clflag =
      saved.cLflag &
      ~(Defaults.termiosEcho |
          Defaults.termiosICanon |
          Defaults.termiosISig |
          Defaults.termiosIExten);
  _write32(buf, Defaults.termiosOffsetLFlag, clflag);
  _write8(buf, Defaults.termiosOffsetCCMin, Defaults.termiosVminRaw);
  _write8(buf, Defaults.termiosOffsetCCTime, Defaults.termiosVtimeRaw);

  final setResult = tcSetAttr(Defaults.stdinFd, Defaults.tcsaNow, buf);
  if (setResult != 0) {
    _free(buf);
    return null;
  }

  return saved;
}

void disableRawModeFfi(RawModeState state) {
  _write32(state.buf, Defaults.termiosOffsetIFlag, state.cIflag);
  _write32(state.buf, Defaults.termiosOffsetOFlag, state.cOflag);
  _write32(state.buf, Defaults.termiosOffsetCFlag, state.cCflag);
  _write32(state.buf, Defaults.termiosOffsetLFlag, state.cLflag);
  tcSetAttr(Defaults.stdinFd, Defaults.tcsaNow, state.buf);
  _free(state.buf);
}

Pointer<Uint8> _malloc(int size) {
  final fn = _libc
      .lookupFunction<
        Pointer<Void> Function(IntPtr),
        Pointer<Void> Function(int)
      >('malloc');
  return fn(size).cast();
}

void _free(Pointer<Uint8> ptr) {
  final fn = _libc
      .lookupFunction<
        Void Function(Pointer<Void>),
        void Function(Pointer<Void>)
      >('free');
  fn(ptr.cast());
}

int _read32(Pointer<Uint8> p, int offset) {
  return p[offset] |
      (p[offset + 1] << Defaults.bitShift8) |
      (p[offset + 2] << Defaults.bitShift16) |
      (p[offset + 3] << Defaults.bitShift24);
}

void _write32(Pointer<Uint8> p, int offset, int value) {
  p[offset] = value & Defaults.byteMask;
  p[offset + 1] = (value >> Defaults.bitShift8) & Defaults.byteMask;
  p[offset + 2] = (value >> Defaults.bitShift16) & Defaults.byteMask;
  p[offset + 3] = (value >> Defaults.bitShift24) & Defaults.byteMask;
}

void _write8(Pointer<Uint8> p, int offset, int value) {
  p[offset] = value & Defaults.byteMask;
}
