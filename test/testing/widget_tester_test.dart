import 'package:test/test.dart';
import 'package:t22e/src/testing/widget_tester.dart';
import 'package:t22e/src/widgets/basic/text.dart';
import 'package:t22e/src/widgets/basic/link.dart';

void main() {
  group('WidgetTester', () {
    test('pumpWidget renders Text', () {
      final tester = WidgetTester(width: 40, height: 10);
      tester.pumpWidget(Text('Hello'), width: 40, height: 10);
      expect(tester.virtualTerminal.cellAt(0, 0).char, equals('H'));
      expect(tester.virtualTerminal.cellAt(0, 4).char, equals('o'));
    });

    test('pumpWidget renders empty text', () {
      final tester = WidgetTester(width: 40, height: 10);
      tester.pumpWidget(Text(''), width: 40, height: 10);
      expect(tester.virtualTerminal.plainText(), isNotEmpty);
    });

    test('expectCell works for char', () {
      final tester = WidgetTester(width: 40, height: 10);
      tester.pumpWidget(Text('Hi'), width: 40, height: 10);
      tester.expectCell(0, 0, char: 'H');
      tester.expectCell(0, 1, char: 'i');
    });

    test('virtual terminal contains rendered text', () {
      final tester = WidgetTester(width: 40, height: 10);
      tester.pumpWidget(Text('Hi'), width: 40, height: 10);
      expect(tester.virtualTerminal.cellAt(0, 0).char, equals('H'));
      expect(tester.virtualTerminal.cellAt(0, 1).char, equals('i'));
    });

    test('Hyperlink renders through pumpWidget', () {
      final tester = WidgetTester(width: 40, height: 10);
      tester.pumpWidget(Hyperlink('https://example.com', 'Click'), width: 40, height: 10);
      expect(tester.virtualTerminal.cellAt(0, 0).char, equals('C'));
      expect(tester.virtualTerminal.cellAt(0, 4).char, equals('k'));
    });
  });
}
