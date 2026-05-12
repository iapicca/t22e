import 'dart:ffi';

import '../well_known.dart';
import 'platform_service.dart';

/// Linux implementation: tries libc.so.6 first, falls back to libc.so.7
class LinuxService implements PlatformService {
  /// Operating system identifier for Linux
  static const operatingSystem = 'linux';
  @override
  DynamicLibrary get library {
    try {
      return DynamicLibrary.open(WellKnown.libcLinux6);
    } catch (_) {
      return DynamicLibrary.open(WellKnown.libcLinux7);
    }
  }
}
