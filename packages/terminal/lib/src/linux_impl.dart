import 'dart:ffi';

import 'platform_service.dart';
import 'symbols_ffi.dart';

/// Linux implementation of [PlatformService] (tries libc.so.6, then .7).
class LinuxService implements PlatformService {
  /// Platform identifier string for Linux.
  static const operatingSystem = 'linux';

  @override
  DynamicLibrary get library {
    try {
      return DynamicLibrary.open(SymbolsFFI.libcLinux6);
    } catch (_) {
      return DynamicLibrary.open(SymbolsFFI.libcLinux7);
    }
  }
}
