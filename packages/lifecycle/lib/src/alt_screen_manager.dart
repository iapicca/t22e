import 'dart:io';

import 'package:ansi/ansi.dart' show hideCursor, showCursor;
import 'package:ansi/ansi.dart'
    show enterAltScreen, exitAltScreen, enableMouse, disableMouse;

/// Manages entering/exiting the alternate screen buffer.
class AltScreenManager {
  final Stdout _stdout;
  bool _active = false;
  bool _mouseEnabled = false;

  AltScreenManager(this._stdout);

  /// Switches to the alternate screen, hides cursor, optionally enables mouse.
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

  /// Returns to the main screen, shows cursor, disables mouse if active.
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

  /// Whether the alternate screen is currently active.
  bool get isActive => _active;
}
