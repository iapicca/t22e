import 'dart:ffi';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'libc_signatures.dart';
import 'symbols_ffi.dart';

part 'libc_provider.g.dart';

/// Extension on [DynamicLibrary] providing FFI memory helpers.
@internal
extension DynamicLibraryFfi on DynamicLibrary {
  /// Releases [ptr] via libc `free`.
  void freePointer(Pointer<Void> ptr) {
    final cFree = lookupFunction<NativeFree, Free>(SymbolsFFI.freeName);
    cFree(ptr);
  }
}

/// Opens the appropriate libc library for the current platform.
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

/// Riverpod provider for the platform libc [DynamicLibrary].
@riverpod
DynamicLibrary libc(Ref ref) => openLibc();
