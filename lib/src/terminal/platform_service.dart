import 'dart:ffi';
import 'dart:io';

import 'mac_impl.dart';
import 'linux_impl.dart';

/// Platform abstraction for loading the system C library via FFI
abstract class PlatformService {
  /// The platform-native C dynamic library
  DynamicLibrary get library;

  /// Factory: returns MacService or LinuxService based on platform
  factory PlatformService() {
    switch (Platform.operatingSystem) {
      case MacService.operatingSystem:
        return MacService();
      case LinuxService.operatingSystem:
        return LinuxService();
      default:
        throw UnsupportedError(
          'FFI raw mode is not supported on this platform',
        );
    }
  }
}
