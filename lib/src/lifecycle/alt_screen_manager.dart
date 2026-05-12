import 'dart:io';

import '../ansi/cursor.dart' show hideCursor, showCursor;
import '../ansi/term.dart' show enterAltScreen, exitAltScreen, enableMouse, disableMouse;

/// Manages the alternate screen buffer, cursor visibility, and mouse capture
class AltScreenManager {
  /// Terminal output stream
  final Stdout _stdout;
  /// Whether the alt screen is currently active
  bool _active = false;
  /// Whether mouse capture is enabled
  bool _mouseEnabled = false;

  AltScreenManager(this._stdout);

  /// Enters alt screen, hides cursor, optionally captures mouse
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

  /// Exits alt screen, restores cursor, disables mouse if captured
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

  /// Whether the alt screen is currently active
  bool get isActive => _active;
}
