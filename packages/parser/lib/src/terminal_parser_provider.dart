import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'csi_parser_provider.dart' show csiParserProvider;
import 'esc_parser_provider.dart' show escParserProvider;
import 'osc_parser_provider.dart' show oscParserProvider;
import 'dcs_parser_provider.dart' show dcsParserProvider;
import 'terminal_parser.dart' show TerminalParser;

part 'terminal_parser_provider.g.dart';

@riverpod
TerminalParser terminalParser(Ref ref) {
  final csiParser = ref.read(csiParserProvider);
  final escParser = ref.read(escParserProvider);
  final oscParser = ref.read(oscParserProvider);
  final dcsParser = ref.read(dcsParserProvider);

  return TerminalParser(
    csiParser: csiParser,
    escParser: escParser,
    oscParser: oscParser,
    dcsParser: dcsParser,
  );
}
