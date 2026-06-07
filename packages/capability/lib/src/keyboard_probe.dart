import 'package:ansi/ansi.dart' show enableKittyKeyboard, disableKittyKeyboard;
import 'package:meta/meta.dart';
import 'package:parser/terminal_parser.dart'
    show KeyboardEnhancementFlagsEvent, TerminalParser;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:terminal/terminal.dart' show SystemIo;
import 'result.dart' show KeyboardProtocol;
import 'terminal_probe_extension.dart' show probeTerminal;

/// Probe for Kitty keyboard protocol via enable/query/disable sequence.
@internal
Future<KeyboardProtocol> probeKeyboard(
  SystemIo io,
  TerminalParser parser, {
  Duration timeout = Defaults.defaultProbeTimeout,
}) async {
  final result =
      await probeTerminal<KeyboardEnhancementFlagsEvent, KeyboardProtocol>(
        query: enableKittyKeyboard(Defaults.kittyDisambiguate),
        io: io,
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
