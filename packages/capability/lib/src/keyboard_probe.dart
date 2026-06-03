import 'package:ansi/ansi.dart' show enableKittyKeyboard, disableKittyKeyboard;
import 'package:parser/terminal_parser.dart'
    show KeyboardEnhancementFlagsEvent, TerminalParser;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:terminal/terminal.dart' show TerminalIo;
import 'result.dart' show KeyboardProtocol;
import 'terminal_probe_extension.dart' show TerminalProbeExtension;

@internal
Future<KeyboardProtocol> probeKeyboard(
  TerminalIo io,
  TerminalParser parser, {
  Duration timeout = Defaults.defaultProbeTimeout,
}) async {
  final result = await io.probe<KeyboardEnhancementFlagsEvent, KeyboardProtocol>(
    query: enableKittyKeyboard(Defaults.kittyDisambiguate),
    parser: parser,
    timeout: timeout,
    onEvent: (event) => KeyboardProtocol.kitty,
    onTimeout: () => KeyboardProtocol.basic,
  );
  if (result == KeyboardProtocol.basic) {
    io.write(disableKittyKeyboard());
  }
  return result;
}
