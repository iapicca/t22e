import 'package:protocol/protocol.dart' show Defaults;

/// SGR escape sequence for bold on/off.
String bold(bool on) => on
    ? '${Defaults.csi}${Defaults.sgrBold}m'
    : '${Defaults.csi}${Defaults.sgrNoBoldFaint}m';
/// SGR escape sequence for dim/faint on/off.
String dim(bool on) => on
    ? '${Defaults.csi}${Defaults.sgrFaint}m'
    : '${Defaults.csi}${Defaults.sgrNoBoldFaint}m';
/// SGR escape sequence for italic on/off.
String italic(bool on) => on
    ? '${Defaults.csi}${Defaults.sgrItalic}m'
    : '${Defaults.csi}${Defaults.sgrNoItalic}m';
/// SGR escape sequence for underline on/off.
String underline(bool on) => on
    ? '${Defaults.csi}${Defaults.sgrUnderline}m'
    : '${Defaults.csi}${Defaults.sgrNoUnderline}m';
/// SGR escape sequence for blink on/off.
String blink(bool on) => on
    ? '${Defaults.csi}${Defaults.sgrBlink}m'
    : '${Defaults.csi}${Defaults.sgrNoBlink}m';
/// SGR escape sequence for reverse video on/off.
String reverse(bool on) => on
    ? '${Defaults.csi}${Defaults.sgrReverse}m'
    : '${Defaults.csi}${Defaults.sgrNoReverse}m';
/// SGR escape sequence for strikethrough on/off.
String strikethrough(bool on) => on
    ? '${Defaults.csi}${Defaults.sgrStrikethrough}m'
    : '${Defaults.csi}${Defaults.sgrNoStrikethrough}m';
/// SGR escape sequence for overline on/off.
String overLine(bool on) => on
    ? '${Defaults.csi}${Defaults.sgrOverline}m'
    : '${Defaults.csi}${Defaults.sgrNoOverline}m';
/// SGR escape sequence to reset all text attributes.
String resetAll() => '${Defaults.csi}${Defaults.sgrReset}m';
