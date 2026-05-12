import 'dart:ffi';
import 'dart:io';

import '../well_known.dart' show WellKnown;
import 'platform_service.dart';

// Platform-specific C library for termios functions
final DynamicLibrary _libc = PlatformService().library;

// FFI binding for tcgetattr
final int Function(int fd, Pointer<Uint8> buf) tcGetAttr = _libc
    .lookupFunction<Int32 Function(Int32, Pointer<Uint8>),
        int Function(int, Pointer<Uint8>)>('tcgetattr');

// FFI binding for tcsetattr
final int Function(int fd, int opt, Pointer<Uint8> buf) tcSetAttr = _libc
    .lookupFunction<Int32 Function(Int32, Int32, Pointer<Uint8>),
        int Function(int, int, Pointer<Uint8>)>('tcsetattr');

/// Saved termios state for restoring when exiting raw mode
final class RawModeState {
  /// Raw memory buffer holding the termios struct
  final Pointer<Uint8> buf;
  /// Saved input flags
  final int cIflag;
  /// Saved output flags
  final int cOflag;
  /// Saved control flags
  final int cCflag;
  /// Saved local flags
  final int cLflag;

  const RawModeState(this.buf, this.cIflag, this.cOflag, this.cCflag, this.cLflag);
}

/// Enters raw mode via FFI/termios. Returns saved state, or null on failure.
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

/// Restores terminal to the saved termios state
void disableRawModeFfi(RawModeState state) {
  _write32(state.buf, WellKnown.termiosOffsetIFlag, state.cIflag);
  _write32(state.buf, WellKnown.termiosOffsetOFlag, state.cOflag);
  _write32(state.buf, WellKnown.termiosOffsetCFlag, state.cCflag);
  _write32(state.buf, WellKnown.termiosOffsetLFlag, state.cLflag);
  tcSetAttr(WellKnown.stdinFd, WellKnown.tcsaNow, state.buf);
  _free(state.buf);
}

/// Allocates memory via libc malloc
Pointer<Uint8> _malloc(int size) {
  final fn = _libc
      .lookupFunction<Pointer<Void> Function(IntPtr), Pointer<Void> Function(int)>(
      'malloc');
  return fn(size).cast();
}

/// Frees memory via libc free
void _free(Pointer<Uint8> ptr) {
  final fn = _libc
      .lookupFunction<Void Function(Pointer<Void>), void Function(Pointer<Void>)>(
      'free');
  fn(ptr.cast());
}

/// Reads a 32-bit integer from a raw pointer at the given offset
int _read32(Pointer<Uint8> p, int offset) {
  return p[offset] | (p[offset + 1] << WellKnown.bitShift8) | (p[offset + 2] << WellKnown.bitShift16) | (p[offset + 3] << WellKnown.bitShift24);
}

/// Writes a 32-bit integer to a raw pointer at the given offset
void _write32(Pointer<Uint8> p, int offset, int value) {
  p[offset] = value & WellKnown.byteMask;
  p[offset + 1] = (value >> WellKnown.bitShift8) & WellKnown.byteMask;
  p[offset + 2] = (value >> WellKnown.bitShift16) & WellKnown.byteMask;
  p[offset + 3] = (value >> WellKnown.bitShift24) & WellKnown.byteMask;
}

/// Writes an 8-bit byte to a raw pointer at the given offset
void _write8(Pointer<Uint8> p, int offset, int value) {
  p[offset] = value & WellKnown.byteMask;
}
