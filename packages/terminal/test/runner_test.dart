import 'dart:async';
import 'dart:ffi';

import 'package:ffi/ffi.dart' show calloc;
import 'package:test/test.dart';
import 'package:terminal/terminal.dart';

/// Fake [SystemIo] for unit testing.
class FakeSystemIo implements SystemIo {
  final StreamController<List<int>> _input = StreamController<List<int>>();
  final StringBuffer output = StringBuffer();
  int _columns = 80;
  int _rows = 24;
  bool _echoMode = true;
  bool _lineMode = true;
  String _operatingSystem = 'macos';

  @override
  Stream<List<int>> get inputStream => _input.stream;

  @override
  void write(String data) => output.write(data);

  @override
  Future<void> flush() async {}

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

  void addInput(List<int> bytes) => _input.add(bytes);
  Future<void> close() => _input.close();
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

class MockTermiosBindings implements TermiosBindings {
  final _calls = <String>[];
  final _mallocs = <Pointer<Uint8>>[];
  int _getAttrResult = 0;
  int _setAttrResult = 0;

  List<String> get calls => List.unmodifiable(_calls);
  bool get mallocCalled => _calls.contains('malloc');
  bool get freeCalled => _calls.contains('free');
  bool get getAttrCalled => _calls.contains('getAttr');
  bool get setAttrCalled => _calls.contains('setAttr');

  void seedGetAttrResult(int value) => _getAttrResult = value;
  void seedSetAttrResult(int value) => _setAttrResult = value;

  @override
  GetAttr get getAttr => (int fd, Pointer<Uint8> buf) {
    _calls.add('getAttr');
    return _getAttrResult;
  };

  @override
  SetAttr get setAttr => (int fd, int opt, Pointer<Uint8> buf) {
    _calls.add('setAttr');
    return _setAttrResult;
  };

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
    late FakeSystemIo io;

    setUp(() {
      io = FakeSystemIo();
    });

    test('enable calls malloc, getAttr, setAttr in order', () {
      final bindings = MockTermiosBindings();
      final backend = FfiRawModeBackend(bindings: bindings, io: io);

      backend.enable();

      expect(bindings.mallocCalled, isTrue);
      expect(bindings.getAttrCalled, isTrue);
      expect(bindings.setAttrCalled, isTrue);
    });

    test('enable throws when getAttr fails', () {
      final bindings = MockTermiosBindings();
      bindings.seedGetAttrResult(-1);
      final backend = FfiRawModeBackend(bindings: bindings, io: io);

      expect(() => backend.enable(), throwsStateError);
      expect(bindings.freeCalled, isTrue);
    });

    test('enable throws when setAttr fails', () {
      final bindings = MockTermiosBindings();
      bindings.seedSetAttrResult(-1);
      final backend = FfiRawModeBackend(bindings: bindings, io: io);

      expect(() => backend.enable(), throwsStateError);
      expect(bindings.freeCalled, isTrue);
    });

    test('disable is a no-op when not enabled', () {
      final bindings = MockTermiosBindings();
      final backend = FfiRawModeBackend(bindings: bindings, io: io);

      backend.disable();

      expect(bindings.calls, isEmpty);
    });

    test('enable writes raw mode flags to termios struct', () {
      final bindings = MockTermiosBindings();
      final backend = FfiRawModeBackend(bindings: bindings, io: io);

      backend.enable();

      expect(bindings.calls, ['malloc', 'getAttr', 'setAttr']);
    });

    test('disable calls setAttr and free', () {
      final bindings = MockTermiosBindings();
      final backend = FfiRawModeBackend(bindings: bindings, io: io);

      backend.enable();
      bindings._calls.clear();
      backend.disable();

      expect(bindings.setAttrCalled, isTrue);
      expect(bindings.freeCalled, isTrue);
    });

    test('disable is idempotent', () {
      final bindings = MockTermiosBindings();
      final backend = FfiRawModeBackend(bindings: bindings, io: io);

      backend.enable();
      backend.disable();
      bindings._calls.clear();
      backend.disable();

      expect(bindings.calls, isEmpty);
    });

    test('enable throws UnsupportedError on Windows', () {
      io.operatingSystem = 'windows';
      final bindings = MockTermiosBindings();
      final backend = FfiRawModeBackend(bindings: bindings, io: io);

      expect(() => backend.enable(), throwsUnsupportedError);
    });
  });

  group('IoRawModeBackend', () {
    test('enable disables echo and line mode', () {
      final io = FakeSystemIo();
      final backend = IoRawModeBackend(io: io);

      backend.enable();

      expect(io.echoMode, isFalse);
      expect(io.lineMode, isFalse);
    });

    test('disable restores echo and line mode', () {
      final io = FakeSystemIo();
      final backend = IoRawModeBackend(io: io);

      backend.enable();
      backend.disable();

      expect(io.echoMode, isTrue);
      expect(io.lineMode, isTrue);
    });
  });

  group('TerminalIo', () {
    test('delegates inputStream to SystemIo', () {
      final io = FakeSystemIo();
      final terminalIo = TerminalIo(io: io);
      io.addInput([0x1b]);

      expect(terminalIo.inputStream, emits([0x1b]));
    });

    test('delegates write to SystemIo', () {
      final io = FakeSystemIo();
      final terminalIo = TerminalIo(io: io);
      terminalIo.write('hello');

      expect(io.output.toString(), 'hello');
    });

    test('delegates columns to SystemIo', () {
      final io = FakeSystemIo();
      final terminalIo = TerminalIo(io: io);
      io.columns = 120;

      expect(terminalIo.columns, 120);
    });

    test('delegates rows to SystemIo', () {
      final io = FakeSystemIo();
      final terminalIo = TerminalIo(io: io);
      io.rows = 40;

      expect(terminalIo.rows, 40);
    });
  });
}
