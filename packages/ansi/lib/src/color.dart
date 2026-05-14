import 'package:protocol/protocol.dart' show Defaults;

/// CSI for setting foreground to an RGB color.
String setForegroundRgb(int r, int g, int b) =>
    '${Defaults.csi}${Defaults.sgrFgExtended};${Defaults.sgrColorRgb};$r;$g;${b}m';
/// CSI for setting background to an RGB color.
String setBackgroundRgb(int r, int g, int b) =>
    '${Defaults.csi}${Defaults.sgrBgExtended};${Defaults.sgrColorRgb};$r;$g;${b}m';
/// CSI for setting foreground to a 256-color palette index.
String setForeground256(int index) =>
    '${Defaults.csi}${Defaults.sgrFgExtended};${Defaults.sgrColor256};${index}m';
/// CSI for setting background to a 256-color palette index.
String setBackground256(int index) =>
    '${Defaults.csi}${Defaults.sgrBgExtended};${Defaults.sgrColor256};${index}m';
/// CSI for setting foreground to an ANSI 16 color index.
String foregroundAnsi(int color) =>
    '${Defaults.csi}${Defaults.sgrFgAnsiBase + color}m';
/// CSI for setting background to an ANSI 16 color index.
String backgroundAnsi(int color) =>
    '${Defaults.csi}${Defaults.sgrBgAnsiBase + color}m';
/// CSI for setting foreground to a bright ANSI color.
String foregroundBrightAnsi(int color) =>
    '${Defaults.csi}${Defaults.sgrFgBrightBase + color}m';
/// CSI for setting background to a bright ANSI color.
String backgroundBrightAnsi(int color) =>
    '${Defaults.csi}${Defaults.sgrBgBrightBase + color}m';
/// CSI to reset both foreground and background colors.
String resetColor() =>
    '${Defaults.csi}${Defaults.sgrFgReset};${Defaults.sgrBgReset}m';
