import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:terminal/terminal.dart';
import 'package:notifier/notifier.dart';
import 'package:test/test.dart';
import 'package:widgets/widgets.dart';
import 'package:example_app/example_app.dart';

final class _FakeSystemIo with SystemIo {
  final ValueNotifier<SystemContext> _context;

  _FakeSystemIo(int width, int height)
    : _context = ValueNotifier<SystemContext>(
        SystemContext(
          width: width,
          height: height,
          hasTerminal: true,
          operatingSystem: OperatingSystem.macOS,
        ),
      );

  @override
  Stream<List<int>> get inputStream => const Stream.empty();

  @override
  void write(String data) {}

  @override
  Future<void> flush() async {}

  @override
  ValueNotifier<SystemContext> get context => _context;
}

void main() {
  group('chatAppProvider', () {
    test('creates a ChatApp with terminal dimensions', () {
      final fakeIo = _FakeSystemIo(100, 50);
      final container = ProviderContainer(
        overrides: [systemIoProvider.overrideWithValue(fakeIo)],
      );
      addTearDown(container.dispose);

      final app = container.read(chatAppProvider);
      expect(app, isA<ChatApp>());
      expect(app.model.terminalWidth, 100);
      expect(app.model.terminalHeight, 50);
    });

    test('ChatApp from provider can dispatch messages', () {
      final fakeIo = _FakeSystemIo(80, 24);
      final container = ProviderContainer(
        overrides: [systemIoProvider.overrideWithValue(fakeIo)],
      );
      addTearDown(container.dispose);

      final app = container.read(chatAppProvider);
      expect(app.view(), isA<Widget>());
    });
  });
}
