import 'dart:ffi';

import 'package:ffi/ffi.dart' show calloc;
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

class MockTermiosBindings implements TermiosBindings {
  final _calls = <String>[];
  final _mallocs = <Pointer<Uint8>>[];
  int _tcGetAttrResult = 0;
  int _tcSetAttrResult = 0;

  List<String> get calls => List.unmodifiable(_calls);
  bool get mallocCalled => _calls.contains('malloc');
  bool get freeCalled => _calls.contains('free');
  bool get tcGetAttrCalled => _calls.contains('tcgetattr');
  bool get tcSetAttrCalled => _calls.contains('tcsetattr');

  void seedTcGetAttrResult(int value) => _tcGetAttrResult = value;
  void seedTcSetAttrResult(int value) => _tcSetAttrResult = value;

  @override
  Pointer<Uint8> malloc(int size) {
    _calls.add('malloc');
    final p = calloc<Uint8>(size);
    _mallocs.add(p);
    return p;
  }

  @override
  void free(Pointer<Uint8> ptr) {
    _calls.add('free');
    calloc.free(ptr);
  }

  @override
  int tcGetAttr(int fd, Pointer<Uint8> buf) {
    _calls.add('tcgetattr');
    return _tcGetAttrResult;
  }

  @override
  int tcSetAttr(int fd, int opt, Pointer<Uint8> buf) {
    _calls.add('tcsetattr');
    return _tcSetAttrResult;
  }
}

void main() {
  group('TerminalRunner', () {
    test('initial state is not raw mode', () {
      final runner = TerminalRunner(backends: [FakeRawModeBackend()]);
      expect(runner.isRawMode, isFalse);
    });

    test('enterRawMode sets raw mode', () {
      final runner = TerminalRunner(backends: [FakeRawModeBackend()]);
      runner.enterRawMode();
      expect(runner.isRawMode, isTrue);
    });

    test('exitRawMode unsets raw mode', () {
      final runner = TerminalRunner(backends: [FakeRawModeBackend()]);
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
      final runner = TerminalRunner(backends: [FakeRawModeBackend()]);
      runner.enterRawMode();
      runner.exitRawMode();
      runner.exitRawMode();
      expect(runner.isRawMode, isFalse);
    });

    test('runWithRawMode enters and exits raw mode', () {
      final runner = TerminalRunner(backends: [FakeRawModeBackend()]);
      var ran = false;
      runner.runWithRawMode(() {
        expect(runner.isRawMode, isTrue);
        ran = true;
      });
      expect(ran, isTrue);
      expect(runner.isRawMode, isFalse);
    });
  });

  group('FfiRawModeBackend', () {
    test('enable calls malloc, tcgetattr, tcsetattr in order', () {
      final bindings = MockTermiosBindings();
      final backend = FfiRawModeBackend(bindings: bindings);

      backend.enable();

      expect(bindings.mallocCalled, isTrue);
      expect(bindings.tcGetAttrCalled, isTrue);
      expect(bindings.tcSetAttrCalled, isTrue);
    });

    test('enable throws when tcgetattr fails', () {
      final bindings = MockTermiosBindings();
      bindings.seedTcGetAttrResult(-1);
      final backend = FfiRawModeBackend(bindings: bindings);

      expect(() => backend.enable(), throwsStateError);
      expect(bindings.freeCalled, isTrue);
    });

    test('enable throws when tcsetattr fails', () {
      final bindings = MockTermiosBindings();
      bindings.seedTcSetAttrResult(-1);
      final backend = FfiRawModeBackend(bindings: bindings);

      expect(() => backend.enable(), throwsStateError);
      expect(bindings.freeCalled, isTrue);
    });

    test('disable is a no-op when not enabled', () {
      final bindings = MockTermiosBindings();
      final backend = FfiRawModeBackend(bindings: bindings);

      backend.disable();

      expect(bindings.calls, isEmpty);
    });

    test('enable writes raw mode flags to termios struct', () {
      final bindings = MockTermiosBindings();
      final backend = FfiRawModeBackend(bindings: bindings);

      backend.enable();

      expect(bindings.calls, [
        'malloc',
        'tcgetattr',
        'tcsetattr',
      ]);
    });

    test('disable calls tcsetattr and free', () {
      final bindings = MockTermiosBindings();
      final backend = FfiRawModeBackend(bindings: bindings);

      backend.enable();
      bindings._calls.clear();
      backend.disable();

      expect(bindings.tcSetAttrCalled, isTrue);
      expect(bindings.freeCalled, isTrue);
    });

    test('disable is idempotent', () {
      final bindings = MockTermiosBindings();
      final backend = FfiRawModeBackend(bindings: bindings);

      backend.enable();
      backend.disable();
      bindings._calls.clear();
      backend.disable();

      expect(bindings.calls, isEmpty);
    });
  });
}
