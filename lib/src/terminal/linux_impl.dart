import 'dart:ffi';

import '../well_known.dart';
import 'platform_service.dart';

class LinuxService implements PlatformService {
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
