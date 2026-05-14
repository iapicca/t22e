import 'package:protocol/protocol.dart' show Defaults;

/// Erase part of the display using the given mode.
String eraseDisplay(int mode) => '${Defaults.csi}${mode}J';
/// Erase part of the current line using the given mode.
String eraseLine(int mode) => '${Defaults.csi}${mode}K';
/// Erase the entire visible display.
String eraseScreen() => '${Defaults.csi}${Defaults.eraseDisplayAll}J';
/// Erase saved lines (scrollback buffer).
String eraseSavedLines() => '${Defaults.csi}${Defaults.eraseDisplaySaved}J';
/// Erase from cursor to end of line.
String eraseLineToEnd() => '${Defaults.csi}${Defaults.eraseLineRight}K';
/// Erase from cursor to beginning of line.
String eraseLineToStart() => '${Defaults.csi}${Defaults.eraseLineLeft}K';
/// Erase the entire current line.
String eraseLineAll() => '${Defaults.csi}${Defaults.eraseLineAll}K';
