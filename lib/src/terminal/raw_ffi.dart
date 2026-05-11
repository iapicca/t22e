import 'dart:ffi';
import 'dart:io';

import '../well_known.dart' show WellKnown;

DynamicLibrary _loadLibc() {
  if (Platform.isMacOS) return DynamicLibrary.open(WellKnown.libcMacOS);
  if (Platform.isLinux) {
    try {
      return DynamicLibrary.open(WellKnown.libcLinux6);
    } catch (_) {
      return DynamicLibrary.open(WellKnown.libcLinux7);
    }
  }
  throw UnsupportedError('FFI raw mode is not supported on this platform');
}

final DynamicLibrary _libc = _loadLibc();

final int Function(int fd, Pointer<Uint8> buf) tcGetAttr = _libc
    .lookupFunction<Int32 Function(Int32, Pointer<Uint8>),
        int Function(int, Pointer<Uint8>)>('tcgetattr');

final int Function(int fd, int opt, Pointer<Uint8> buf) tcSetAttr = _libc
    .lookupFunction<Int32 Function(Int32, Int32, Pointer<Uint8>),
        int Function(int, int, Pointer<Uint8>)>('tcsetattr');

final class RawModeState {
  final Pointer<Uint8> buf;
  final int cIflag;
  final int cOflag;
  final int cCflag;
  final int cLflag;

  const RawModeState(this.buf, this.cIflag, this.cOflag, this.cCflag, this.cLflag);
}

RawModeState? enableRawModeFfi() {
  if (Platform.isWindows) return null;
  final buf = _malloc(WellKnown.termiosStructSize);
  final result = tcGetAttr(WellKnown.stdinFd, buf);
  if (result != 0) {
    _free(buf);
    return null;
  }

  final saved = RawModeState(
    buf,
    _read32(buf, WellKnown.termiosOffsetIFlag),
    _read32(buf, WellKnown.termiosOffsetOFlag),
    _read32(buf, WellKnown.termiosOffsetCFlag),
    _read32(buf, WellKnown.termiosOffsetLFlag),
  );

  final clflag = saved.cLflag & ~(WellKnown.termiosEcho | WellKnown.termiosICanon | WellKnown.termiosISig | WellKnown.termiosIExten);
  _write32(buf, WellKnown.termiosOffsetLFlag, clflag);
  _write8(buf, WellKnown.termiosOffsetCCMin, WellKnown.termiosVminRaw);
  _write8(buf, WellKnown.termiosOffsetCCTime, WellKnown.termiosVtimeRaw);

  final setResult = tcSetAttr(WellKnown.stdinFd, WellKnown.tcsaNow, buf);
  if (setResult != 0) {
    _free(buf);
    return null;
  }

  return saved;
}

void disableRawModeFfi(RawModeState state) {
  _write32(state.buf, WellKnown.termiosOffsetIFlag, state.cIflag);
  _write32(state.buf, WellKnown.termiosOffsetOFlag, state.cOflag);
  _write32(state.buf, WellKnown.termiosOffsetCFlag, state.cCflag);
  _write32(state.buf, WellKnown.termiosOffsetLFlag, state.cLflag);
  tcSetAttr(WellKnown.stdinFd, WellKnown.tcsaNow, state.buf);
  _free(state.buf);
}

Pointer<Uint8> _malloc(int size) {
  final fn = _libc
      .lookupFunction<Pointer<Void> Function(IntPtr), Pointer<Void> Function(int)>(
      'malloc');
  return fn(size).cast();
}

void _free(Pointer<Uint8> ptr) {
  final fn = _libc
      .lookupFunction<Void Function(Pointer<Void>), void Function(Pointer<Void>)>(
      'free');
  fn(ptr.cast());
}

int _read32(Pointer<Uint8> p, int offset) {
  return p[offset] | (p[offset + 1] << WellKnown.bitShift8) | (p[offset + 2] << WellKnown.bitShift16) | (p[offset + 3] << WellKnown.bitShift24);
}

void _write32(Pointer<Uint8> p, int offset, int value) {
  p[offset] = value & WellKnown.byteMask;
  p[offset + 1] = (value >> WellKnown.bitShift8) & WellKnown.byteMask;
  p[offset + 2] = (value >> WellKnown.bitShift16) & WellKnown.byteMask;
  p[offset + 3] = (value >> WellKnown.bitShift24) & WellKnown.byteMask;
}

void _write8(Pointer<Uint8> p, int offset, int value) {
  p[offset] = value & WellKnown.byteMask;
}
