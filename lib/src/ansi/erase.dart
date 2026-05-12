import '../well_known.dart' show WellKnown;

/// Erases display region specified by mode
String eraseDisplay(int mode) => '${WellKnown.csi}${mode}J';
/// Erases line region specified by mode
String eraseLine(int mode) => '${WellKnown.csi}${mode}K';
/// Erases the entire screen
String eraseScreen() => '${WellKnown.csi}${WellKnown.eraseDisplayAll}J';
/// Erases screen including scrollback buffer
String eraseSavedLines() => '${WellKnown.csi}${WellKnown.eraseDisplaySaved}J';
/// Erases from cursor to end of line
String eraseLineToEnd() => '${WellKnown.csi}${WellKnown.eraseLineRight}K';
/// Erases from start of line to cursor
String eraseLineToStart() => '${WellKnown.csi}${WellKnown.eraseLineLeft}K';
/// Erases the entire line
String eraseLineAll() => '${WellKnown.csi}${WellKnown.eraseLineAll}K';
