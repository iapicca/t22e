import 'dart:io';
import 'package:test/test.dart';
import 'package:t22e/src/terminal/runner.dart';

void main() {
  group('TerminalRunner', () {
    test('initial state is not raw mode', () {
      final runner = TerminalRunner();
      expect(runner.isRawMode, isFalse);
    });

    test('enterRawMode does not throw', () {
      final runner = TerminalRunner();
      runner.enterRawMode();
      runner.exitRawMode();
    });

    test('exitRawMode is idempotent', () {
      final runner = TerminalRunner();
      runner.exitRawMode();
      runner.exitRawMode();
      expect(runner.isRawMode, isFalse);
    });

    test('enterRawMode is idempotent', () {
      final runner = TerminalRunner();
      runner.enterRawMode();
      runner.enterRawMode();
      runner.exitRawMode();
      expect(runner.isRawMode, isFalse);
    });

    test('runWithRawMode executes body and restores', () {
      final runner = TerminalRunner();
      var executed = false;
      runner.runWithRawMode(() {
        executed = true;
      });
      expect(executed, isTrue);
      expect(runner.isRawMode, isFalse);
    });

    test('runWithRawMode restores on exception', () {
      final runner = TerminalRunner();
      expect(
        () => runner.runWithRawMode(() {
          throw StateError('test error');
        }),
        throwsStateError,
      );
      expect(runner.isRawMode, isFalse);
    });
  });
}
