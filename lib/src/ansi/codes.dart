import '../well_known.dart' show WellKnown;

String bold(bool on) => on
    ? '${WellKnown.csi}${WellKnown.sgrBold}m'
    : '${WellKnown.csi}${WellKnown.sgrNoBoldFaint}m';
String dim(bool on) => on
    ? '${WellKnown.csi}${WellKnown.sgrFaint}m'
    : '${WellKnown.csi}${WellKnown.sgrNoBoldFaint}m';
String italic(bool on) => on
    ? '${WellKnown.csi}${WellKnown.sgrItalic}m'
    : '${WellKnown.csi}${WellKnown.sgrNoItalic}m';
String underline(bool on) => on
    ? '${WellKnown.csi}${WellKnown.sgrUnderline}m'
    : '${WellKnown.csi}${WellKnown.sgrNoUnderline}m';
String blink(bool on) => on
    ? '${WellKnown.csi}${WellKnown.sgrBlink}m'
    : '${WellKnown.csi}${WellKnown.sgrNoBlink}m';
String reverse(bool on) => on
    ? '${WellKnown.csi}${WellKnown.sgrReverse}m'
    : '${WellKnown.csi}${WellKnown.sgrNoReverse}m';
String strikethrough(bool on) => on
    ? '${WellKnown.csi}${WellKnown.sgrStrikethrough}m'
    : '${WellKnown.csi}${WellKnown.sgrNoStrikethrough}m';
String overLine(bool on) => on
    ? '${WellKnown.csi}${WellKnown.sgrOverline}m'
    : '${WellKnown.csi}${WellKnown.sgrNoOverline}m';
String resetAll() => '${WellKnown.csi}${WellKnown.sgrReset}m';
