import 'dart:io';

import '../ansi/cursor.dart' show hideCursor, showCursor;
import '../ansi/term.dart' show enterAltScreen, exitAltScreen;

class AltScreenManager {
  final Stdout _stdout;
  bool _active = false;

  AltScreenManager(this._stdout);

  void enter() {
    if (_active) return;
    _stdout.write(enterAltScreen());
    _stdout.write(hideCursor());
    _stdout.flush();
    _active = true;
  }

  void exit() {
    if (!_active) return;
    _stdout.write(showCursor());
    _stdout.write(exitAltScreen());
    _stdout.flush();
    _active = false;
  }

  bool get isActive => _active;
}
