import 'package:protocol/protocol.dart' show Defaults;

/// Enter the alternate screen buffer.
String enterAltScreen() => '${Defaults.csi}?${Defaults.decModeAltScreen}h';
/// Exit the alternate screen buffer.
String exitAltScreen() => '${Defaults.csi}?${Defaults.decModeAltScreen}l';
/// Enable normal (X10) mouse tracking.
String enableNormalMouse() => '${Defaults.csi}?${Defaults.decModeMouseNormal}h';
/// Disable all mouse tracking modes.
String disableMouse() =>
    '${Defaults.csi}?${Defaults.decModeMouseNormal}l${Defaults.csi}?${Defaults.decModeMouseButton}l${Defaults.csi}?${Defaults.decModeMouseSgr}l';
/// Enable button-event mouse tracking.
String enableButtonEvents() =>
    '${Defaults.csi}?${Defaults.decModeMouseButton}h';
/// Enable SGR extended mouse reporting.
String enableSgrMouse() => '${Defaults.csi}?${Defaults.decModeMouseSgr}h';
/// Start a synchronized update batch.
String startSync() => '${Defaults.csi}?${Defaults.decModeSync}h';
/// End a synchronized update batch.
String endSync() => '${Defaults.csi}?${Defaults.decModeSync}l';
/// Enable bracketed paste mode.
String enableBracketedPaste() =>
    '${Defaults.csi}?${Defaults.decModeBracketedPaste}h';
/// Disable bracketed paste mode.
String disableBracketedPaste() =>
    '${Defaults.csi}?${Defaults.decModeBracketedPaste}l';
/// Enable focus event tracking.
String enableFocusTracking() => '${Defaults.csi}?${Defaults.decModeFocus}h';
/// Disable focus event tracking.
String disableFocusTracking() => '${Defaults.csi}?${Defaults.decModeFocus}l';
/// Set the terminal window title.
String setTitle(String title) => '${Defaults.osc}0;$title${Defaults.bel}';
/// Wrap text in an OSC 8 hyperlink.
String hyperlink(String uri, String text, {String? id}) {
  final params = id != null ? 'id=$id' : '';
  return '${Defaults.osc}8;$params;$uri${Defaults.bel}$text${Defaults.osc}8;;${Defaults.bel}';
}

/// Enable the Kitty keyboard protocol with given flags.
String enableKittyKeyboard(int flags) => '${Defaults.csi}>${flags}u';
/// Disable the Kitty keyboard protocol.
String disableKittyKeyboard() => '${Defaults.csi}<u';
/// Query the Kitty keyboard protocol status.
String queryKittyKeyboard() => '${Defaults.csi}?u';
/// Query the terminal's default foreground color.
String queryForegroundColor() => '${Defaults.osc}10;?${Defaults.bel}';
/// Query the terminal's default background color.
String queryBackgroundColor() => '${Defaults.osc}11;?${Defaults.bel}';
/// Request the current cursor position from the terminal.
String queryCursorPosition() => '${Defaults.csi}6n';
/// Request primary device attributes (DA1).
String queryDa1() => '${Defaults.csi}c';
/// Query synchronized update support via DECRPM.
String querySyncUpdate() => '${Defaults.csi}?${Defaults.decModeSync}\$p';
/// Soft reset the terminal.
String softReset() => '${Defaults.csi}!p';
/// Write base64-encoded data to the system clipboard.
String writeClipboard(String base64Data, {String clipboard = 'c'}) =>
    '${Defaults.osc}52;$clipboard;$base64Data${Defaults.bel}';
/// Query the system clipboard contents.
String queryClipboard({String clipboard = 'c'}) =>
    '${Defaults.osc}52;$clipboard;?${Defaults.bel}';
/// Enable all mouse tracking modes (normal, button-event, SGR).
String enableMouse() =>
    '${Defaults.csi}?${Defaults.decModeMouseNormal}h${Defaults.csi}?${Defaults.decModeMouseButton}h${Defaults.csi}?${Defaults.decModeMouseSgr}h';
