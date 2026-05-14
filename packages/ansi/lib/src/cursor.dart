import 'package:protocol/protocol.dart' show Defaults;

/// Cursor shape styles for block, underline, and bar cursors.
enum CursorStyle {
  /// Blinking block cursor.
  blinkingBlock(Defaults.cursorStyleBlinkingBlock),
  /// Steady block cursor.
  steadyBlock(Defaults.cursorStyleSteadyBlock),
  /// Blinking underline cursor.
  blinkingUnderline(Defaults.cursorStyleBlinkingUnderline),
  /// Steady underline cursor.
  steadyUnderline(Defaults.cursorStyleSteadyUnderline),
  /// Blinking bar (I-beam) cursor.
  blinkingBar(Defaults.cursorStyleBlinkingBar),
  /// Steady bar (I-beam) cursor.
  steadyBar(Defaults.cursorStyleSteadyBar);

  /// The numeric cursor style code.
  final int value;
  const CursorStyle(this.value);
}

/// Move cursor to the given row and column (1-based).
String moveTo(int row, int col) => '${Defaults.csi}$row;${col}H';
/// Move cursor up by n lines.
String moveUp(int n) => '${Defaults.csi}${n}A';
/// Move cursor down by n lines.
String moveDown(int n) => '${Defaults.csi}${n}B';
/// Move cursor right by n columns.
String moveRight(int n) => '${Defaults.csi}${n}C';
/// Move cursor left by n columns.
String moveLeft(int n) => '${Defaults.csi}${n}D';
/// Move cursor to a specific column (1-based).
String moveColumn(int col) => '${Defaults.csi}${col}G';
/// Hide the terminal cursor.
String hideCursor() => '${Defaults.csi}?${Defaults.decModeCursorVisible}l';
/// Show the terminal cursor.
String showCursor() => '${Defaults.csi}?${Defaults.decModeCursorVisible}h';
/// Save the current cursor position.
String saveCursor() => '${Defaults.csi}s';
/// Restore the previously saved cursor position.
String restoreCursor() => '${Defaults.csi}u';
/// Request the current cursor position from the terminal.
String requestPosition() => '${Defaults.csi}6n';
/// Set the cursor shape/style.
String setStyle(CursorStyle style) => '${Defaults.csi}${style.value} q';
