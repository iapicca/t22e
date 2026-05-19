import 'system_io.dart';
import 'native_io.dart';
import 'raw_mode_backend.dart';

/// Raw mode backend using dart:io stdin echo/line mode settings.
final class IoRawModeBackend implements RawModeBackend {
  final SystemIo _io;

  /// Creates with injected [io] (defaults to [NativeIo]).
  const IoRawModeBackend({this._io = const NativeIo()});

  @override
  void enable() {
    _io.echoMode = false;
    _io.lineMode = false;
  }

  @override
  void disable() {
    _io.echoMode = true;
    _io.lineMode = true;
  }
}
