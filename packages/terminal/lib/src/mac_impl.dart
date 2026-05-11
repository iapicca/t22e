import 'dart:ffi';

import 'package:protocol/protocol.dart';
import 'platform_service.dart';

class MacService implements PlatformService {
  static const operatingSystem = 'macos';
  @override
  DynamicLibrary get library => DynamicLibrary.open(Defaults.libcMacOS);
}
