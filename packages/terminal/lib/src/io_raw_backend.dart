import 'dart:io';

import 'raw_mode_backend.dart';

/// Raw mode backend using dart:io stdin settings.
final class IoRawModeBackend implements RawModeBackend {
  const IoRawModeBackend();

  @override
  void enable() {
    stdin.echoMode = false;
    stdin.lineMode = false;
  }

  @override
  void disable() {
    stdin.echoMode = true;
    stdin.lineMode = true;
  }
}
