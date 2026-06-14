import 'package:protocol/protocol.dart' show ControlBytes, SgrCodes;

/// CSI for setting foreground to an RGB color.
String setForegroundRgb(int r, int g, int b) =>
    '${ControlBytes.csi}${SgrCodes.sgrFgExtended};${SgrCodes.sgrColorRgb};$r;$g;${b}m';

/// CSI for setting background to an RGB color.
String setBackgroundRgb(int r, int g, int b) =>
    '${ControlBytes.csi}${SgrCodes.sgrBgExtended};${SgrCodes.sgrColorRgb};$r;$g;${b}m';

/// CSI for setting foreground to a 256-color palette index.
String setForeground256(int index) =>
    '${ControlBytes.csi}${SgrCodes.sgrFgExtended};${SgrCodes.sgrColor256};${index}m';

/// CSI for setting background to a 256-color palette index.
String setBackground256(int index) =>
    '${ControlBytes.csi}${SgrCodes.sgrBgExtended};${SgrCodes.sgrColor256};${index}m';

/// CSI for setting foreground to an ANSI 16 color index.
String foregroundAnsi(int color) =>
    '${ControlBytes.csi}${SgrCodes.sgrFgAnsiBase + color}m';

/// CSI for setting background to an ANSI 16 color index.
String backgroundAnsi(int color) =>
    '${ControlBytes.csi}${SgrCodes.sgrBgAnsiBase + color}m';

/// CSI for setting foreground to a bright ANSI color.
String foregroundBrightAnsi(int color) =>
    '${ControlBytes.csi}${SgrCodes.sgrFgBrightBase + color}m';

/// CSI for setting background to a bright ANSI color.
String backgroundBrightAnsi(int color) =>
    '${ControlBytes.csi}${SgrCodes.sgrBgBrightBase + color}m';
