import 'package:ansi/ansi.dart' show queryDa1;
import 'package:parser/terminal_parser.dart'
    show PrimaryDeviceAttributesEvent, TerminalParser;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:terminal/terminal.dart' show TerminalIo;
import 'result.dart' show QueryResult, Da1Result;
import 'terminal_probe_extension.dart' show TerminalProbeExtension;

@internal
Future<QueryResult<Da1Result>> probeDa1(
  TerminalIo io,
  TerminalParser parser, {
  Duration timeout = Defaults.defaultProbeTimeout,
}) async {
  return io.probe<PrimaryDeviceAttributesEvent, QueryResult<Da1Result>>(
    query: queryDa1(),
    parser: parser,
    timeout: timeout,
    onEvent: (event) {
      final id = event.params.isNotEmpty
          ? event.params[Defaults.da1TerminalIdDefault]
          : 0;
      return QueryResult.supported(
        Da1Result(id, event.params.skip(1).toList()),
      );
    },
    onTimeout: () => const QueryResult.unavailable(),
  );
}
