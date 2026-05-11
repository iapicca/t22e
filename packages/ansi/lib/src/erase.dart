import 'package:protocol/protocol.dart' show Defaults;

String eraseDisplay(int mode) => '${Defaults.csi}${mode}J';
String eraseLine(int mode) => '${Defaults.csi}${mode}K';
String eraseScreen() => '${Defaults.csi}${Defaults.eraseDisplayAll}J';
String eraseSavedLines() => '${Defaults.csi}${Defaults.eraseDisplaySaved}J';
String eraseLineToEnd() => '${Defaults.csi}${Defaults.eraseLineRight}K';
String eraseLineToStart() => '${Defaults.csi}${Defaults.eraseLineLeft}K';
String eraseLineAll() => '${Defaults.csi}${Defaults.eraseLineAll}K';
