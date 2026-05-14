import 'dart:ffi';

import 'package:protocol/protocol.dart';
import 'platform_service.dart';

/// Linux implementation of PlatformService (tries libc.so.6, falls back to .7).
class LinuxService implements PlatformService {
  static const operatingSystem = 'linux';
  @override
  DynamicLibrary get library {
    try {
      return DynamicLibrary.open(Defaults.libcLinux6);
    } catch (_) {
      return DynamicLibrary.open(Defaults.libcLinux7);
    }
  }
}
