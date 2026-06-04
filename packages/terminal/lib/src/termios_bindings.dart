import 'dart:ffi';

import 'system_io.dart';
import 'platform_service.dart';
import 'symbols_ffi.dart';

typedef GetAttr = int Function(int fd, Pointer<Uint8> buf);
typedef SetAttr = int Function(int fd, int opt, Pointer<Uint8> buf);

/// Abstract interface for libc FFI calls used to manage terminal raw mode.
abstract class TermiosBindings {
  /// Posix tcgetattr: read terminal attributes into [buf].
  GetAttr get getAttr;

  /// Posix tcsetattr: set terminal attributes from [buf].
  SetAttr get setAttr;

  /// C malloc: allocate [size] bytes.
  Pointer<Uint8> malloc(int size);

  /// C free: release memory allocated by [malloc].
  void free(Pointer<Uint8> ptr);
}

/// Concrete [TermiosBindings] backed by a [DynamicLibrary].
final class TermiosBindingsImpl implements TermiosBindings {
  final DynamicLibrary _libc;

  final int Function(int, Pointer<Uint8>) _getAttr;
  final int Function(int, int, Pointer<Uint8>) _setAttr;

  /// Looks up tcgetattr and tcsetattr from the given [library].
  TermiosBindingsImpl(this._libc)
    : _getAttr = _libc
          .lookupFunction<
            Int32 Function(Int32, Pointer<Uint8>),
            int Function(int, Pointer<Uint8>)
          >(SymbolsFFI.getAttrName),
      _setAttr = _libc
          .lookupFunction<
            Int32 Function(Int32, Int32, Pointer<Uint8>),
            int Function(int, int, Pointer<Uint8>)
          >(SymbolsFFI.setAttrName);

  @override
  GetAttr get getAttr => _getAttr;

  @override
  SetAttr get setAttr => _setAttr;

  @override
  Pointer<Uint8> malloc(int size) {
    final fn = _libc
        .lookupFunction<
          Pointer<Void> Function(IntPtr),
          Pointer<Void> Function(int)
        >(SymbolsFFI.mallocName);
    return fn(size).cast();
  }

  @override
  void free(Pointer<Uint8> ptr) {
    final fn = _libc
        .lookupFunction<
          Void Function(Pointer<Void>),
          void Function(Pointer<Void>)
        >(SymbolsFFI.freeName);
    fn(ptr.cast());
  }

  /// Uses [PlatformService] to open the platform libc.
  static TermiosBindingsImpl fromPlatformService(SystemIo io) =>
      TermiosBindingsImpl(PlatformService(io: io).library);
}
