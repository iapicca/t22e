import 'system_io.dart';
import 'raw_mode_backend.dart';

import 'package:notifier/notifier.dart' show Disposable;

/// Raw mode backend using dart:io stdin echo/line mode settings.
///
/// Use [ioRawBackendProvider] instead of instantiating directly.
final class IoRawModeBackend with Disposable implements RawModeBackend {
  final SystemIo io;

  /// Creates with injected [io].
  IoRawModeBackend({required this.io});

  @override
  void enable() {
    check();
    if (!io.hasTerminal) return;
    io.echoMode = false;
    io.lineMode = false;
  }

  @override
  void disable() {
    if (!io.hasTerminal) return;
    io.echoMode = true;
    io.lineMode = true;
  }

  @override
  void dispose({String? message}) {
    super.dispose(message: message);
    disable();
  }
}
