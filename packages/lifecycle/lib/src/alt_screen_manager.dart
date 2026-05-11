import 'dart:io';

import 'package:ansi/ansi.dart' show hideCursor, showCursor;
import 'package:ansi/ansi.dart'
    show enterAltScreen, exitAltScreen, enableMouse, disableMouse;

class AltScreenManager {
  final Stdout _stdout;
  bool _active = false;
  bool _mouseEnabled = false;

  AltScreenManager(this._stdout);

  void enter({bool captureMouse = false}) {
    if (_active) return;
    _stdout.write(enterAltScreen());
    _stdout.write(hideCursor());
    if (captureMouse) {
      _stdout.write(enableMouse());
      _mouseEnabled = true;
    }
    _stdout.flush();
    _active = true;
  }

  void exit() {
    if (!_active) return;
    _stdout.write(showCursor());
    if (_mouseEnabled) {
      _stdout.write(disableMouse());
      _mouseEnabled = false;
    }
    _stdout.write(exitAltScreen());
    _stdout.flush();
    _active = false;
  }

  bool get isActive => _active;
}
