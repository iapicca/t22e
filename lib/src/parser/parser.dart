import 'engine.dart';
import 'events.dart';
import 'csi_parser.dart';
import 'esc_parser.dart';
import 'osc_parser.dart';
import 'dcs_parser.dart';

/// Full terminal parser: byte stream -> sequence parsing -> event interpretation
class TerminalParser {
  /// The VT500 state machine for breaking bytes into sequences
  final _engine = Vt500Engine();
  /// Parses CSI sequences into events
  final _csiParser = CsiParser();
  /// Parses ESC sequences into events
  final _escParser = EscParser();
  /// Parses OSC sequences into events
  final _oscParser = OscParser();
  /// Parses DCS sequences into events
  final _dcsParser = DcsParser();

  /// Parses raw bytes into a list of terminal events
  List<Event> advance(List<int> bytes) {
    final events = <Event>[];
    for (final seq in _engine.advanceAll(bytes)) {
      final event = _interpret(seq);
      if (event != null) events.add(event);
    }
    return events;
  }

  /// Dispatches a parsed sequence to the appropriate sub-parser
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

  /// Resets the underlying state machine to ground state
  void reset() {
    _engine.reset();
  }
}
