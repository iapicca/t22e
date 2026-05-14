import 'dart:io';

import 'raw_mode_backend.dart';

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
