import 'package:test/test.dart';
import 'package:example_app/example_app.dart';

void main() {
  group('ChatMessage', () {
    test('creates with required fields', () {
      final now = DateTime.now();
      final message = ChatMessage(text: 'Hello', isBot: false, timestamp: now);
      expect(message.text, 'Hello');
      expect(message.isBot, false);
      expect(message.timestamp, now);
    });

    test('equality is based on all fields', () {
      final now = DateTime.now();
      final a = ChatMessage(text: 'Hello', isBot: false, timestamp: now);
      final b = ChatMessage(text: 'Hello', isBot: false, timestamp: now);
      expect(a, equals(b));
    });

    test('is not equal when text differs', () {
      final now = DateTime.now();
      final a = ChatMessage(text: 'Hello', isBot: false, timestamp: now);
      final b = ChatMessage(text: 'World', isBot: false, timestamp: now);
      expect(a, isNot(equals(b)));
    });

    test('is not equal when isBot differs', () {
      final now = DateTime.now();
      final a = ChatMessage(text: 'Hello', isBot: false, timestamp: now);
      final b = ChatMessage(text: 'Hello', isBot: true, timestamp: now);
      expect(a, isNot(equals(b)));
    });

    test('copyWith returns a copy with overridden fields', () {
      final now = DateTime.now();
      final original = ChatMessage(text: 'Hello', isBot: false, timestamp: now);
      final copy = original.copyWith(text: 'World');
      expect(copy.text, 'World');
      expect(copy.isBot, false);
      expect(copy.timestamp, now);
    });

    test('copyWith preserves unchanged fields', () {
      final now = DateTime.now();
      final original = ChatMessage(text: 'Hello', isBot: true, timestamp: now);
      final copy = original.copyWith();
      expect(copy, equals(original));
    });

    test('toString includes text', () {
      final now = DateTime(2025, 1, 1, 12, 0);
      final message = ChatMessage(text: 'Hello', isBot: false, timestamp: now);
      expect(message.toString(), contains('Hello'));
    });
  });
}
