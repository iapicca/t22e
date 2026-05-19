import 'dart:ffi';

import 'platform_service.dart';
import 'symbols_ffi.dart';

/// macOS implementation of [PlatformService] using libSystem.dylib.
class MacService implements PlatformService {
  /// Platform identifier string for macOS.
  static const operatingSystem = 'macos';

  @override
  DynamicLibrary get library => DynamicLibrary.open(SymbolsFFI.libcMacOS);
}
