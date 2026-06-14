import 'package:ansi/ansi.dart' show AnsiDefaults;
import 'package:meta/meta.dart';
import 'package:parser/terminal_parser.dart'
    show PrimaryDeviceAttributesEvent, TerminalParser;
import 'package:protocol/protocol.dart' show Da1Codes;
import 'package:terminal/terminal.dart' show SystemIo;
import 'da1_query.dart' show Da1Query;
import 'probe_definitions.dart' show Da1Probe;
import 'system_io_probe_extension.dart' show SystemIoProbeExtension;

/// Probe for primary device attributes (DA1) via CSI c query.
@internal
Da1Probe probeDa1(SystemIo io, TerminalParser parser, Duration timeout) =>
    io.probeTerminal<PrimaryDeviceAttributesEvent, Da1Query>(
      query: AnsiDefaults.queryDa1,
      parser: parser,
      timeout: timeout,
      onEvent: (event) {
        final id = event.params.isNotEmpty
            ? event.params[Da1Codes.da1TerminalIdDefault]
            : 0;
        return Da1Query.supported(id, [...event.params.skip(1)]);
      },
      onTimeout: () => const Da1Query.unsupported(),
    );
