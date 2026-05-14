import 'engine.dart';
import 'events.dart';
import 'csi_parser.dart';
import 'esc_parser.dart';
import 'osc_parser.dart';
import 'dcs_parser.dart';

/// Top-level terminal parser: runs bytes through the engine, dispatches to sub-parsers.
class TerminalParser {
  final _engine = Vt500Engine();
  final _csiParser = CsiParser();
  final _escParser = EscParser();
  final _oscParser = OscParser();
  final _dcsParser = DcsParser();

  /// Parses raw byte input into a list of terminal events.
  List<Event> advance(List<int> bytes) {
    final events = <Event>[];
    for (final seq in _engine.advanceAll(bytes)) {
      final event = _interpret(seq);
      if (event != null) events.add(event);
    }
    return events;
  }

  /// Interprets parsed sequence data into a typed Event.
  Event? _interpret(SequenceData seq) {
    return switch (seq) {
      CharData() => KeyEvent(keyCode: KeyCode.char, codepoint: seq.codepoint),
      CsiSequenceData() => _csiParser.parse(seq),
      EscSequenceData() => _escParser.parse(seq),
      OscSequenceData() => _oscParser.parse(seq),
      DcsSequenceData() => _dcsParser.parse(seq),
    };
  }

  /// Resets the underlying byte engine state.
  void reset() {
    _engine.reset();
  }
}
