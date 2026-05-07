import 'dart:ffi';
import 'dart:io';

DynamicLibrary _loadLibc() {
  if (Platform.isMacOS) return DynamicLibrary.open('libSystem.dylib');
  if (Platform.isLinux) {
    try {
      return DynamicLibrary.open('libc.so.6');
    } catch (_) {
      return DynamicLibrary.open('libc.so.7');
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

const _echo = 0x00000008;
const _icanon = 0x00000002;
const _isig = 0x00000001;
const _iexten = 0x00008000;

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
  const size = 60;
  final buf = _malloc(size);
  final result = tcGetAttr(0, buf);
  if (result != 0) {
    _free(buf);
    return null;
  }

  final saved = RawModeState(
    buf,
    _read32(buf, 0),
    _read32(buf, 4),
    _read32(buf, 8),
    _read32(buf, 12),
  );

  final clflag = saved.cLflag & ~(_echo | _icanon | _isig | _iexten);
  _write32(buf, 12, clflag);
  _write8(buf, 17, 1);
  _write8(buf, 18, 0);

  final setResult = tcSetAttr(0, 0, buf);
  if (setResult != 0) {
    _free(buf);
    return null;
  }

  return saved;
}

void disableRawModeFfi(RawModeState state) {
  _write32(state.buf, 0, state.cIflag);
  _write32(state.buf, 4, state.cOflag);
  _write32(state.buf, 8, state.cCflag);
  _write32(state.buf, 12, state.cLflag);
  tcSetAttr(0, 0, state.buf);
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
  return p[offset] | (p[offset + 1] << 8) | (p[offset + 2] << 16) | (p[offset + 3] << 24);
}

void _write32(Pointer<Uint8> p, int offset, int value) {
  p[offset] = value & 0xFF;
  p[offset + 1] = (value >> 8) & 0xFF;
  p[offset + 2] = (value >> 16) & 0xFF;
  p[offset + 3] = (value >> 24) & 0xFF;
}

void _write8(Pointer<Uint8> p, int offset, int value) {
  p[offset] = value & 0xFF;
}
