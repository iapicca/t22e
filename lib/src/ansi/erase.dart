String eraseDisplay(int mode) => '\x1b[${mode}J';
String eraseLine(int mode) => '\x1b[${mode}K';
String eraseScreen() => '\x1b[2J';
String eraseSavedLines() => '\x1b[3J';
String eraseLineToEnd() => '\x1b[0K';
String eraseLineToStart() => '\x1b[1K';
String eraseLineAll() => '\x1b[2K';
