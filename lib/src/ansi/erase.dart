import '../well_known.dart' show WellKnown;

String eraseDisplay(int mode) => '${WellKnown.csi}${mode}J';
String eraseLine(int mode) => '${WellKnown.csi}${mode}K';
String eraseScreen() => '${WellKnown.csi}${WellKnown.eraseDisplayAll}J';
String eraseSavedLines() => '${WellKnown.csi}${WellKnown.eraseDisplaySaved}J';
String eraseLineToEnd() => '${WellKnown.csi}${WellKnown.eraseLineRight}K';
String eraseLineToStart() => '${WellKnown.csi}${WellKnown.eraseLineLeft}K';
String eraseLineAll() => '${WellKnown.csi}${WellKnown.eraseLineAll}K';
