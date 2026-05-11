import 'package:protocol/protocol.dart' show Defaults;

String enterAltScreen() => '${Defaults.csi}?${Defaults.decModeAltScreen}h';
String exitAltScreen() => '${Defaults.csi}?${Defaults.decModeAltScreen}l';
String enableNormalMouse() => '${Defaults.csi}?${Defaults.decModeMouseNormal}h';
String disableMouse() =>
    '${Defaults.csi}?${Defaults.decModeMouseNormal}l${Defaults.csi}?${Defaults.decModeMouseButton}l${Defaults.csi}?${Defaults.decModeMouseSgr}l';
String enableButtonEvents() =>
    '${Defaults.csi}?${Defaults.decModeMouseButton}h';
String enableSgrMouse() => '${Defaults.csi}?${Defaults.decModeMouseSgr}h';
String startSync() => '${Defaults.csi}?${Defaults.decModeSync}h';
String endSync() => '${Defaults.csi}?${Defaults.decModeSync}l';
String enableBracketedPaste() =>
    '${Defaults.csi}?${Defaults.decModeBracketedPaste}h';
String disableBracketedPaste() =>
    '${Defaults.csi}?${Defaults.decModeBracketedPaste}l';
String enableFocusTracking() => '${Defaults.csi}?${Defaults.decModeFocus}h';
String disableFocusTracking() => '${Defaults.csi}?${Defaults.decModeFocus}l';
String setTitle(String title) => '${Defaults.osc}0;$title${Defaults.bel}';
String hyperlink(String uri, String text, {String? id}) {
  final params = id != null ? 'id=$id' : '';
  return '${Defaults.osc}8;$params;$uri${Defaults.bel}$text${Defaults.osc}8;;${Defaults.bel}';
}

String enableKittyKeyboard(int flags) => '${Defaults.csi}>${flags}u';
String disableKittyKeyboard() => '${Defaults.csi}<u';
String queryKittyKeyboard() => '${Defaults.csi}?u';
String queryForegroundColor() => '${Defaults.osc}10;?${Defaults.bel}';
String queryBackgroundColor() => '${Defaults.osc}11;?${Defaults.bel}';
String queryCursorPosition() => '${Defaults.csi}6n';
String queryDa1() => '${Defaults.csi}c';
String querySyncUpdate() => '${Defaults.csi}?${Defaults.decModeSync}\$p';
String softReset() => '${Defaults.csi}!p';
String writeClipboard(String base64Data, {String clipboard = 'c'}) =>
    '${Defaults.osc}52;$clipboard;$base64Data${Defaults.bel}';
String queryClipboard({String clipboard = 'c'}) =>
    '${Defaults.osc}52;$clipboard;?${Defaults.bel}';
String enableMouse() =>
    '${Defaults.csi}?${Defaults.decModeMouseNormal}h${Defaults.csi}?${Defaults.decModeMouseButton}h${Defaults.csi}?${Defaults.decModeMouseSgr}h';
