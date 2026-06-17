import 'package:protocol/protocol.dart' show ControlBytes;

/// Set the terminal window title.
String setTitle(String title) =>
    '${ControlBytes.osc}0;$title${ControlBytes.bel}';

/// Wrap text in an OSC 8 hyperlink.
String hyperlink(String uri, String text, {String? id}) {
  final params = id != null ? 'id=$id' : '';
  return '${ControlBytes.osc}8;$params;$uri${ControlBytes.bel}$text${ControlBytes.osc}8;;${ControlBytes.bel}';
}

/// Enable the Kitty keyboard protocol with given flags.
String enableKittyKeyboard(int flags) => '${ControlBytes.csi}>${flags}u';

/// Write base64-encoded data to the system clipboard.
String writeClipboard(String base64Data, {String clipboard = 'c'}) =>
    '${ControlBytes.osc}52;$clipboard;$base64Data${ControlBytes.bel}';

/// Query the system clipboard contents.
String queryClipboard({String clipboard = 'c'}) =>
    '${ControlBytes.osc}52;$clipboard;?${ControlBytes.bel}';
