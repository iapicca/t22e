import 'package:test/test.dart';
import 'package:terminal/terminal.dart';

void main() {
  group('TerminalRunner', () {
    test('initial state is not raw mode', () {
      final runner = TerminalRunner();
      expect(runner.isRawMode, isFalse);
    });

    test('enterRawMode sets raw mode', () {
      final runner = TerminalRunner();
      runner.enterRawMode();
      expect(runner.isRawMode, isTrue);
    });

    test('exitRawMode unsets raw mode', () {
      final runner = TerminalRunner();
      runner.enterRawMode();
      runner.exitRawMode();
      expect(runner.isRawMode, isFalse);
    });
  });
}
