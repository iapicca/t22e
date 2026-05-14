import 'package:test/test.dart';
import 'package:terminal/terminal.dart';

class FakeRawModeBackend implements RawModeBackend {
  bool enabled = false;

  @override
  void enable() {
    enabled = true;
  }

  @override
  void disable() {
    enabled = false;
  }
}

void main() {
  group('TerminalRunner', () {
    test('initial state is not raw mode', () {
      final runner = TerminalRunner(
        backends: [FakeRawModeBackend()],
      );
      expect(runner.isRawMode, isFalse);
    });

    test('enterRawMode sets raw mode', () {
      final runner = TerminalRunner(
        backends: [FakeRawModeBackend()],
      );
      runner.enterRawMode();
      expect(runner.isRawMode, isTrue);
    });

    test('exitRawMode unsets raw mode', () {
      final runner = TerminalRunner(
        backends: [FakeRawModeBackend()],
      );
      runner.enterRawMode();
      runner.exitRawMode();
      expect(runner.isRawMode, isFalse);
    });

    test('enterRawMode is idempotent', () {
      final backend = FakeRawModeBackend();
      final runner = TerminalRunner(backends: [backend]);
      runner.enterRawMode();
      runner.enterRawMode();
      expect(backend.enabled, isTrue);
      expect(runner.isRawMode, isTrue);
    });

    test('exitRawMode is idempotent', () {
      final runner = TerminalRunner(
        backends: [FakeRawModeBackend()],
      );
      runner.enterRawMode();
      runner.exitRawMode();
      runner.exitRawMode();
      expect(runner.isRawMode, isFalse);
    });

    test('runWithRawMode enters and exits raw mode', () {
      final runner = TerminalRunner(
        backends: [FakeRawModeBackend()],
      );
      var ran = false;
      runner.runWithRawMode(() {
        expect(runner.isRawMode, isTrue);
        ran = true;
      });
      expect(ran, isTrue);
      expect(runner.isRawMode, isFalse);
    });
  });
}
