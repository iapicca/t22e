import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:core/core.dart' show Surface;
import 'package:lifecycle/lifecycle.dart' show AltScreenManager;
import 'package:lifecycle/lifecycle.dart' show SignalHandler;
import 'package:lifecycle/lifecycle.dart' show TerminalGuard;
import 'package:parser/terminal_parser.dart'
    show Event, KeyCode, KeyEvent, MouseEvent, WindowResizeEvent;
import 'package:parser/terminal_parser.dart' show TerminalParser;
import 'package:renderer/renderer.dart' show Frame, DiffResult, diff;
import 'package:renderer/renderer.dart' show CellRenderer;
import 'package:renderer/renderer.dart' show SyncRenderer;
import 'package:terminal/terminal.dart' show TerminalRunner;
import 'package:ansi/ansi.dart'
    show enableKittyKeyboard, disableKittyKeyboard, enableMouse, disableMouse;
import 'package:widgets/widgets.dart' show Widget;
import 'package:widgets/widgets.dart' show WidgetRenderer;
import 'package:widgets/widgets.dart' show Cmd;
import 'package:widgets/widgets.dart' show Model;
import 'package:widgets/widgets.dart'
    show
        Msg,
        QuitMsg,
        InterruptMsg,
        KeyMsg,
        MouseMsg,
        WindowSizeMsg,
        ClearScreenMsg;
import 'package:protocol/protocol.dart' show Defaults;

class FpsThrottle {
  final Duration _frameDuration;
  DateTime _lastRender = DateTime.now();

  FpsThrottle({int fps = Defaults.defaultFps})
    : _frameDuration = Duration(
        microseconds: (Defaults.microsecondsPerSecond / fps).round(),
      );

  bool get shouldRender {
    final now = DateTime.now();
    if (now.difference(_lastRender) >= _frameDuration) {
      _lastRender = now;
      return true;
    }
    return false;
  }

  void reset() {
    _lastRender = DateTime.now();
  }
}

class Program<M extends Model<M>> {
  M _model;
  final Queue<Msg> _msgQueue = Queue<Msg>();
  final FpsThrottle _fpsThrottle;
  final TerminalRunner _runner = TerminalRunner();
  late final TerminalGuard _guard;
  late final AltScreenManager _altScreen;
  late final SignalHandler _signalHandler;
  final TerminalParser _parser = TerminalParser();
  final SyncRenderer _lineRenderer;
  final CellRenderer _cellRenderer;
  final bool _useCellRenderer;
  final bool _useKittyKeyboard;
  final bool _useMouse;
  StreamSubscription<List<int>>? _stdinSub;
  bool _running = true;
  bool _needsRender = true;
  Frame? _previousFrame;
  bool _inEscapeSequence = false;
  Timer? _escTimer;
  int _termWidth = Defaults.defaultTerminalWidth;
  int _termHeight = Defaults.defaultTerminalHeight;

  Program(
    this._model, {
    int fps = Defaults.defaultFps,
    bool syncSupported = false,
    bool useCellRenderer = false,
    bool useKittyKeyboard = false,
    bool useMouse = false,
  }) : _fpsThrottle = FpsThrottle(fps: fps),
       _lineRenderer = SyncRenderer(syncSupported: syncSupported),
       _cellRenderer = const CellRenderer(),
       _useCellRenderer = useCellRenderer,
       _useKittyKeyboard = useKittyKeyboard,
       _useMouse = useMouse {
    _altScreen = AltScreenManager(stdout);
    _guard = TerminalGuard(_runner, _altScreen);
    _signalHandler = SignalHandler(
      guard: _guard,
      onInterrupt: () => enqueue(const InterruptMsg()),
    );
  }

  void enqueue(Msg msg) {
    _msgQueue.add(msg);
  }

  void run() {
    _runner.enterRawMode();
    _altScreen.enter();
    if (_useMouse) {
      stdout.write(enableMouse());
    }
    if (_useKittyKeyboard) {
      stdout.write(enableKittyKeyboard(Defaults.kittyAllEvents));
    }
    stdout.flush();
    _guard.arm();
    _signalHandler.install();

    _stdinSub = stdin.listen(_onStdinData);

    _eventLoop();
  }

