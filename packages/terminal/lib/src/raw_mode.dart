import 'package:meta/meta.dart';
import 'package:notifier/notifier.dart' show InitMixin, ValueNotifier;

import 'raw_mode_state.dart';
import 'pointer_extensions.dart';
import 'termios.dart';
import 'termios_bindings.dart';

/// Abstract base for raw mode lifecycle management.
abstract class RawModeInterface extends ValueNotifier<RawModeState?>
    with InitMixin {
  RawModeInterface() : super(null);
}

/// Concrete [RawModeInterface] implementation using libc FFI.
///
/// Consumers should read [rawModeProvider] instead of instantiating directly.
/// This class is exposed under `src/` for advanced use at your own risk.
@internal
final class RawMode extends RawModeInterface {
  final TermiosBindings _bindings;
  final Termios _termios;

  RawMode({required this._bindings, required this._termios});

  @override
  void init({String? message, bool throwIfExists = false}) {
    super.init(message: message, throwIfExists: throwIfExists);
    final buffer = _bindings.malloc(_termios.termiosStructSize);
    final tcGetAttrResult = _bindings.tcGetAttr(Termios.stdinFd, buffer);
    if (tcGetAttrResult != 0) {
      _bindings.free(buffer);
      throw StateError('tcgetattr failed (stdin is not a TTY?)');
    }

    final savedState = RawModeState(
      buffer,
      _termios.readFlag(buffer, _termios.termiosOffsetIFlag),
      _termios.readFlag(buffer, _termios.termiosOffsetOFlag),
      _termios.readFlag(buffer, _termios.termiosOffsetCFlag),
      _termios.readFlag(buffer, _termios.termiosOffsetLFlag),
    );

    final modifiedLFlag =
        savedState.cLflag &
        ~(Termios.termiosEcho |
            Termios.termiosICanon |
            Termios.termiosISig |
            Termios.termiosIExten);
    _termios.writeFlag(buffer, _termios.termiosOffsetLFlag, modifiedLFlag);
    buffer.write8(_termios.termiosOffsetCCMin, Termios.termiosVminRaw);
    buffer.write8(_termios.termiosOffsetCCTime, Termios.termiosVtimeRaw);

    final tcSetAttrResult = _bindings.tcSetAttr(
      Termios.stdinFd,
      Termios.tcsaNow,
      buffer,
    );
    if (tcSetAttrResult != 0) {
      _bindings.free(buffer);
      throw StateError('tcsetattr failed');
    }

    value = savedState;
  }

  @override
  void dispose({String? message}) {
    final savedState = value;
    if (savedState != null) {
      _termios.writeFlag(
        savedState.buf,
        _termios.termiosOffsetIFlag,
        savedState.cIflag,
      );
      _termios.writeFlag(
        savedState.buf,
        _termios.termiosOffsetOFlag,
        savedState.cOflag,
      );
      _termios.writeFlag(
        savedState.buf,
        _termios.termiosOffsetCFlag,
        savedState.cCflag,
      );
      _termios.writeFlag(
        savedState.buf,
        _termios.termiosOffsetLFlag,
        savedState.cLflag,
      );
      _bindings.tcSetAttr(Termios.stdinFd, Termios.tcsaNow, savedState.buf);
      _bindings.free(savedState.buf);
    }
    super.dispose(message: message);
  }
}
