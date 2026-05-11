import '../well_known.dart' show WellKnown;

String enterAltScreen() => '${WellKnown.csi}?${WellKnown.decModeAltScreen}h';
String exitAltScreen() => '${WellKnown.csi}?${WellKnown.decModeAltScreen}l';
String enableNormalMouse() => '${WellKnown.csi}?${WellKnown.decModeMouseNormal}h';
String disableMouse() => '${WellKnown.csi}?${WellKnown.decModeMouseNormal}l${WellKnown.csi}?${WellKnown.decModeMouseButton}l${WellKnown.csi}?${WellKnown.decModeMouseSgr}l';
String enableButtonEvents() => '${WellKnown.csi}?${WellKnown.decModeMouseButton}h';
String enableSgrMouse() => '${WellKnown.csi}?${WellKnown.decModeMouseSgr}h';
String startSync() => '${WellKnown.csi}?${WellKnown.decModeSync}h';
String endSync() => '${WellKnown.csi}?${WellKnown.decModeSync}l';
String enableBracketedPaste() => '${WellKnown.csi}?${WellKnown.decModeBracketedPaste}h';
String disableBracketedPaste() => '${WellKnown.csi}?${WellKnown.decModeBracketedPaste}l';
String enableFocusTracking() => '${WellKnown.csi}?${WellKnown.decModeFocus}h';
String disableFocusTracking() => '${WellKnown.csi}?${WellKnown.decModeFocus}l';
String setTitle(String title) => '${WellKnown.osc}0;$title${WellKnown.bel}';
String hyperlink(String uri, String text, {String? id}) {
  final params = id != null ? 'id=$id' : '';
  return '${WellKnown.osc}8;$params;$uri${WellKnown.bel}$text${WellKnown.osc}8;;${WellKnown.bel}';
}
String enableKittyKeyboard(int flags) => '${WellKnown.csi}>${flags}u';
String disableKittyKeyboard() => '${WellKnown.csi}<u';
String queryKittyKeyboard() => '${WellKnown.csi}?u';
String queryForegroundColor() => '${WellKnown.osc}10;?${WellKnown.bel}';
String queryBackgroundColor() => '${WellKnown.osc}11;?${WellKnown.bel}';
String queryCursorPosition() => '${WellKnown.csi}6n';
String queryDa1() => '${WellKnown.csi}c';
String querySyncUpdate() => '${WellKnown.csi}?${WellKnown.decModeSync}\$p';
String softReset() => '${WellKnown.csi}!p';
String writeClipboard(String base64Data, {String clipboard = 'c'}) =>
    '${WellKnown.osc}52;$clipboard;$base64Data${WellKnown.bel}';
String queryClipboard({String clipboard = 'c'}) =>
    '${WellKnown.osc}52;$clipboard;?${WellKnown.bel}';
String enableMouse() => '${WellKnown.csi}?${WellKnown.decModeMouseNormal}h${WellKnown.csi}?${WellKnown.decModeMouseButton}h${WellKnown.csi}?${WellKnown.decModeMouseSgr}h';
