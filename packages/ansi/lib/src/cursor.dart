import 'package:protocol/protocol.dart' show ControlBytes, DecModes;

/// Cursor shape styles for block, underline, and bar cursors.
enum CursorStyle {
  /// Blinking block cursor.
  blinkingBlock(DecModes.cursorStyleBlinkingBlock),

  /// Steady block cursor.
  steadyBlock(DecModes.cursorStyleSteadyBlock),

  /// Blinking underline cursor.
  blinkingUnderline(DecModes.cursorStyleBlinkingUnderline),

  /// Steady underline cursor.
  steadyUnderline(DecModes.cursorStyleSteadyUnderline),

  /// Blinking bar (I-beam) cursor.
  blinkingBar(DecModes.cursorStyleBlinkingBar),

  /// Steady bar (I-beam) cursor.
  steadyBar(DecModes.cursorStyleSteadyBar);

  /// The numeric cursor style code.
  final int value;
  const CursorStyle(this.value);
}

/// Move cursor to the given row and column (1-based).
String moveTo(int row, int col) => '${ControlBytes.csi}$row;${col}H';

/// Move cursor up by n lines.
String moveUp(int n) => '${ControlBytes.csi}${n}A';

/// Move cursor down by n lines.
String moveDown(int n) => '${ControlBytes.csi}${n}B';

/// Move cursor right by n columns.
String moveRight(int n) => '${ControlBytes.csi}${n}C';

/// Move cursor left by n columns.
String moveLeft(int n) => '${ControlBytes.csi}${n}D';

/// Move cursor to a specific column (1-based).
String moveColumn(int col) => '${ControlBytes.csi}${col}G';

/// Set the cursor shape/style.
String setStyle(CursorStyle style) => '${ControlBytes.csi}${style.value} q';
