import 'package:ansi/ansi.dart' show querySyncUpdate;
import 'package:meta/meta.dart';
import 'package:parser/terminal_parser.dart'
    show QuerySyncUpdateEvent, TerminalParser;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:terminal/terminal.dart' show TerminalInterface;
import 'terminal_probe_extension.dart' show TerminalProbeExtension;

/// Probe for synchronized update support via DECRPM query.
@internal
Future<bool> probeSync(
  TerminalInterface io,
  TerminalParser parser, {
  Duration timeout = Defaults.defaultProbeTimeout,
}) async {
  return io.probe<QuerySyncUpdateEvent, bool>(
    query: querySyncUpdate(),
    parser: parser,
    timeout: timeout,
    onEvent: (event) => event.supported,
    onTimeout: () => false,
  );
}
