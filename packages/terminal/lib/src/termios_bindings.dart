import 'dart:ffi';

import 'package:meta/meta.dart';

import 'libc_signatures.dart';
import 'symbols_ffi.dart';

/// Abstract interface for libc FFI calls used to manage terminal raw mode.
/// TODO this should be named `TermiosBindingsInterface`
@internal
abstract class TermiosBindings {
  /// Posix tcgetattr: read terminal attributes into [buf].
  TcGetAttr get tcGetAttr;

  /// Posix tcsetattr: set terminal attributes from [buf].
  TcSetAttr get tcSetAttr;

  /// C malloc: allocate [size] bytes.
  Pointer<Uint8> malloc(int size);

  /// C free: release memory allocated by [malloc].
  void free(Pointer<Uint8> ptr);
}

/// Concrete [TermiosBindings] backed by a [DynamicLibrary].
/// TODO this should be named `TermiosBindings`
@internal
final class TermiosBindingsImpl implements TermiosBindings {
  late final DynamicLibrary _library;
  late final TcGetAttr _tcGetAttr;
  late final TcSetAttr _tcSetAttr;

  /// Looks up tcgetattr and tcsetattr from the given [library].
  TermiosBindingsImpl(this._library)
  /// TODO all the dynanic library operations shoul occure via `RawMode`!!!
    : _tcGetAttr = _library.lookupFunction<NativeTcGetAttr, TcGetAttr>(
        SymbolsFFI.tcGetAttrName,
      ),
      _tcSetAttr = _library.lookupFunction<NativeTcSetAttr, TcSetAttr>(
        SymbolsFFI.tcSetAttrName,
      );

  @override
  TcGetAttr get tcGetAttr => _tcGetAttr;

  @override
  TcSetAttr get tcSetAttr => _tcSetAttr;

  @override
  Pointer<Uint8> malloc(int size) {
    final fn = _library.lookupFunction<NativeMalloc, Malloc>(
      SymbolsFFI.mallocName,
    );
    return fn(size).cast();
  }

  @override
  void free(Pointer<Uint8> ptr) {
    final fn = _library.lookupFunction<NativeFree, Free>(SymbolsFFI.freeName);
    fn(ptr.cast());
  }
}
