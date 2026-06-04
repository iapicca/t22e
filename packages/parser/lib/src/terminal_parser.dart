import 'engine.dart';
import 'events.dart';

/// VT500-compatible terminal input parser.
///
/// Use [terminalParserProvider] instead of instantiating directly.

/// TODO `  final _engine = Vt500Engine();` should be injected with riverpod!
class TerminalParser {
  final _engine = Vt500Engine();
  final Parser csiParser;
  final Parser escParser;
  final Parser oscParser;
  final Parser dcsParser;

  TerminalParser({
    required this.csiParser,
    required this.escParser,
    required this.oscParser,
    required this.dcsParser,
  });

  List<Event> advance(List<int> bytes) {
    final events = <Event>[];
    for (final seq in _engine.advanceAll(bytes)) {
      final event = _interpret(seq);
      if (event != null) events.add(event);
    }
    return events;
  }

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
