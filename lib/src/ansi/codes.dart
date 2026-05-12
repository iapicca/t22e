import '../well_known.dart' show WellKnown;

/// Builds SGR escape codes for basic text style attributes
/// Toggles bold on or off
String bold(bool on) => on
    ? '${WellKnown.csi}${WellKnown.sgrBold}m'
    : '${WellKnown.csi}${WellKnown.sgrNoBoldFaint}m';
/// Toggles dim/faint on or off
String dim(bool on) => on
    ? '${WellKnown.csi}${WellKnown.sgrFaint}m'
    : '${WellKnown.csi}${WellKnown.sgrNoBoldFaint}m';
/// Toggles italic on or off
String italic(bool on) => on
    ? '${WellKnown.csi}${WellKnown.sgrItalic}m'
    : '${WellKnown.csi}${WellKnown.sgrNoItalic}m';
/// Toggles underline on or off
String underline(bool on) => on
    ? '${WellKnown.csi}${WellKnown.sgrUnderline}m'
    : '${WellKnown.csi}${WellKnown.sgrNoUnderline}m';
/// Toggles blink on or off
String blink(bool on) => on
    ? '${WellKnown.csi}${WellKnown.sgrBlink}m'
    : '${WellKnown.csi}${WellKnown.sgrNoBlink}m';
/// Toggles reverse video on or off
String reverse(bool on) => on
    ? '${WellKnown.csi}${WellKnown.sgrReverse}m'
    : '${WellKnown.csi}${WellKnown.sgrNoReverse}m';
/// Toggles strikethrough on or off
String strikethrough(bool on) => on
    ? '${WellKnown.csi}${WellKnown.sgrStrikethrough}m'
    : '${WellKnown.csi}${WellKnown.sgrNoStrikethrough}m';
/// Toggles overline on or off
String overLine(bool on) => on
    ? '${WellKnown.csi}${WellKnown.sgrOverline}m'
    : '${WellKnown.csi}${WellKnown.sgrNoOverline}m';
/// Resets all SGR attributes to default
String resetAll() => '${WellKnown.csi}${WellKnown.sgrReset}m';
