import 'package:protocol/protocol.dart' show ControlBytes;

/// Erase part of the display using the given mode.
String eraseDisplay(int mode) => '${ControlBytes.csi}${mode}J';

/// Erase part of the current line using the given mode.
String eraseLine(int mode) => '${ControlBytes.csi}${mode}K';
