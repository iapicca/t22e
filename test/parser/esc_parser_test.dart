import 'package:test/test.dart';
import 'package:t22e/src/parser/esc_parser.dart';
import 'package:t22e/src/parser/engine.dart';
import 'package:t22e/src/parser/events.dart';

void main() {
  late EscParser parser;

  setUp(() {
    parser = EscParser();
  });

  group('SS3 F-keys', () {
    test('ESC O P is F1', () {
      final event = parser.parse(EscSequenceData([0x4F], 0x50));
      expect(event, isA<KeyEvent>());
      expect((event as KeyEvent).keyCode, equals(KeyCode.f1));
    });

    test('ESC O Q is F2', () {
      final event = parser.parse(EscSequenceData([0x4F], 0x51));
      expect((event as KeyEvent).keyCode, equals(KeyCode.f2));
    });

    test('ESC O R is F3', () {
      final event = parser.parse(EscSequenceData([0x4F], 0x52));
      expect((event as KeyEvent).keyCode, equals(KeyCode.f3));
    });

    test('ESC O S is F4', () {
      final event = parser.parse(EscSequenceData([0x4F], 0x53));
      expect((event as KeyEvent).keyCode, equals(KeyCode.f4));
    });
  });

  group('internal events', () {
    test('ESC c is reset', () {
      final event = parser.parse(EscSequenceData([], 0x63));
      expect(event, isA<InternalEvent>());
      expect((event as InternalEvent).kind, equals('reset'));
    });
  });

  test('unknown sequence returns null', () {
    final event = parser.parse(EscSequenceData([], 0x5A));
    expect(event, isNull);
  });
}
