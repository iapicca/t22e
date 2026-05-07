import 'engine.dart';
import 'events.dart';
import 'csi_parser.dart';
import 'esc_parser.dart';
import 'osc_parser.dart';
import 'dcs_parser.dart';

class TerminalParser {
  final _engine = Vt500Engine();
  final _csiParser = CsiParser();
  final _escParser = EscParser();
  final _oscParser = OscParser();
  final _dcsParser = DcsParser();

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
      CharData() => KeyEvent(
          keyCode: KeyCode.char,
          codepoint: seq.codepoint,
        ),
      CsiSequenceData() => _csiParser.parse(seq),
      EscSequenceData() => _escParser.parse(seq),
      OscSequenceData() => _oscParser.parse(seq),
      DcsSequenceData() => _dcsParser.parse(seq),
    };
  }

  void reset() {
    _engine.reset();
  }
}
