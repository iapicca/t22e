import 'dart:async';
import 'dart:io' as io;

import 'package:test/test.dart';
import 'package:lifecycle/lifecycle.dart';
import 'package:terminal/terminal.dart';

class FakeSystemIo implements SystemIo {
  final controller = StreamController<List<int>>();
  final output = StringBuffer();
  int _columns = 80;
  int _rows = 24;
  bool _echoMode = true;
  bool _lineMode = true;
  String _operatingSystem = 'macos';

  @override
  Stream<List<int>> get inputStream => controller.stream;

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
}

class FakeRawModeBackend implements RawModeBackend {
  bool enabled = false;

  @override
  void enable() => enabled = true;

  @override
  void disable() => enabled = false;
}

void main() {
  group('SignalHandler', () {
    late StreamController<io.ProcessSignal> sigintController;
    late StreamController<io.ProcessSignal> sigtermController;
    late StreamController<io.ProcessSignal> sigtstpController;
    late StreamController<io.ProcessSignal> sigcontController;
    late TerminalGuard guard;
    late SignalHandler handler;

    setUp(() {
      sigintController = StreamController<io.ProcessSignal>.broadcast();
      sigtermController = StreamController<io.ProcessSignal>.broadcast();
      sigtstpController = StreamController<io.ProcessSignal>.broadcast();
      sigcontController = StreamController<io.ProcessSignal>.broadcast();

      final backend = FakeRawModeBackend();
      final runner = TerminalRunner(backends: [backend]);
      final fakeIo = FakeSystemIo();
      final terminalIo = TerminalIo(io: fakeIo);
      final altScreen = AltScreenManager(terminalIo);
      guard = TerminalGuard(runner, altScreen);

      handler = SignalHandler(
        guard: guard,
        onInterrupt: () {},
        onTerminate: () {},
        sigint: sigintController.stream,
        sigterm: sigtermController.stream,
        sigtstp: sigtstpController.stream,
        sigcont: sigcontController.stream,
      );
    });

    tearDown(() {
      if (!handler.isDisposed) {
        handler.dispose();
      }
      sigintController.close();
      sigtermController.close();
      sigtstpController.close();
      sigcontController.close();
    });

    test('isDisposed is false initially', () {
      expect(handler.isDisposed, isFalse);
    });

    test('install sets up listeners', () {
      handler.install();
      expect(handler.isDisposed, isFalse);
    });

    test('dispose cancels all subscriptions', () {
      handler.install();
      handler.dispose();
      expect(handler.isDisposed, isTrue);
    });

    test('sigint triggers onInterrupt callback', () async {
      var interrupted = false;
      handler = SignalHandler(
        guard: guard,
        onInterrupt: () => interrupted = true,
        onTerminate: () {},
        sigint: sigintController.stream,
        sigterm: sigtermController.stream,
        sigtstp: sigtstpController.stream,
        sigcont: sigcontController.stream,
      );

      handler.install();
      sigintController.add(io.ProcessSignal.sigint);
      await Future.delayed(Duration.zero);

      expect(interrupted, isTrue);
    });

    test('sigterm restores guard', () async {
      final backend = FakeRawModeBackend();
      final runner = TerminalRunner(backends: [backend]);
      final fakeIo = FakeSystemIo();
      final terminalIo = TerminalIo(io: fakeIo);
      final altScreen = AltScreenManager(terminalIo);
      guard = TerminalGuard(runner, altScreen);
      guard.init();

      handler = SignalHandler(
        guard: guard,
        onInterrupt: () {},
        onTerminate: () {},
        sigint: sigintController.stream,
        sigterm: sigtermController.stream,
        sigtstp: sigtstpController.stream,
        sigcont: sigcontController.stream,
      );

      handler.install();
      runner.enterRawMode();
      expect(backend.enabled, isTrue);

      sigtermController.add(io.ProcessSignal.sigterm);
      await Future.delayed(Duration.zero);

      expect(guard.isRestored, isTrue);
      expect(backend.enabled, isFalse);
    });

    test('sigtstp restores guard', () async {
      final backend = FakeRawModeBackend();
      final runner = TerminalRunner(backends: [backend]);
      final fakeIo = FakeSystemIo();
      final terminalIo = TerminalIo(io: fakeIo);
      final altScreen = AltScreenManager(terminalIo);
      guard = TerminalGuard(runner, altScreen);
      guard.init();

      handler = SignalHandler(
        guard: guard,
        onInterrupt: () {},
        onTerminate: () {},
        sigint: sigintController.stream,
        sigterm: sigtermController.stream,
        sigtstp: sigtstpController.stream,
        sigcont: sigcontController.stream,
      );

      handler.install();
      runner.enterRawMode();
      expect(backend.enabled, isTrue);

      sigtstpController.add(io.ProcessSignal.sigtstp);
      await Future.delayed(Duration.zero);

      expect(guard.isRestored, isTrue);
    });
  });
}
