import 'dart:ffi';

import '../well_known.dart';
import 'platform_service.dart';

/// macOS implementation: loads libSystem.dylib
class MacService implements PlatformService {
  /// Operating system identifier for macOS
  static const operatingSystem = 'macos';
  @override
  DynamicLibrary get library => DynamicLibrary.open(WellKnown.libcMacOS);
}
