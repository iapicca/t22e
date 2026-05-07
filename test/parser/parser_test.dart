import 'package:test/test.dart';
import 'package:t22e/src/parser/parser.dart';
import 'package:t22e/src/parser/events.dart';

void main() {
  late TerminalParser parser;

  setUp(() {
    parser = TerminalParser();
  });

  group('end-to-end parsing', () {
    test('printable characters', () {
      final events = parser.advance('Hello'.codeUnits.toList());
      expect(events.length, equals(5));
      for (final event in events) {
        expect(event, isA<KeyEvent>());
        expect((event as KeyEvent).keyCode, equals(KeyCode.char));
      }
    });

    test('cursor up', () {
      final events = parser.advance([0x1B, 0x5B, 0x41]);
      expect(events.length, equals(1));
      expect(events[0], isA<KeyEvent>());
      expect((events[0] as KeyEvent).keyCode, equals(KeyCode.up));
    });

    test('cursor down with modifier', () {
      final events = parser.advance([0x1B, 0x5B, 0x31, 0x3B, 0x35, 0x42]);
      expect(events.length, equals(1));
      final event = events[0] as KeyEvent;
      expect(event.keyCode, equals(KeyCode.down));
      expect(event.modifiers.ctrl, isTrue);
    });

    test('F5 key', () {
      final events = parser.advance([0x1B, 0x5B, 0x31, 0x35, 0x7E]);
      expect(events.length, equals(1));
      expect((events[0] as KeyEvent).keyCode, equals(KeyCode.f5));
    });

    test('SS3 F1 key', () {
      final events = parser.advance([0x1B, 0x4F, 0x50]);
      expect(events.length, equals(1));
      expect((events[0] as KeyEvent).keyCode, equals(KeyCode.f1));
    });

    test('OSC title change', () {
      final bytes = [0x1B, 0x5D, ...'0;Hello'.codeUnits, 0x07];
      final events = parser.advance(bytes);
      expect(events.length, equals(1));
      expect(events[0], isA<InternalEvent>());
    });

    test('CPR response', () {
      final events = parser.advance([0x1B, 0x5B, 0x31, 0x30, 0x3B, 0x32, 0x30, 0x52]);
      expect(events.length, equals(1));
      expect(events[0], isA<CursorPositionEvent>());
      final cpr = events[0] as CursorPositionEvent;
      expect(cpr.row, equals(10));
      expect(cpr.col, equals(20));
    });

    test('mixed input', () {
      final bytes = [
        0x48, // 'H'
        0x1B, 0x5B, 0x41, // up arrow
        0x69, // 'i'
      ];
      final events = parser.advance(bytes);
      expect(events.length, equals(3));
      expect((events[0] as KeyEvent).codepoint, equals(0x48));
      expect((events[1] as KeyEvent).keyCode, equals(KeyCode.up));
      expect((events[2] as KeyEvent).codepoint, equals(0x69));
    });
  });

  group('reset', () {
    test('reset clears parser state', () {
      parser.advance([0x1B, 0x5B]);
      parser.reset();
      final events = parser.advance([0x48]);
      expect(events.length, equals(1));
      expect((events[0] as KeyEvent).codepoint, equals(0x48));
    });
  });
}
