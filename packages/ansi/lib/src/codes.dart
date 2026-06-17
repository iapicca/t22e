import 'package:protocol/protocol.dart' show ControlBytes, SgrCodes;

/// SGR escape sequence for bold on/off.
String bold(bool on) => on
    ? '${ControlBytes.csi}${SgrCodes.sgrBold}m'
    : '${ControlBytes.csi}${SgrCodes.sgrNoBoldFaint}m';

/// SGR escape sequence for dim/faint on/off.
String dim(bool on) => on
    ? '${ControlBytes.csi}${SgrCodes.sgrFaint}m'
    : '${ControlBytes.csi}${SgrCodes.sgrNoBoldFaint}m';

/// SGR escape sequence for italic on/off.
String italic(bool on) => on
    ? '${ControlBytes.csi}${SgrCodes.sgrItalic}m'
    : '${ControlBytes.csi}${SgrCodes.sgrNoItalic}m';

/// SGR escape sequence for underline on/off.
String underline(bool on) => on
    ? '${ControlBytes.csi}${SgrCodes.sgrUnderline}m'
    : '${ControlBytes.csi}${SgrCodes.sgrNoUnderline}m';

/// SGR escape sequence for blink on/off.
String blink(bool on) => on
    ? '${ControlBytes.csi}${SgrCodes.sgrBlink}m'
    : '${ControlBytes.csi}${SgrCodes.sgrNoBlink}m';

/// SGR escape sequence for reverse video on/off.
String reverse(bool on) => on
    ? '${ControlBytes.csi}${SgrCodes.sgrReverse}m'
    : '${ControlBytes.csi}${SgrCodes.sgrNoReverse}m';

/// SGR escape sequence for strikethrough on/off.
String strikethrough(bool on) => on
    ? '${ControlBytes.csi}${SgrCodes.sgrStrikethrough}m'
    : '${ControlBytes.csi}${SgrCodes.sgrNoStrikethrough}m';

/// SGR escape sequence for overline on/off.
String overLine(bool on) => on
    ? '${ControlBytes.csi}${SgrCodes.sgrOverline}m'
    : '${ControlBytes.csi}${SgrCodes.sgrNoOverline}m';
