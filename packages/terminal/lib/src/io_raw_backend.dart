import 'system_io.dart';
import 'native_io.dart';
import 'raw_mode_backend.dart';

import 'package:notifier/notifier.dart' show Disposable;

/// Raw mode backend using dart:io stdin echo/line mode settings.
final class IoRawModeBackend with Disposable implements RawModeBackend {
  final SystemIo _io;

  /// Creates with injected [io] (defaults to [NativeIo]).
  IoRawModeBackend({this._io = const NativeIo()});

  @override
  void enable() {
    check();
    _io.echoMode = false;
    _io.lineMode = false;
  }

  @override
  void disable() {
    _io.echoMode = true;
    _io.lineMode = true;
  }

  @override
  void dispose(String? message) {
    super.dispose(message);
    disable();
  }
}
