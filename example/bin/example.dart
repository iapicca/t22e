import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:lifecycle/lifecycle.dart';
import 'package:parser/terminal_parser.dart';
import 'package:renderer/renderer.dart';
import 'package:terminal/terminal.dart';
import 'package:widgets/widgets.dart';
import 'package:ansi/ansi.dart';

import 'package:example/src/chat_model.dart';
import 'package:example/src/providers.dart';

Future<void> main() async {
  final container = ProviderContainer();

  final terminalIo = container.read(terminalIoProvider);
  final rawMode = container.read(rawModeProvider);
  final guard = container.read(
    terminalGuardProvider(
      onRestore: () {
        rawMode.dispose();
        terminalIo.write(AnsiDefaults.showCursor);
        terminalIo.write(AnsiDefaults.exitAltScreen);
        terminalIo.flush();
      },
    ),
  )..arm();

  rawMode.init();
  terminalIo.write(AnsiDefaults.hideCursor);
  terminalIo.write(AnsiDefaults.enterAltScreen);
  terminalIo.flush();

  await _runApp(container, terminalIo);

  guard.restore();
  container.dispose();
}

Future<void> _runApp(ProviderContainer container, TerminalIo terminalIo) async {
  final parser = container.read(terminalParserProvider);

  final width = terminalIo.columns;
  final height = terminalIo.rows;
  final modelProvider = chatModelStateProvider(width: width, height: height);
  var model = container.read(modelProvider);
  Frame? previousFrame;
  var running = true;

  final blinkCmd = TickCmd(
    const Duration(milliseconds: 500),
    (_) => const CursorBlinkMsg(),
  );
  blinkCmd.execute((msg) {
    if (!running) return;
    final result = model.update(msg);
    model = result.$1;
    container.read(modelProvider.notifier).updateModel(model);
    _render(model, terminalIo, ref: previousFrame);
    previousFrame = _currentFrame(model);
  });

  _render(model, terminalIo, ref: previousFrame);
  previousFrame = _currentFrame(model);

  final subscription = terminalIo.inputStream.listen((bytes) {
    if (!running) return;

    final events = parser.advance(bytes);
    for (final event in events) {
      if (event is WindowResizeEvent) {
        final result = model.update(WindowSizeMsg(event.cols, event.rows));
        model = result.$1;
        container.read(modelProvider.notifier).updateModel(model);
      } else if (event is KeyEvent) {
        if (event.keyCode == KeyCode.char && event.codepoint == 113) {
          running = false;
          return;
        }

        Msg msg;
        if (event.keyCode == KeyCode.enter) {
          model = model.update(KeyMsg(event)).$1;
          msg = KeyMsg(const KeyEvent(keyCode: KeyCode.enter));
        } else {
          msg = KeyMsg(event);
        }

        final result = model.update(msg);
        model = result.$1;
        container.read(modelProvider.notifier).updateModel(model);
        final cmd = result.$2;
        if (cmd != null) {
          cmd.execute((m) {
            if (!running) return;
            final r = model.update(m);
            model = r.$1;
            container.read(modelProvider.notifier).updateModel(model);
            _render(model, terminalIo, ref: previousFrame);
            previousFrame = _currentFrame(model);
          });
        }
      }
    }
    _render(model, terminalIo, ref: previousFrame);
    previousFrame = _currentFrame(model);
  });

  while (running) {
    await Future.delayed(const Duration(milliseconds: 50));
  }

  await subscription.cancel();
  terminalIo.write(AnsiDefaults.showCursor);
  terminalIo.flush();
}

Frame _currentFrame(ChatModel model) {
  return Frame.fromSurface(
    WidgetRenderer.render(
      model.view(),
      model.terminalWidth,
      model.terminalHeight,
    ),
  );
}

void _render(ChatModel model, TerminalIo terminalIo, {required Frame? ref}) {
  final surface = WidgetRenderer.render(
    model.view(),
    model.terminalWidth,
    model.terminalHeight,
  );

  final currentFrame = Frame.fromSurface(surface);

  if (ref != null) {
    final diffResult = diff(ref, currentFrame);
    final renderer = const SyncRenderer();
    final output = renderer.render(diffResult, currentFrame);
    if (output.isNotEmpty) {
      terminalIo.write(output);
    }
  } else {
    final lines = surface.toAnsiLines();
    terminalIo
      ..write(lines.join('\n'))
      ..write(moveTo(model.terminalHeight, 1));
  }

  terminalIo.flush();
}
