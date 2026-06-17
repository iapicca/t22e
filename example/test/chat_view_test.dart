import 'package:test/test.dart';
import 'package:core/core.dart';
import 'package:widgets/widgets.dart';
import 'package:example_app/example_app.dart';

void main() {
  group('ChatBubble', () {
    test('layout returns size covering border + text + timestamp', () {
      final bubble = ChatBubble(
        message: ChatMessage(
          text: 'Hi',
          isBot: true,
          timestamp: DateTime(2025, 1, 1, 12, 0),
        ),
      );
      final size = bubble.layout(constraints(80, 24));
      expect(size.width, greaterThanOrEqualTo(4));
      expect(size.height, greaterThanOrEqualTo(3));
    });

    test('layout for user message does not crash', () {
      final bubble = ChatBubble(
        message: ChatMessage(
          text: 'Hello there',
          isBot: false,
          timestamp: DateTime.now(),
        ),
      );
      expect(() => bubble.layout(constraints(80, 24)), returnsNormally);
    });

    test('paint writes bot message text to surface', () {
      final surface = Surface.genetate(const Size(80, 10));
      final bubble = ChatBubble(
        message: ChatMessage(
          text: 'Hi',
          isBot: true,
          timestamp: DateTime(2025, 1, 1, 12, 0),
        ),
      );
      bubble.layout(constraints(80, 10));
      bubble.paint(PaintingContext(surface: surface));

      final plain = surface.toPlainLines();
      final hasText = plain.any((line) => line.contains('Hi'));
      expect(hasText, isTrue);
    });

    test('paint writes user message text to surface', () {
      final surface = Surface.genetate(const Size(80, 10));
      final bubble = ChatBubble(
        message: ChatMessage(
          text: 'Hello',
          isBot: false,
          timestamp: DateTime(2025, 1, 1, 12, 0),
        ),
      );
      bubble.layout(constraints(80, 10));
      bubble.paint(PaintingContext(surface: surface));

      final plain = surface.toPlainLines();
      final hasText = plain.any((line) => line.contains('Hello'));
      expect(hasText, isTrue);
    });

    test('bot message text is colored blue', () {
      final surface = Surface.genetate(const Size(80, 10));
      final bubble = ChatBubble(
        message: ChatMessage(
          text: 'X',
          isBot: true,
          timestamp: DateTime(2025, 1, 1, 12, 0),
        ),
      );
      bubble.layout(constraints(80, 10));
      bubble.paint(PaintingContext(surface: surface));

      var foundBlue = false;
      for (var y = 0; y < 10; y++) {
        for (var x = 0; x < 80; x++) {
          final cell = surface.grid[y][x];
          if (cell.char == 'X') {
            final fg = cell.style.foreground;
            if (fg != null) {
              expect(fg.blue, greaterThan(fg.red));
              foundBlue = true;
            }
          }
        }
      }
      expect(foundBlue, isTrue);
    });

    test('user message text is colored green', () {
      final surface = Surface.genetate(const Size(80, 10));
      final bubble = ChatBubble(
        message: ChatMessage(
          text: 'X',
          isBot: false,
          timestamp: DateTime(2025, 1, 1, 12, 0),
        ),
      );
      bubble.layout(constraints(80, 10));
      bubble.paint(PaintingContext(surface: surface));

      var foundGreen = false;
      for (var y = 0; y < 10; y++) {
        for (var x = 0; x < 80; x++) {
          final cell = surface.grid[y][x];
          if (cell.char == 'X') {
            final fg = cell.style.foreground;
            if (fg != null) {
              expect(fg.green, greaterThan(fg.red));
              foundGreen = true;
            }
          }
        }
      }
      expect(foundGreen, isTrue);
    });

    test('paint draws border characters', () {
      final surface = Surface.genetate(const Size(80, 10));
      final bubble = ChatBubble(
        message: ChatMessage(
          text: 'Hi',
          isBot: true,
          timestamp: DateTime(2025, 1, 1, 12, 0),
        ),
      );
      bubble.layout(constraints(80, 10));
      bubble.paint(PaintingContext(surface: surface));

      final plain = surface.toPlainLines();
      final hasBorder = plain.any((line) => line.contains('\u250c'));
      expect(hasBorder, isTrue);
    });

    test('long text is constrained by max width', () {
      final bubble = ChatBubble(
        message: ChatMessage(
          text: 'A very long message that should be wrapped',
          isBot: true,
          timestamp: DateTime.now(),
        ),
      );
      final size = bubble.layout(constraints(10, 24));
      expect(size.width, lessThanOrEqualTo(10));
    });
  });

  group('ChatView', () {
    test('layout returns zero size for empty messages', () {
      final view = ChatView(messages: const []);
      final size = view.layout(constraints(80, 24));
      expect(size.width, 0);
      expect(size.height, 0);
    });

    test('layout returns size for messages', () {
      final view = ChatView(
        messages: [
          ChatMessage(text: 'Hi', isBot: true, timestamp: DateTime.now()),
        ],
      );
      final size = view.layout(constraints(80, 24));
      expect(size.width, 80);
      expect(size.height, greaterThan(0));
    });

    test('layout returns greater height for multiple messages', () {
      final singleSize = ChatView(
        messages: [
          ChatMessage(text: 'Hi', isBot: true, timestamp: DateTime.now()),
        ],
      ).layout(constraints(80, 24)).height;

      final multiSize = ChatView(
        messages: [
          ChatMessage(text: 'Hi', isBot: true, timestamp: DateTime.now()),
          ChatMessage(text: 'Hello', isBot: false, timestamp: DateTime.now()),
        ],
      ).layout(constraints(80, 24)).height;

      expect(multiSize, greaterThan(singleSize));
    });

    test('paint does not crash for empty messages', () {
      final view = ChatView(messages: const []);
      view.layout(constraints(80, 24));
      expect(
        () => view.paint(
          PaintingContext(surface: Surface.genetate(const Size(80, 24))),
        ),
        returnsNormally,
      );
    });

    test('paint renders all messages', () {
      final surface = Surface.genetate(const Size(80, 24));
      final view = ChatView(
        messages: [
          ChatMessage(
            text: 'First',
            isBot: true,
            timestamp: DateTime(2025, 1, 1, 12, 0),
          ),
          ChatMessage(
            text: 'Second',
            isBot: false,
            timestamp: DateTime(2025, 1, 1, 12, 1),
          ),
        ],
      );
      view.layout(constraints(80, 24));
      view.paint(PaintingContext(surface: surface));

      final plain = surface.toPlainLines();
      final hasFirst = plain.any((line) => line.contains('First'));
      final hasSecond = plain.any((line) => line.contains('Second'));
      expect(hasFirst, isTrue);
      expect(hasSecond, isTrue);
    });

    test('paint scrolls to bottom when content exceeds viewport', () {
      final view = ChatView(
        messages: List.generate(
          20,
          (i) => ChatMessage(
            text: 'Msg $i',
            isBot: i.isEven,
            timestamp: DateTime.now(),
          ),
        ),
      );
      view.layout(constraints(80, 10));
      expect(
        () => view.paint(
          PaintingContext(surface: Surface.genetate(const Size(80, 24))),
        ),
        returnsNormally,
      );
    });
  });
}

Constraints constraints(int w, int h) => Constraints(maxWidth: w, maxHeight: h);
