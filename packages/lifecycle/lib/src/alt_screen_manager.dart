import 'package:ansi/ansi.dart' show hideCursor, showCursor;
import 'package:ansi/ansi.dart'
    show enterAltScreen, exitAltScreen, enableMouse, disableMouse;
import 'package:terminal/terminal.dart' show TerminalIo;

class AltScreenManager {
  final TerminalIo _io;
  bool _active = false;
  bool _mouseEnabled = false;

  AltScreenManager(this._io);

  void enter({bool captureMouse = false}) {
    if (_active) return;
    _io.write(enterAltScreen());
    _io.write(hideCursor());
    if (captureMouse) {
      _io.write(enableMouse());
      _mouseEnabled = true;
    }
    _io.flush();
    _active = true;
  }

  void exit() {
    if (!_active) return;
    _io.write(showCursor());
    if (_mouseEnabled) {
      _io.write(disableMouse());
      _mouseEnabled = false;
    }
    _io.write(exitAltScreen());
    _io.flush();
    _active = false;
  }

  bool get isActive => _active;
}
