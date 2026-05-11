import 'dart:ffi';

import '../well_known.dart';
import 'platform_service.dart';

class MacService implements PlatformService {
  static const operatingSystem = 'macos';
  @override
  DynamicLibrary get library => DynamicLibrary.open(WellKnown.libcMacOS);
}
