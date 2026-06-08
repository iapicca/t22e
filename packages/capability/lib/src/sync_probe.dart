import 'package:ansi/ansi.dart' show AnsiDefaults;
import 'package:meta/meta.dart';
import 'package:parser/terminal_parser.dart'
    show QuerySyncUpdateEvent, TerminalParser;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:terminal/terminal.dart' show SystemIo;

import 'system_io_probe_extension.dart' show SystemIoProbeExtension;


/// Probe for synchronized update support via DECRPM query.
@internal
Future<bool> probeSync(
  SystemIo io,
  TerminalParser parser, {
  Duration timeout = Defaults.defaultProbeTimeout,
}) async {
  return io.probeTerminal<QuerySyncUpdateEvent, bool>(
    query: AnsiDefaults.querySyncUpdate,
    parser: parser,
    timeout: timeout,
    onEvent: (event) => event.supported,
    onTimeout: () => false,
  );
}
