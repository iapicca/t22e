import 'system_io.dart';
import 'raw_mode_backend.dart';

import 'package:notifier/notifier.dart' show Disposable;

/// Raw mode backend using dart:io stdin echo/line mode settings.
final class IoRawModeBackend with Disposable implements RawModeBackend {
  final SystemIo io;

  /// Creates with injected [io].
  IoRawModeBackend({required this.io});

  @override
  void enable() {
    check();
    io.echoMode = false;
    io.lineMode = false;
  }

  @override
  void disable() {
    io.echoMode = true;
    io.lineMode = true;
  }

  @override
  void dispose({String? message}) {
    super.dispose(message: message);
    disable();
  }
}
