import 'package:protocol/protocol.dart' show Defaults;

/// Erase part of the display using the given mode.
String eraseDisplay(int mode) => '${Defaults.csi}${mode}J';

/// Erase part of the current line using the given mode.
String eraseLine(int mode) => '${Defaults.csi}${mode}K';
