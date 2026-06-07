import 'package:ansi/ansi.dart' show querySyncUpdate;
import 'package:meta/meta.dart';
import 'package:parser/terminal_parser.dart'
    show QuerySyncUpdateEvent, TerminalParser;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:terminal/terminal.dart' show SystemIo;
import 'terminal_probe_extension.dart' show probeTerminal;

/// Probe for synchronized update support via DECRPM query.
@internal
Future<bool> probeSync(
  SystemIo io,
  TerminalParser parser, {
  Duration timeout = Defaults.defaultProbeTimeout,
}) async {
  return probeTerminal<QuerySyncUpdateEvent, bool>(
    query: querySyncUpdate(),
    io: io,
    parser: parser,
    timeout: timeout,
    onEvent: (event) => event.supported,
    onTimeout: () => false,
  );
}
