import 'package:protocol/protocol.dart' show Defaults;

String setForegroundRgb(int r, int g, int b) =>
    '${Defaults.csi}${Defaults.sgrFgExtended};${Defaults.sgrColorRgb};$r;$g;${b}m';
String setBackgroundRgb(int r, int g, int b) =>
    '${Defaults.csi}${Defaults.sgrBgExtended};${Defaults.sgrColorRgb};$r;$g;${b}m';
String setForeground256(int index) =>
    '${Defaults.csi}${Defaults.sgrFgExtended};${Defaults.sgrColor256};${index}m';
String setBackground256(int index) =>
    '${Defaults.csi}${Defaults.sgrBgExtended};${Defaults.sgrColor256};${index}m';
String foregroundAnsi(int color) =>
    '${Defaults.csi}${Defaults.sgrFgAnsiBase + color}m';
String backgroundAnsi(int color) =>
    '${Defaults.csi}${Defaults.sgrBgAnsiBase + color}m';
String foregroundBrightAnsi(int color) =>
    '${Defaults.csi}${Defaults.sgrFgBrightBase + color}m';
String backgroundBrightAnsi(int color) =>
    '${Defaults.csi}${Defaults.sgrBgBrightBase + color}m';
String resetColor() =>
    '${Defaults.csi}${Defaults.sgrFgReset};${Defaults.sgrBgReset}m';
