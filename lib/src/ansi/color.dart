import '../well_known.dart' show WellKnown;

/// Sets foreground to an RGB color
String setForegroundRgb(int r, int g, int b) => '${WellKnown.csi}${WellKnown.sgrFgExtended};${WellKnown.sgrColorRgb};$r;$g;${b}m';
/// Sets background to an RGB color
String setBackgroundRgb(int r, int g, int b) => '${WellKnown.csi}${WellKnown.sgrBgExtended};${WellKnown.sgrColorRgb};$r;$g;${b}m';
/// Sets foreground to a 256-color palette index
String setForeground256(int index) => '${WellKnown.csi}${WellKnown.sgrFgExtended};${WellKnown.sgrColor256};${index}m';
/// Sets background to a 256-color palette index
String setBackground256(int index) => '${WellKnown.csi}${WellKnown.sgrBgExtended};${WellKnown.sgrColor256};${index}m';
/// Sets foreground to a standard ANSI color (0–7)
String foregroundAnsi(int color) => '${WellKnown.csi}${WellKnown.sgrFgAnsiBase + color}m';
/// Sets background to a standard ANSI color (0–7)
String backgroundAnsi(int color) => '${WellKnown.csi}${WellKnown.sgrBgAnsiBase + color}m';
/// Sets foreground to a bright ANSI color (8–15)
String foregroundBrightAnsi(int color) => '${WellKnown.csi}${WellKnown.sgrFgBrightBase + color}m';
/// Sets background to a bright ANSI color (8–15)
String backgroundBrightAnsi(int color) => '${WellKnown.csi}${WellKnown.sgrBgBrightBase + color}m';
/// Resets both foreground and background to terminal defaults
String resetColor() => '${WellKnown.csi}${WellKnown.sgrFgReset};${WellKnown.sgrBgReset}m';
