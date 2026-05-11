import 'package:protocol/protocol.dart' show Defaults;

enum CursorStyle {
  blinkingBlock(Defaults.cursorStyleBlinkingBlock),
  steadyBlock(Defaults.cursorStyleSteadyBlock),
  blinkingUnderline(Defaults.cursorStyleBlinkingUnderline),
  steadyUnderline(Defaults.cursorStyleSteadyUnderline),
  blinkingBar(Defaults.cursorStyleBlinkingBar),
  steadyBar(Defaults.cursorStyleSteadyBar);

  final int value;
  const CursorStyle(this.value);
}

String moveTo(int row, int col) => '${Defaults.csi}$row;${col}H';
String moveUp(int n) => '${Defaults.csi}${n}A';
String moveDown(int n) => '${Defaults.csi}${n}B';
String moveRight(int n) => '${Defaults.csi}${n}C';
String moveLeft(int n) => '${Defaults.csi}${n}D';
String moveColumn(int col) => '${Defaults.csi}${col}G';
String hideCursor() => '${Defaults.csi}?${Defaults.decModeCursorVisible}l';
String showCursor() => '${Defaults.csi}?${Defaults.decModeCursorVisible}h';
String saveCursor() => '${Defaults.csi}s';
String restoreCursor() => '${Defaults.csi}u';
String requestPosition() => '${Defaults.csi}6n';
String setStyle(CursorStyle style) => '${Defaults.csi}${style.value} q';
