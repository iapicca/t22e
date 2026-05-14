import 'dart:ffi';
import 'dart:io';

import 'mac_impl.dart';
import 'linux_impl.dart';

/// Abstract service providing platform-specific DynamicLibrary access.
abstract class PlatformService {
  /// The platform's libc DynamicLibrary instance.
  DynamicLibrary get library;

  /// Returns the appropriate PlatformService for the current OS.
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
