import '../well_known.dart' show WellKnown;

/// Cursor shape and blink modes
enum CursorStyle {
  blinkingBlock(WellKnown.cursorStyleBlinkingBlock),
  steadyBlock(WellKnown.cursorStyleSteadyBlock),
  blinkingUnderline(WellKnown.cursorStyleBlinkingUnderline),
  steadyUnderline(WellKnown.cursorStyleSteadyUnderline),
  blinkingBar(WellKnown.cursorStyleBlinkingBar),
  steadyBar(WellKnown.cursorStyleSteadyBar);

  /// Numeric value for the CSI q cursor style sequence
  final int value;
  const CursorStyle(this.value);
}

/// Moves cursor to absolute (row, col) — 1-based
String moveTo(int row, int col) => '${WellKnown.csi}$row;${col}H';
/// Moves cursor up by n lines
String moveUp(int n) => '${WellKnown.csi}${n}A';
/// Moves cursor down by n lines
String moveDown(int n) => '${WellKnown.csi}${n}B';
/// Moves cursor right by n columns
String moveRight(int n) => '${WellKnown.csi}${n}C';
/// Moves cursor left by n columns
String moveLeft(int n) => '${WellKnown.csi}${n}D';
/// Sets cursor to absolute column
String moveColumn(int col) => '${WellKnown.csi}${col}G';
/// Hides the cursor
String hideCursor() => '${WellKnown.csi}?${WellKnown.decModeCursorVisible}l';
/// Shows the cursor
String showCursor() => '${WellKnown.csi}?${WellKnown.decModeCursorVisible}h';
/// Saves cursor position and attributes
String saveCursor() => '${WellKnown.csi}s';
/// Restores cursor position and attributes
String restoreCursor() => '${WellKnown.csi}u';
/// Requests cursor position report from terminal
String requestPosition() => '${WellKnown.csi}6n';
/// Sets cursor shape and blink style
String setStyle(CursorStyle style) => '${WellKnown.csi}${style.value} q';
