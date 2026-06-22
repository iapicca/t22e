import 'dart:ffi';

import 'package:meta/meta.dart';
import 'package:protocol/protocol.dart' show ControlBytes;

/// Byte-level read/write helpers for [Pointer<Uint8>].
@internal
extension PointerUint8Ops on Pointer<Uint8> {
  /// Read a 32-bit little-endian integer at [offset].
  int read32(int offset) {
    return this[offset] |
        (this[offset + 1] << ControlBytes.bitShift8) |
        (this[offset + 2] << ControlBytes.bitShift16) |
        (this[offset + 3] << ControlBytes.bitShift24);
  }

  /// Write a 32-bit little-endian integer [value] at [offset].
  void write32(int offset, int value) {
    this[offset] = value & ControlBytes.byteMask;
    this[offset + 1] =
        (value >> ControlBytes.bitShift8) & ControlBytes.byteMask;
    this[offset + 2] =
        (value >> ControlBytes.bitShift16) & ControlBytes.byteMask;
    this[offset + 3] =
        (value >> ControlBytes.bitShift24) & ControlBytes.byteMask;
  }

  /// Write an 8-bit [value] at [offset].
  void write8(int offset, int value) {
    this[offset] = value & ControlBytes.byteMask;
  }

  /// Read a 64-bit little-endian integer at [offset].
  int read64(int offset) {
    return this[offset] |
        (this[offset + 1] << 8) |
        (this[offset + 2] << 16) |
        (this[offset + 3] << 24) |
        (this[offset + 4] << 32) |
        (this[offset + 5] << 40) |
        (this[offset + 6] << 48) |
        (this[offset + 7] << 56);
  }

  /// Write a 64-bit little-endian integer [value] at [offset].
  void write64(int offset, int value) {
    this[offset] = value & ControlBytes.byteMask;
    this[offset + 1] = (value >> 8) & ControlBytes.byteMask;
    this[offset + 2] = (value >> 16) & ControlBytes.byteMask;
    this[offset + 3] = (value >> 24) & ControlBytes.byteMask;
    this[offset + 4] = (value >> 32) & ControlBytes.byteMask;
    this[offset + 5] = (value >> 40) & ControlBytes.byteMask;
    this[offset + 6] = (value >> 48) & ControlBytes.byteMask;
    this[offset + 7] = (value >> 56) & ControlBytes.byteMask;
  }
}
