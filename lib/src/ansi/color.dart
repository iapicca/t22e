import '../well_known.dart' show WellKnown;

String setForegroundRgb(int r, int g, int b) => '${WellKnown.csi}${WellKnown.sgrFgExtended};${WellKnown.sgrColorRgb};$r;$g;${b}m';
String setBackgroundRgb(int r, int g, int b) => '${WellKnown.csi}${WellKnown.sgrBgExtended};${WellKnown.sgrColorRgb};$r;$g;${b}m';
String setForeground256(int index) => '${WellKnown.csi}${WellKnown.sgrFgExtended};${WellKnown.sgrColor256};${index}m';
String setBackground256(int index) => '${WellKnown.csi}${WellKnown.sgrBgExtended};${WellKnown.sgrColor256};${index}m';
String foregroundAnsi(int color) => '${WellKnown.csi}${WellKnown.sgrFgAnsiBase + color}m';
String backgroundAnsi(int color) => '${WellKnown.csi}${WellKnown.sgrBgAnsiBase + color}m';
String foregroundBrightAnsi(int color) => '${WellKnown.csi}${WellKnown.sgrFgBrightBase + color}m';
String backgroundBrightAnsi(int color) => '${WellKnown.csi}${WellKnown.sgrBgBrightBase + color}m';
String resetColor() => '${WellKnown.csi}${WellKnown.sgrFgReset};${WellKnown.sgrBgReset}m';
