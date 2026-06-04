import 'package:notifier/notifier.dart' show Disposable;
import 'package:protocol/protocol.dart' show Defaults;

import 'system_io.dart';
import 'raw_mode_backend.dart';
import 'raw_mode_state.dart';
import 'pointer_extensions.dart';
import 'termios_bindings.dart';

/// Raw mode backend using libc FFI (tcgetattr/tcsetattr).
final class FfiRawModeBackend with Disposable implements RawModeBackend {
  final TermiosBindings bindings;
  final SystemIo io;
  RawModeState? _state;

  /// Creates with injected [bindings] and [io].
  FfiRawModeBackend({required this.bindings, required this.io});

  @override
  void enable() {
    check();
    if (io.operatingSystem == 'windows') {
      throw UnsupportedError('FFI raw mode is not supported on Windows');
    }
    final buf = bindings.malloc(Defaults.termiosStructSize);
    final result = bindings.getAttr(Defaults.stdinFd, buf);
    if (result != 0) {
      bindings.free(buf);
      throw StateError('tcgetattr failed (stdin is not a TTY?)');
    }

    final saved = RawModeState(
      buf,
      buf.read32(Defaults.termiosOffsetIFlag),
      buf.read32(Defaults.termiosOffsetOFlag),
      buf.read32(Defaults.termiosOffsetCFlag),
      buf.read32(Defaults.termiosOffsetLFlag),
    );

    final clflag =
        saved.cLflag &
        ~(Defaults.termiosEcho |
            Defaults.termiosICanon |
            Defaults.termiosISig |
            Defaults.termiosIExten);
    buf.write32(Defaults.termiosOffsetLFlag, clflag);
    buf.write8(Defaults.termiosOffsetCCMin, Defaults.termiosVminRaw);
    buf.write8(Defaults.termiosOffsetCCTime, Defaults.termiosVtimeRaw);

    final setResult = bindings.setAttr(Defaults.stdinFd, Defaults.tcsaNow, buf);
    if (setResult != 0) {
      bindings.free(buf);
      throw StateError('tcsetattr failed');
    }

    _state = saved;
  }

  @override
  void disable() {
    final state = _state;
    if (state == null) return;
    state.buf.write32(Defaults.termiosOffsetIFlag, state.cIflag);
    state.buf.write32(Defaults.termiosOffsetOFlag, state.cOflag);
    state.buf.write32(Defaults.termiosOffsetCFlag, state.cCflag);
    state.buf.write32(Defaults.termiosOffsetLFlag, state.cLflag);
    bindings.setAttr(Defaults.stdinFd, Defaults.tcsaNow, state.buf);
    bindings.free(state.buf);
    _state = null;
  }

  @override
  void dispose({String? message}) {
    super.dispose(message: message);
    disable();
  }
}
