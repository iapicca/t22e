enum CursorStyle {
  blinkingBlock(1),
  steadyBlock(2),
  blinkingUnderline(3),
  steadyUnderline(4),
  blinkingBar(5),
  steadyBar(6);

  final int value;
  const CursorStyle(this.value);
}

String moveTo(int row, int col) => '\x1b[$row;${col}H';
String moveUp(int n) => '\x1b[${n}A';
String moveDown(int n) => '\x1b[${n}B';
String moveRight(int n) => '\x1b[${n}C';
String moveLeft(int n) => '\x1b[${n}D';
String moveColumn(int col) => '\x1b[${col}G';
String hideCursor() => '\x1b[?25l';
String showCursor() => '\x1b[?25h';
String saveCursor() => '\x1b[s';
String restoreCursor() => '\x1b[u';
String requestPosition() => '\x1b[6n';
String setStyle(CursorStyle style) => '\x1b[${style.value} q';
