/// DEC private modes, cursor styles, and erase modes.
final class DecModes {
  DecModes._();

  /// DECSET/DECRST mode: normal mouse tracking (X10).
  static const int decModeMouseNormal = 1000;

  /// DECSET/DECRST mode: button-event tracking.
  static const int decModeMouseButton = 1002;

  /// DECSET/DECRST mode: SGR extended mouse.
  static const int decModeMouseSgr = 1006;

  /// DECSET/DECRST mode: focus tracking.
  static const int decModeFocus = 1004;

  /// DECSET/DECRST mode: bracketed paste.
  static const int decModeBracketedPaste = 2004;

  /// DECSET/DECRST mode: synchronized updates.
  static const int decModeSync = 2026;

  /// DECSET/DECRST mode: alternate screen buffer.
  static const int decModeAltScreen = 1049;

  /// DECSET/DECRST mode: cursor visibility.
  static const int decModeCursorVisible = 25;

  /// Blinking block cursor shape.
  static const int cursorStyleBlinkingBlock = 1;

  /// Steady block cursor shape.
  static const int cursorStyleSteadyBlock = 2;

  /// Blinking underline cursor shape.
  static const int cursorStyleBlinkingUnderline = 3;

  /// Steady underline cursor shape.
  static const int cursorStyleSteadyUnderline = 4;

  /// Blinking bar cursor shape.
  static const int cursorStyleBlinkingBar = 5;

  /// Steady bar cursor shape.
  static const int cursorStyleSteadyBar = 6;

  /// Erase from cursor to end of display.
  static const int eraseDisplayBelow = 0;

  /// Erase from cursor to beginning of display.
  static const int eraseDisplayAbove = 1;

  /// Erase entire display.
  static const int eraseDisplayAll = 2;

  /// Erase saved lines (scrollback).
  static const int eraseDisplaySaved = 3;

  /// Erase from cursor to end of line.
  static const int eraseLineRight = 0;

  /// Erase from cursor to beginning of line.
  static const int eraseLineLeft = 1;

  /// Erase entire line.
  static const int eraseLineAll = 2;
}
