import 'dart:async';

import 'package:test/test.dart';
import 'package:terminal/terminal.dart';
import 'package:lifecycle/lifecycle.dart';

class FakeSystemIo implements SystemIo {
  final controller = StreamController<List<int>>();
  final output = StringBuffer();
  void Function()? onFlush;
  int _columns = 80;
  int _rows = 24;
  bool _echoMode = true;
  bool _lineMode = true;
  String _operatingSystem = 'macos';

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
  int get columns => _columns;
  set columns(int value) => _columns = value;

  @override
  int get rows => _rows;
  set rows(int value) => _rows = value;

  @override
  bool get echoMode => _echoMode;
  @override
  set echoMode(bool value) => _echoMode = value;

  @override
  bool get lineMode => _lineMode;
  @override
  set lineMode(bool value) => _lineMode = value;

  @override
  String get operatingSystem => _operatingSystem;
  set operatingSystem(String value) => _operatingSystem = value;
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
      final fakeIo = FakeSystemIo();
      final io = TerminalIo(io: fakeIo);
      final manager = AltScreenManager(io);
      expect(manager.isActive, isFalse);
    });

    test('enter writes alt screen and hide cursor sequences', () {
      final fakeIo = FakeSystemIo();
      final io = TerminalIo(io: fakeIo);
      final manager = AltScreenManager(io);
      manager.enter();
      expect(fakeIo.output.toString(), contains('\x1b['));
      expect(manager.isActive, isTrue);
    });

    test('enter is idempotent', () {
      final fakeIo = FakeSystemIo();
      final io = TerminalIo(io: fakeIo);
      final manager = AltScreenManager(io);
      manager.enter();
      final afterFirst = fakeIo.output.toString();
      manager.enter();
      expect(fakeIo.output.toString(), afterFirst);
    });

    test('exit writes show cursor and exit alt screen sequences', () {
      final fakeIo = FakeSystemIo();
      final io = TerminalIo(io: fakeIo);
      final manager = AltScreenManager(io);
      manager.enter();
      fakeIo.output.clear();
      manager.exit();
      expect(fakeIo.output.toString(), contains('\x1b['));
      expect(manager.isActive, isFalse);
    });

    test('exit is idempotent', () {
      final fakeIo = FakeSystemIo();
      final io = TerminalIo(io: fakeIo);
      final manager = AltScreenManager(io);
      manager.enter();
      manager.exit();
      fakeIo.output.clear();
      manager.exit();
      expect(fakeIo.output.toString(), isEmpty);
    });

    test('enter with captureMouse writes mouse enable sequence', () {
      final fakeIo = FakeSystemIo();
      final io = TerminalIo(io: fakeIo);
      final manager = AltScreenManager(io);
      manager.enter(captureMouse: true);
      expect(fakeIo.output.toString(), contains('\x1b['));
    });
  });

  group('TerminalGuard', () {
    test('arm and restore calls exit', () {
      final backend = FakeRawModeBackend();
      final runner = TerminalRunner(backends: [backend]);
      final fakeIo = FakeSystemIo();
      final io = TerminalIo(io: fakeIo);
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
      final fakeIo = FakeSystemIo();
      final io = TerminalIo(io: fakeIo);
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
      final fakeIo = FakeSystemIo();
      final io = TerminalIo(io: fakeIo);
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
      final fakeIo = FakeSystemIo();
      final io = TerminalIo(io: fakeIo);
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
      final fakeIo = FakeSystemIo();
      final io = TerminalIo(io: fakeIo);
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
