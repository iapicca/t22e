import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:core/core.dart';
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

  final io = container.read(systemIoProvider);
  final rawMode = container.read(rawModeProvider);

  final exitCompleter = Completer<void>();

  final guard = container.read(
    terminalGuardProvider(
      onRestore: () {
        rawMode.dispose();
        io.write(AnsiDefaults.showCursor);
        io.write(AnsiDefaults.exitAltScreen);
        io.flush();
      },
    ),
  )..arm();

  final signalHandler = container.read(
    signalHandlerProvider(
      onInterrupt: () {
        if (!exitCompleter.isCompleted) exitCompleter.complete();
        guard.restore();
      },
      onCleanup: () {
        if (!exitCompleter.isCompleted) exitCompleter.complete();
        guard.restore();
      },
    ),
  );
  signalHandler.install();

  rawMode.init();
  io.write(AnsiDefaults.hideCursor);
  io.write(AnsiDefaults.enterAltScreen);
  io.flush();

  await _runApp(container, io, exitCompleter.future);

  guard.restore();
  container.dispose();
}

Future<void> _runApp(
  ProviderContainer container,
  SystemIo io,
  Future<void> exitSignal,
) async {
  final parser = container.read(terminalParserProvider);

  final width = io.context.value.width;
  final height = io.context.value.height;
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
    _render(model, io, ref: previousFrame);
    previousFrame = _currentFrame(model);
  });

  _render(model, io, ref: previousFrame);
  previousFrame = _currentFrame(model);

  var lastWidth = width;
  var lastHeight = height;
  io.context.addListener(() {
    final ctx = io.context.value;
    if (ctx.width != lastWidth || ctx.height != lastHeight) {
      lastWidth = ctx.width;
      lastHeight = ctx.height;
      if (!running) return;
      final result = model.update(WindowSizeMsg(ctx.width, ctx.height));
      model = result.$1;
      container.read(modelProvider.notifier).updateModel(model);
      _render(model, io, ref: previousFrame);
      previousFrame = _currentFrame(model);
    }
  });

  final subscription = io.inputStream.listen((bytes) {
    if (!running) return;

    final events = parser.advance(bytes);
    for (final event in events) {
      if (event is KeyEvent) {
        if (event.keyCode == KeyCode.char &&
            (event.codepoint == 113 || event.codepoint == 3)) {
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
            _render(model, io, ref: previousFrame);
            previousFrame = _currentFrame(model);
          });
        }
      }
    }
    _render(model, io, ref: previousFrame);
    previousFrame = _currentFrame(model);
  });

  await exitSignal;
  await subscription.cancel();
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

void _render(ChatModel model, SystemIo io, {required Frame? ref}) {
  final surface = WidgetRenderer.render(
    model.view(),
    model.terminalWidth,
    model.terminalHeight,
  );

  final currentFrame = Frame.fromSurface(surface);

  if (ref != null) {
    final diffResult = DiffResult.fromFrames(ref, currentFrame);
    final renderer = const SyncRenderer();
    final output = renderer.render(diffResult, currentFrame);
    if (output.isNotEmpty) {
      io.write(output);
    }
  } else {
    final lines = surface.toAnsiLines();
    io
      ..write(lines.join('\n'))
      ..write(moveTo(model.terminalHeight, 1));
  }

  io.flush();
}
