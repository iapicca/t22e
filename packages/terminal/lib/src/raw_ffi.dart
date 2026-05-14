import 'dart:ffi';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:protocol/protocol.dart' show Defaults;
import 'platform_service.dart';

part 'raw_ffi.freezed.dart';

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

@freezed
abstract class RawModeState with _$RawModeState {
  const factory RawModeState(
    Pointer<Uint8> buf,
    int cIflag,
    int cOflag,
    int cCflag,
    int cLflag,
  ) = _RawModeState;
}

Pointer<Uint8> mallocFfi(int size) {
  final fn = _libc
      .lookupFunction<
        Pointer<Void> Function(IntPtr),
        Pointer<Void> Function(int)
      >('malloc');
  return fn(size).cast();
}

void freeFfi(Pointer<Uint8> ptr) {
  final fn = _libc
      .lookupFunction<
        Void Function(Pointer<Void>),
        void Function(Pointer<Void>)
      >('free');
  fn(ptr.cast());
}

int read32(Pointer<Uint8> p, int offset) {
  return p[offset] |
      (p[offset + 1] << Defaults.bitShift8) |
      (p[offset + 2] << Defaults.bitShift16) |
      (p[offset + 3] << Defaults.bitShift24);
}

void write32(Pointer<Uint8> p, int offset, int value) {
  p[offset] = value & Defaults.byteMask;
  p[offset + 1] = (value >> Defaults.bitShift8) & Defaults.byteMask;
  p[offset + 2] = (value >> Defaults.bitShift16) & Defaults.byteMask;
  p[offset + 3] = (value >> Defaults.bitShift24) & Defaults.byteMask;
}

void write8(Pointer<Uint8> p, int offset, int value) {
  p[offset] = value & Defaults.byteMask;
}
