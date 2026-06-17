import 'engine.dart';
import 'sequence_data.dart';
import 'events.dart';

/// VT500-compatible terminal input parser.
///
/// Use [terminalParserProvider] instead of instantiating directly.
class TerminalParser {
  final Vt500Engine _engine;
  final Parser csiParser;
  final Parser escParser;
  final Parser oscParser;
  final Parser dcsParser;

  TerminalParser({
    required this._engine,
    required this.csiParser,
    required this.escParser,
    required this.oscParser,
    required this.dcsParser,
  });

  List<Event> advance(List<int> bytes) => [
    for (final seq in _engine.advanceAll(bytes)) ?_interpret(seq),
  ];

  Event? _interpret(SequenceData seq) {
    return switch (seq) {
      CharData() => KeyEvent(keyCode: KeyCode.char, codepoint: seq.codepoint),
      CsiSequenceData() => csiParser(seq),
      EscSequenceData() => escParser(seq),
      OscSequenceData() => oscParser(seq),
      DcsSequenceData() => dcsParser(seq),
    };
  }

  void reset() {
    _engine.reset();
  }
}
