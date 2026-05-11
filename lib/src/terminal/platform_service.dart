import 'dart:ffi';
import 'dart:io';

import 'mac_impl.dart';
import 'linux_impl.dart';

abstract class PlatformService {
  DynamicLibrary get library;

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