  void _onStdinData(List<int> bytes) {
    for (final byte in bytes) {
      if (byte == Defaults.escapeByte) {
        _inEscapeSequence = true;
        _escTimer?.cancel();
        _escTimer = Timer(Defaults.escDisambiguationDelay, () {
          if (_inEscapeSequence) {
            enqueue(KeyMsg(const KeyEvent(keyCode: KeyCode.escape)));
            _inEscapeSequence = false;
          }
        });
      } else if (_inEscapeSequence) {
        _inEscapeSequence = false;
        _escTimer?.cancel();
      }
    }

    final events = _parser.advance(bytes);
    for (final event in events) {
      final msg = _eventToMsg(event);
      if (msg != null) enqueue(msg);
    }
  }

  Msg? _eventToMsg(Event event) {
    return switch (event) {
      KeyEvent e => KeyMsg(e),
      MouseEvent e => MouseMsg(e),
      WindowResizeEvent e => WindowSizeMsg(e.cols, e.rows),
      _ => null,
    };
  }

  void _eventLoop() {
    while (_running) {
      while (_msgQueue.isNotEmpty && _running) {
        final msg = _msgQueue.removeFirst();
        _processMessage(msg);
        _fpsThrottle.reset();
      }

      if (_needsRender && _running && _fpsThrottle.shouldRender) {
        _renderFrame();
        _needsRender = false;
      }

      if (_running && _msgQueue.isEmpty) {
        sleep(Defaults.eventLoopSleep);
      }
    }
    _shutdown();
  }

  void _processMessage(Msg msg) {
    switch (msg) {
      case QuitMsg():
        _running = false;
      case WindowSizeMsg(:final width, :final height):
        _termWidth = width;
        _termHeight = height;
        _dispatchToModel(msg);
        _needsRender = true;
      case ClearScreenMsg():
        _needsRender = true;
      case _:
        _dispatchToModel(msg);
    }
  }

  void _dispatchToModel(Msg msg) {
    final result = _model.update(msg);
    _model = result.$1;
    final cmd = result.$2;
    if (cmd != null) _fire(cmd);
    _needsRender = true;
  }

  void _fire(Cmd cmd) {
    unawaited(_executeCmd(cmd));
  }

  Future<void> _executeCmd(Cmd cmd) async {
    try {
      final msg = await cmd.execute(enqueue);
      if (msg != null) enqueue(msg);
    } catch (_) {}
  }

  void _renderFrame() {
    final view = _model.view();
    late final Surface surface;

    if (view is Widget) {
      surface = WidgetRenderer.render(view, _termWidth, _termHeight);
    } else if (view is Surface) {
      surface = view;
    } else {
      return;
    }

    if (_useCellRenderer) {
      final currentFrame = Frame.fromSurface(surface, includeCells: true);
      if (_previousFrame != null) {
        final output = _cellRenderer.render(_previousFrame!, currentFrame);
        if (output.isNotEmpty) {
          stdout.write(output);
          stdout.flush();
        }
      } else {
        final frame = Frame.fromSurface(surface);
        final output = _lineRenderer.render(
          DiffResult(List.generate(frame.height, (i) => i)),
          frame,
        );
        if (output.isNotEmpty) {
          stdout.write(output);
          stdout.flush();
        }
      }
      _previousFrame = currentFrame;
    } else {
      final currentFrame = Frame.fromSurface(surface);
      final diffResult = _previousFrame != null
          ? diff(_previousFrame!, currentFrame)
          : DiffResult(List.generate(currentFrame.height, (i) => i));

      if (diffResult.hasChanges) {
        final output = _lineRenderer.render(diffResult, currentFrame);
        if (output.isNotEmpty) {
          stdout.write(output);
          stdout.flush();
        }
      }

      _previousFrame = currentFrame;
    }
  }

  void _shutdown() {
    _stdinSub?.cancel();
    _escTimer?.cancel();
    if (_useKittyKeyboard) {
      stdout.write(disableKittyKeyboard());
    }
    if (_useMouse) {
      stdout.write(disableMouse());
    }
    stdout.flush();
    _signalHandler.dispose();
    _guard.restore();
  }
}
