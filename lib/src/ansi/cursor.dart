import '../well_known.dart' show WellKnown;

enum CursorStyle {
  blinkingBlock(WellKnown.cursorStyleBlinkingBlock),
  steadyBlock(WellKnown.cursorStyleSteadyBlock),
  blinkingUnderline(WellKnown.cursorStyleBlinkingUnderline),
  steadyUnderline(WellKnown.cursorStyleSteadyUnderline),
  blinkingBar(WellKnown.cursorStyleBlinkingBar),
  steadyBar(WellKnown.cursorStyleSteadyBar);

  final int value;
  const CursorStyle(this.value);
}

String moveTo(int row, int col) => '${WellKnown.csi}$row;${col}H';
String moveUp(int n) => '${WellKnown.csi}${n}A';
String moveDown(int n) => '${WellKnown.csi}${n}B';
String moveRight(int n) => '${WellKnown.csi}${n}C';
String moveLeft(int n) => '${WellKnown.csi}${n}D';
String moveColumn(int col) => '${WellKnown.csi}${col}G';
String hideCursor() => '${WellKnown.csi}?${WellKnown.decModeCursorVisible}l';
String showCursor() => '${WellKnown.csi}?${WellKnown.decModeCursorVisible}h';
String saveCursor() => '${WellKnown.csi}s';
String restoreCursor() => '${WellKnown.csi}u';
String requestPosition() => '${WellKnown.csi}6n';
String setStyle(CursorStyle style) => '${WellKnown.csi}${style.value} q';
