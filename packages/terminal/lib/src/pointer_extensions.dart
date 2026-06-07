import 'dart:ffi';

import 'package:meta/meta.dart';
import 'package:protocol/protocol.dart' show Defaults;

/// Byte-level read/write helpers for [Pointer<Uint8>].
@internal
extension PointerUint8Ops on Pointer<Uint8> {
  /// Read a 32-bit little-endian integer at [offset].
  int read32(int offset) {
    return this[offset] |
        (this[offset + 1] << Defaults.bitShift8) |
        (this[offset + 2] << Defaults.bitShift16) |
        (this[offset + 3] << Defaults.bitShift24);
  }

  /// Write a 32-bit little-endian integer [value] at [offset].
  void write32(int offset, int value) {
    this[offset] = value & Defaults.byteMask;
    this[offset + 1] = (value >> Defaults.bitShift8) & Defaults.byteMask;
    this[offset + 2] = (value >> Defaults.bitShift16) & Defaults.byteMask;
    this[offset + 3] = (value >> Defaults.bitShift24) & Defaults.byteMask;
  }

  /// Write an 8-bit [value] at [offset].
  void write8(int offset, int value) {
    this[offset] = value & Defaults.byteMask;
  }
}
