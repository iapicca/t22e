import 'dart:io';

import 'package:protocol/protocol.dart' show Defaults;
import 'raw_mode_backend.dart';
import 'raw_ffi.dart';

final class FfiRawModeBackend implements RawModeBackend {
  RawModeState? _state;

  @override
  void enable() {
    if (Platform.isWindows) {
      throw UnsupportedError('FFI raw mode is not supported on Windows');
    }
    final buf = mallocFfi(Defaults.termiosStructSize);
    final result = tcGetAttr(Defaults.stdinFd, buf);
    if (result != 0) {
      freeFfi(buf);
      throw StateError('tcgetattr failed (stdin is not a TTY?)');
    }

    final saved = RawModeState(
      buf,
      read32(buf, Defaults.termiosOffsetIFlag),
      read32(buf, Defaults.termiosOffsetOFlag),
      read32(buf, Defaults.termiosOffsetCFlag),
      read32(buf, Defaults.termiosOffsetLFlag),
    );

    final clflag =
        saved.cLflag &
        ~(Defaults.termiosEcho |
            Defaults.termiosICanon |
            Defaults.termiosISig |
            Defaults.termiosIExten);
    write32(buf, Defaults.termiosOffsetLFlag, clflag);
    write8(buf, Defaults.termiosOffsetCCMin, Defaults.termiosVminRaw);
    write8(buf, Defaults.termiosOffsetCCTime, Defaults.termiosVtimeRaw);

    final setResult = tcSetAttr(Defaults.stdinFd, Defaults.tcsaNow, buf);
    if (setResult != 0) {
      freeFfi(buf);
      throw StateError('tcsetattr failed');
    }

    _state = saved;
  }

  @override
  void disable() {
    final state = _state;
    if (state == null) return;
    write32(state.buf, Defaults.termiosOffsetIFlag, state.cIflag);
    write32(state.buf, Defaults.termiosOffsetOFlag, state.cOflag);
    write32(state.buf, Defaults.termiosOffsetCFlag, state.cCflag);
    write32(state.buf, Defaults.termiosOffsetLFlag, state.cLflag);
    tcSetAttr(Defaults.stdinFd, Defaults.tcsaNow, state.buf);
    freeFfi(state.buf);
    _state = null;
  }
}
