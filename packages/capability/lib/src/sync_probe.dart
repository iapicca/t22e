import 'package:ansi/ansi.dart' show querySyncUpdate;
import 'package:notifier/notifier.dart' show Disposable;
import 'package:parser/terminal_parser.dart'
    show QuerySyncUpdateEvent, TerminalParser;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:terminal/terminal.dart' show TerminalIo;
import 'terminal_probe_extension.dart' show TerminalProbeExtension;

@internal
Future<bool> probeSync(
  TerminalIo io,
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
