import 'package:protocol/protocol.dart' show Defaults;

/// Set the terminal window title.
String setTitle(String title) => '${Defaults.osc}0;$title${Defaults.bel}';

/// Wrap text in an OSC 8 hyperlink.
String hyperlink(String uri, String text, {String? id}) {
  final params = id != null ? 'id=$id' : '';
  return '${Defaults.osc}8;$params;$uri${Defaults.bel}$text${Defaults.osc}8;;${Defaults.bel}';
}

/// Enable the Kitty keyboard protocol with given flags.
String enableKittyKeyboard(int flags) => '${Defaults.csi}>${flags}u';

/// Write base64-encoded data to the system clipboard.
String writeClipboard(String base64Data, {String clipboard = 'c'}) =>
    '${Defaults.osc}52;$clipboard;$base64Data${Defaults.bel}';

/// Query the system clipboard contents.
String queryClipboard({String clipboard = 'c'}) =>
    '${Defaults.osc}52;$clipboard;?${Defaults.bel}';
