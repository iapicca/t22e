import 'package:ansi/ansi.dart' show AnsiDefaults;
import 'package:meta/meta.dart';
import 'package:parser/terminal_parser.dart'
    show PrimaryDeviceAttributesEvent, TerminalParser;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:terminal/terminal.dart' show SystemIo;
import 'capabilities.dart' show QueryResult, Da1Result;
import 'system_io_probe_extension.dart' show SystemIoProbeExtension;


/// Probe for primary device attributes (DA1) via CSI c query.
@internal
Future<QueryResult<Da1Result>> probeDa1(
  SystemIo io,
  TerminalParser parser, 
  Duration timeout ,) =>
   io.probeTerminal<PrimaryDeviceAttributesEvent, QueryResult<Da1Result>>(
    query: AnsiDefaults.queryDa1,
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

