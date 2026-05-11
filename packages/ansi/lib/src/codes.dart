import 'package:protocol/protocol.dart' show Defaults;

String bold(bool on) => on
    ? '${Defaults.csi}${Defaults.sgrBold}m'
    : '${Defaults.csi}${Defaults.sgrNoBoldFaint}m';
String dim(bool on) => on
    ? '${Defaults.csi}${Defaults.sgrFaint}m'
    : '${Defaults.csi}${Defaults.sgrNoBoldFaint}m';
String italic(bool on) => on
    ? '${Defaults.csi}${Defaults.sgrItalic}m'
    : '${Defaults.csi}${Defaults.sgrNoItalic}m';
String underline(bool on) => on
    ? '${Defaults.csi}${Defaults.sgrUnderline}m'
    : '${Defaults.csi}${Defaults.sgrNoUnderline}m';
String blink(bool on) => on
    ? '${Defaults.csi}${Defaults.sgrBlink}m'
    : '${Defaults.csi}${Defaults.sgrNoBlink}m';
String reverse(bool on) => on
    ? '${Defaults.csi}${Defaults.sgrReverse}m'
    : '${Defaults.csi}${Defaults.sgrNoReverse}m';
String strikethrough(bool on) => on
    ? '${Defaults.csi}${Defaults.sgrStrikethrough}m'
    : '${Defaults.csi}${Defaults.sgrNoStrikethrough}m';
String overLine(bool on) => on
    ? '${Defaults.csi}${Defaults.sgrOverline}m'
    : '${Defaults.csi}${Defaults.sgrNoOverline}m';
String resetAll() => '${Defaults.csi}${Defaults.sgrReset}m';
