import 'package:protocol/protocol.dart' show Defaults;

import 'system_io.dart';
import 'native_io.dart';
import 'raw_mode_backend.dart';
import 'raw_mode_state.dart';
import 'pointer_extensions.dart';
import 'termios_bindings.dart';

/// Raw mode backend using libc FFI (tcgetattr/tcsetattr).
final class FfiRawModeBackend implements RawModeBackend {
  final TermiosBindings _bindings;
  final SystemIo _io;
  RawModeState? _state;

  /// Optionally injects custom [bindings] and [io].
  FfiRawModeBackend({
    TermiosBindings? bindings,
    this._io = const NativeIo(),
  }) : _bindings = bindings ?? TermiosBindingsImpl.fromPlatformService(_io);

  @override
  void enable() {
    if (_io.operatingSystem == 'windows') {
      throw UnsupportedError('FFI raw mode is not supported on Windows');
    }
    final buf = _bindings.malloc(Defaults.termiosStructSize);
    final result = _bindings.getAttr(Defaults.stdinFd, buf);
    if (result != 0) {
      _bindings.free(buf);
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

    final setResult = _bindings.setAttr(
      Defaults.stdinFd,
      Defaults.tcsaNow,
      buf,
    );
    if (setResult != 0) {
      _bindings.free(buf);
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
    _bindings.setAttr(Defaults.stdinFd, Defaults.tcsaNow, state.buf);
    _bindings.free(state.buf);
    _state = null;
  }
}
