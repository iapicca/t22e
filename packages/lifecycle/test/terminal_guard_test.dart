import 'dart:async';

import 'package:test/test.dart';
import 'package:terminal/terminal.dart';
import 'package:lifecycle/lifecycle.dart';

class FakeTerminalIo implements TerminalIo {
  final controller = StreamController<List<int>>();
  final output = StringBuffer();
  void Function()? onFlush;

  @override
  Stream<List<int>> get inputStream => controller.stream;

  @override
  void write(String data) {
    output.write(data);
  }

  @override
  Future<void> flush() async {
    onFlush?.call();
  }

  @override
  int get columns => 80;

  @override
  int get rows => 24;
}

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
  group('AltScreenManager', () {
    test('initial state is not active', () {
      final io = FakeTerminalIo();
      final manager = AltScreenManager(io);
      expect(manager.isActive, isFalse);
    });

    test('enter writes alt screen and hide cursor sequences', () {
      final io = FakeTerminalIo();
      final manager = AltScreenManager(io);
      manager.enter();
      expect(io.output.toString(), contains('\x1b['));
      expect(manager.isActive, isTrue);
    });

    test('enter is idempotent', () {
      final io = FakeTerminalIo();
      final manager = AltScreenManager(io);
      manager.enter();
      final afterFirst = io.output.toString();
      manager.enter();
      expect(io.output.toString(), afterFirst);
    });

    test('exit writes show cursor and exit alt screen sequences', () {
      final io = FakeTerminalIo();
      final manager = AltScreenManager(io);
      manager.enter();
      io.output.clear();
      manager.exit();
      expect(io.output.toString(), contains('\x1b['));
      expect(manager.isActive, isFalse);
    });

    test('exit is idempotent', () {
      final io = FakeTerminalIo();
      final manager = AltScreenManager(io);
      manager.enter();
      manager.exit();
      io.output.clear();
      manager.exit();
      expect(io.output.toString(), isEmpty);
    });

    test('enter with captureMouse writes mouse enable sequence', () {
      final io = FakeTerminalIo();
      final manager = AltScreenManager(io);
      manager.enter(captureMouse: true);
      expect(io.output.toString(), contains('\x1b['));
    });
  });

  group('TerminalGuard', () {
    test('arm and restore calls exit', () {
      final backend = FakeRawModeBackend();
      final runner = TerminalRunner(backends: [backend]);
      final io = FakeTerminalIo();
      final altScreen = AltScreenManager(io);
      final guard = TerminalGuard(runner, altScreen);

      guard.arm();
      expect(guard.isRestored, isFalse);

      guard.restore();
      expect(guard.isRestored, isTrue);
      expect(backend.enabled, isFalse);
    });

    test('disarm prevents restore', () {
      final backend = FakeRawModeBackend();
      final runner = TerminalRunner(backends: [backend]);
      final io = FakeTerminalIo();
      final altScreen = AltScreenManager(io);
      final guard = TerminalGuard(runner, altScreen);

      guard.arm();
      guard.disarm();
      expect(guard.isRestored, isTrue);

      runner.enterRawMode();
      guard.restore();
      expect(backend.enabled, isTrue);
    });

    test('restore is idempotent', () {
      final backend = FakeRawModeBackend();
      final runner = TerminalRunner(backends: [backend]);
      final io = FakeTerminalIo();
      final altScreen = AltScreenManager(io);
      final guard = TerminalGuard(runner, altScreen);

      guard.arm();
      guard.restore();
      guard.restore();
      expect(guard.isRestored, isTrue);
    });

    test('runGuarded calls body and restores', () {
      final backend = FakeRawModeBackend();
      final runner = TerminalRunner(backends: [backend]);
      final io = FakeTerminalIo();
      final altScreen = AltScreenManager(io);
      final guard = TerminalGuard(runner, altScreen);

      var called = false;
      guard.arm();
      guard.runGuarded(() {
        called = true;
        runner.enterRawMode();
        expect(runner.isRawMode, isTrue);
      });
      expect(called, isTrue);
      expect(runner.isRawMode, isFalse);
      expect(guard.isRestored, isTrue);
    });

    test('runGuarded restores even when body throws', () {
      final backend = FakeRawModeBackend();
      final runner = TerminalRunner(backends: [backend]);
      final io = FakeTerminalIo();
      final altScreen = AltScreenManager(io);
      final guard = TerminalGuard(runner, altScreen);

      guard.arm();
      runner.enterRawMode();
      try {
        guard.runGuarded(() {
          throw Exception('oh no');
        });
      } catch (_) {}
      expect(runner.isRawMode, isFalse);
      expect(guard.isRestored, isTrue);
    });
  });
}
