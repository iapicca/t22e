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

/// TODO DynamicLibrary SHOULD BE ABSTRACTED!

/// Opens the appropriate libc library for the current platform.
/// TODO this isn't an extension, why it's here!
@internal
/// TODO this shoul be dependency injected with riverpod
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
  final names = [
    SymbolsFFI.libcLinux6,
    SymbolsFFI.libcMuslX86,
    SymbolsFFI.libcMuslAarch64,
  ];
  Object? lastError;
  for (final name in names) {
    try {
      return DynamicLibrary.open(name);
    } on ArgumentError catch (e) {
      lastError = e;
    }
  }
  throw lastError ?? ArgumentError('Cannot open libc on Linux');
}
