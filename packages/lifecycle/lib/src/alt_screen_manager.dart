import 'package:ansi/ansi.dart' show hideCursor, showCursor;
import 'package:ansi/ansi.dart'
    show enterAltScreen, exitAltScreen, enableMouse, disableMouse;
import 'package:notifier/notifier.dart' show InitMixin, ValueNotifier;
import 'package:terminal/terminal.dart' show TerminalIoInterface;

/// Manages alternate screen buffer and cursor visibility.
///
/// Use [altScreenManagerProvider] instead of instantiating directly.
class AltScreenManager extends ValueNotifier<bool> with InitMixin {
  final TerminalIoInterface _io;
  late final ValueNotifier<bool> _mouseEnabled;

  AltScreenManager(this._io) : super(false);

  @override
  void init({String? message, bool throwIfExists = false}) {
    super.init(message: message, throwIfExists: throwIfExists);
    _mouseEnabled = ValueNotifier(false);
  }

  bool get isActive => value;
  bool get isMouseEnabled => _mouseEnabled.value;

  void enter({bool captureMouse = false}) {
    checkInit();
    if (value) return;
    _io.write(enterAltScreen());
    _io.write(hideCursor());
    if (captureMouse) {
      _io.write(enableMouse());
      _mouseEnabled.value = true;
    }
    _io.flush();
    value = true;
  }

  void exit() {
    if (!value) return;
    _io.write(showCursor());
    if (_mouseEnabled.value) {
      _io.write(disableMouse());
      _mouseEnabled.value = false;
    }
    _io.write(exitAltScreen());
    _io.flush();
    value = false;
  }

  @override
  void dispose({String? message}) {
    exit();
    if (isInitialized) {
      _mouseEnabled.dispose(message: message);
    }
    super.dispose(message: message);
  }
}
