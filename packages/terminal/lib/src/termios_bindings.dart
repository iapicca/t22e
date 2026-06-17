import 'dart:ffi';

import 'package:meta/meta.dart';

import 'libc_signatures.dart';
import 'symbols_ffi.dart';

/// Abstract interface for libc FFI calls used to manage terminal raw mode.
@internal
abstract class TermiosBindings {
  factory TermiosBindings(DynamicLibrary library) = _TermiosBindings;

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
final class _TermiosBindings implements TermiosBindings {
  _TermiosBindings(DynamicLibrary library)
    : _tcGetAttr = library.lookupFunction<NativeTcGetAttr, TcGetAttr>(
        SymbolsFFI.tcGetAttrName,
      ),
      _tcSetAttr = library.lookupFunction<NativeTcSetAttr, TcSetAttr>(
        SymbolsFFI.tcSetAttrName,
      ),
      _malloc = library.lookupFunction<NativeMalloc, Malloc>(
        SymbolsFFI.mallocName,
      ),
      _free = library.lookupFunction<NativeFree, Free>(SymbolsFFI.freeName);

  final TcGetAttr _tcGetAttr;
  final TcSetAttr _tcSetAttr;
  final Malloc _malloc;
  final Free _free;

  @override
  TcGetAttr get tcGetAttr => _tcGetAttr;

  @override
  TcSetAttr get tcSetAttr => _tcSetAttr;

  @override
  Pointer<Uint8> malloc(int size) => _malloc(size).cast();

  @override
  void free(Pointer<Uint8> ptr) => _free(ptr.cast());
}
