import 'package:ansi/ansi.dart' show enableKittyKeyboard, AnsiDefaults;
import 'package:meta/meta.dart';
import 'package:parser/terminal_parser.dart'
    show KeyboardEnhancementFlagsEvent, TerminalParser;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:terminal/terminal.dart' show SystemIo;
import 'capabilities.dart' show KeyboardProtocol;
import 'system_io_probe_extension.dart' show SystemIoProbeExtension;

/// Probe for Kitty keyboard protocol via enable/query/disable sequence.
@internal
Future<KeyboardProtocol> probeKeyboard(
  SystemIo io,
  TerminalParser parser, {
  Duration timeout = Defaults.defaultProbeTimeout,
}) async {
  final result =
      await io.probeTerminal<KeyboardEnhancementFlagsEvent, KeyboardProtocol>(
        query: enableKittyKeyboard(Defaults.kittyDisambiguate),
        parser: parser,
        timeout: timeout,
        onEvent: (event) => KeyboardProtocol.kitty,
        onTimeout: () => KeyboardProtocol.basic,
      );
  if (result == KeyboardProtocol.basic) {
    io.write(AnsiDefaults.disableKittyKeyboard);
  }
  return result;
}
