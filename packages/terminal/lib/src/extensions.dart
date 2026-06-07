import 'dart:ffi';
import 'dart:io';

import 'package:meta/meta.dart';

import 'libc_signatures.dart';
import 'symbols_ffi.dart';

/// Extension on [DynamicLibrary] providing FFI memory and platform helpers.
@internal
extension DynamicLibraryFfi on DynamicLibrary {
  /// Releases [ptr] via libc `free`.
  void freePointer(Pointer<Void> ptr) {
    final cFree = lookupFunction<NativeFree, Free>(SymbolsFFI.freeName);
    cFree(ptr);
  }
}

/// Opens the appropriate libc library for the current platform.
@internal
DynamicLibrary openLibc() {
  final operatingSystem = Platform.operatingSystem;
  return switch (operatingSystem) {
    'macos' => DynamicLibrary.open(SymbolsFFI.libcMacOS),
    'linux' => _openLinuxLibc(),
    _ => throw UnsupportedError(
      'FFI raw mode is not supported on $operatingSystem',
    ),
  };
}

DynamicLibrary _openLinuxLibc() {
  try {
    return DynamicLibrary.open(SymbolsFFI.libcLinux6);
  } catch (_) {
    return DynamicLibrary.open(SymbolsFFI.libcLinux7);
  }
}
