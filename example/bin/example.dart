import 'dart:async';
import 'package:widgets/widgets.dart';
import 'package:renderer/renderer.dart';
import 'package:parser/terminal_parser.dart';
import 'package:lifecycle/lifecycle.dart';
import 'package:capability/capability.dart';
import 'package:terminal/terminal.dart';
import 'package:ansi/ansi.dart';
import 'package:riverpod/riverpod.dart';
import 'package:example_app/example_app.dart';

void main() async {
  final container = ProviderContainer();
  final io = container.read(systemIoProvider);
  late final TerminalGuard guard;

  try {
    final capabilities = await container.read(capabilitiesProvider.future);
    final parser = container.read(terminalParserProvider);
    guard = container.read(
      terminalGuardProvider(
        onRestore: () {
          io.write(AnsiDefaults.exitAltScreen);
          io.write(AnsiDefaults.showCursor);
        },
      ),
    );
    final signalHandler = container.read(
      signalHandlerProvider(
        onInterrupt: guard.restore,
        onCleanup: guard.restore,
      ),
    );
    signalHandler.install();

    final app = container.read(chatAppProvider);
    final renderer = SyncRenderer(syncSupported: capabilities.syncSupported);

    Frame? previousFrame;
    void render() {
      final widget = app.view();
      final surface = WidgetRenderer.render(
        widget,
        app.model.terminalWidth,
        app.model.terminalHeight,
      );
      final currentFrame = Frame.fromSurface(surface);
      final diff = DiffResult.fromFrames(
        previousFrame ?? Frame([], []),
        currentFrame,
      );
      if (diff.hasChanges) {
        io.write(renderer.render(diff, currentFrame));
      }
      previousFrame = currentFrame;
    }

    io.write(AnsiDefaults.enterAltScreen);
    io.write(AnsiDefaults.hideCursor);
    render();

    final quitCompleter = Completer<void>();
    final subscription = io.inputStream.listen((bytes) {
      if (bytes.contains(0x03)) {
        quitCompleter.complete();
        return;
      }

      final events = parser.advance(bytes);
      for (final event in events) {
        final msg = _eventToMsg(event);
        if (msg != null) {
          app.dispatch(msg);
        }
      }

      render();
    });

    await quitCompleter.future;
    await subscription.cancel();
  } finally {
    guard.restore();
    container.dispose();
  }
}

Msg? _eventToMsg(Event event) {
  return switch (event) {
    KeyEvent() => KeyMsg(event),
    MouseEvent() => MouseMsg(event),
    _ => null,
  };
}
