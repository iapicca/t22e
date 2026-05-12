import '../well_known.dart' show WellKnown;

/// Switches to the alternate screen buffer
String enterAltScreen() => '${WellKnown.csi}?${WellKnown.decModeAltScreen}h';
/// Switches back to the main screen buffer
String exitAltScreen() => '${WellKnown.csi}?${WellKnown.decModeAltScreen}l';
/// Enables normal mouse tracking
String enableNormalMouse() => '${WellKnown.csi}?${WellKnown.decModeMouseNormal}h';
/// Disables all mouse tracking modes
String disableMouse() => '${WellKnown.csi}?${WellKnown.decModeMouseNormal}l${WellKnown.csi}?${WellKnown.decModeMouseButton}l${WellKnown.csi}?${WellKnown.decModeMouseSgr}l';
/// Enables button-event mouse tracking
String enableButtonEvents() => '${WellKnown.csi}?${WellKnown.decModeMouseButton}h';
/// Enables SGR extended mouse mode
String enableSgrMouse() => '${WellKnown.csi}?${WellKnown.decModeMouseSgr}h';
/// Begins a synchronized update frame
String startSync() => '${WellKnown.csi}?${WellKnown.decModeSync}h';
/// Ends a synchronized update frame
String endSync() => '${WellKnown.csi}?${WellKnown.decModeSync}l';
/// Enables bracketed paste mode
String enableBracketedPaste() => '${WellKnown.csi}?${WellKnown.decModeBracketedPaste}h';
/// Disables bracketed paste mode
String disableBracketedPaste() => '${WellKnown.csi}?${WellKnown.decModeBracketedPaste}l';
/// Enables focus in/out event reporting
String enableFocusTracking() => '${WellKnown.csi}?${WellKnown.decModeFocus}h';
/// Disables focus in/out event reporting
String disableFocusTracking() => '${WellKnown.csi}?${WellKnown.decModeFocus}l';
/// Sets the terminal window title
String setTitle(String title) => '${WellKnown.osc}0;$title${WellKnown.bel}';
/// Wraps text in a terminal hyperlink
String hyperlink(String uri, String text, {String? id}) {
  final params = id != null ? 'id=$id' : '';
  return '${WellKnown.osc}8;$params;$uri${WellKnown.bel}$text${WellKnown.osc}8;;${WellKnown.bel}';
}
/// Enables Kitty keyboard protocol
String enableKittyKeyboard(int flags) => '${WellKnown.csi}>${flags}u';
/// Disables Kitty keyboard protocol
String disableKittyKeyboard() => '${WellKnown.csi}<u';
/// Queries Kitty keyboard protocol support
String queryKittyKeyboard() => '${WellKnown.csi}?u';
/// Queries the terminal's default foreground color
String queryForegroundColor() => '${WellKnown.osc}10;?${WellKnown.bel}';
/// Queries the terminal's default background color
String queryBackgroundColor() => '${WellKnown.osc}11;?${WellKnown.bel}';
/// Queries the current cursor position
String queryCursorPosition() => '${WellKnown.csi}6n';
/// Sends primary device attributes query (DA1)
String queryDa1() => '${WellKnown.csi}c';
/// Queries whether synchronized updates are supported
String querySyncUpdate() => '${WellKnown.csi}?${WellKnown.decModeSync}\$p';
/// Soft terminal reset (DECSTR)
String softReset() => '${WellKnown.csi}!p';
/// Writes base64 data to the system clipboard
String writeClipboard(String base64Data, {String clipboard = 'c'}) =>
    '${WellKnown.osc}52;$clipboard;$base64Data${WellKnown.bel}';
/// Queries clipboard contents from the terminal
String queryClipboard({String clipboard = 'c'}) =>
    '${WellKnown.osc}52;$clipboard;?${WellKnown.bel}';
/// Enables all mouse tracking modes (normal + button + SGR)
String enableMouse() => '${WellKnown.csi}?${WellKnown.decModeMouseNormal}h${WellKnown.csi}?${WellKnown.decModeMouseButton}h${WellKnown.csi}?${WellKnown.decModeMouseSgr}h';
