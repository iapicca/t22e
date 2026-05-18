import 'dart:ffi';

import 'package:protocol/protocol.dart';
import 'platform_service.dart';

/// macOS implementation of [PlatformService] using libSystem.dylib.
class MacService implements PlatformService {
  /// Platform identifier string for macOS.
  static const operatingSystem = 'macos';

  @override
  DynamicLibrary get library => DynamicLibrary.open(Defaults.libcMacOS);
}
