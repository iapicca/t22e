import 'ansi/ansi_test.dart' as ansi;
import 'unicode/unicode_test.dart' as unicode;
import 'parser/events_test.dart' as events;
import 'parser/engine_test.dart' as engine;
import 'parser/csi_parser_test.dart' as csi;
import 'parser/esc_parser_test.dart' as esc;
import 'parser/osc_parser_test.dart' as osc;
import 'parser/dcs_parser_test.dart' as dcs;
import 'parser/parser_test.dart' as parser;
import 'terminal/terminal_test.dart' as terminal;

void main() {
  ansi.main();
  unicode.main();
  events.main();
  engine.main();
  csi.main();
  esc.main();
  osc.main();
  dcs.main();
  parser.main();
  terminal.main();
}
