import 'dart:async';
import 'dart:collection';
import 'dart:io';

import '../core/surface.dart' show Surface;
import '../lifecycle/alt_screen_manager.dart' show AltScreenManager;
import '../lifecycle/signal_handler.dart' show SignalHandler;
import '../lifecycle/terminal_guard.dart' show TerminalGuard;
import '../parser/events.dart' show Event, KeyCode, KeyEvent, MouseEvent, WindowResizeEvent;
import '../parser/parser.dart' show TerminalParser;
import '../renderer/frame.dart' show Frame, DiffResult, diff;
import '../renderer/cell_renderer.dart' show CellRenderer;
import '../renderer/sync_renderer.dart' show SyncRenderer;
import '../terminal/runner.dart' show TerminalRunner;
import '../ansi/term.dart' show enableKittyKeyboard, disableKittyKeyboard, enableMouse, disableMouse;
import '../widgets/widget.dart' show Widget;
import '../widgets/renderer.dart' show WidgetRenderer;
import 'cmd.dart' show Cmd;
import 'model.dart' show Model;
import 'msg.dart';
import '../well_known.dart' show WellKnown;

/// Throttles frame rendering to a target FPS to avoid excessive output
class FpsThrottle {
  final Duration _frameDuration;
  DateTime _lastRender = DateTime.now();

  FpsThrottle({int fps = WellKnown.defaultFps})
      : _frameDuration = Duration(microseconds: (WellKnown.microsecondsPerSecond / fps).round());

  /// Whether enough time has elapsed since the last render to allow a new one
  bool get shouldRender {
    final now = DateTime.now();
    if (now.difference(_lastRender) >= _frameDuration) {
      _lastRender = now;
      return true;
    }
    return false;
  }

  /// Resets the last render time to now
  void reset() {
    _lastRender = DateTime.now();
  }
}

/// The Elm Architecture runtime: event loop, rendering, and signal handling
class Program<M extends Model<M>> {
  /// Current application model state
  M _model;
  /// Queue of pending messages to process
  final Queue<Msg> _msgQueue = Queue<Msg>();
  /// FPS throttle to limit render frequency
  final FpsThrottle _fpsThrottle;
  /// Raw mode entry/exit manager
  final TerminalRunner _runner = TerminalRunner();
  /// Ensures terminal state is restored on exit
  late final TerminalGuard _guard;
  /// Alternate screen buffer manager
  late final AltScreenManager _altScreen;
  /// Installs POSIX signal handlers
  late final SignalHandler _signalHandler;
  /// Terminal byte parser
  final TerminalParser _parser = TerminalParser();
  /// Line-based renderer (with optional sync update wrapping)
  final SyncRenderer _lineRenderer;
  /// Cell-based renderer for per-cell diffing
  final CellRenderer _cellRenderer;
  /// Whether to use per-cell diffing instead of line-based
  final bool _useCellRenderer;
  /// Whether the Kitty keyboard protocol is enabled
  final bool _useKittyKeyboard;
  /// Whether mouse tracking is enabled
  final bool _useMouse;
  /// Subscription to stdin byte stream
  StreamSubscription<List<int>>? _stdinSub;
  /// Whether the event loop is still running
  bool _running = true;
  /// Whether a re-render is needed
  bool _needsRender = true;
  /// The previous frame for diffing
  Frame? _previousFrame;
  /// Whether we're inside an escape sequence (for ESC disambiguation)
  bool _inEscapeSequence = false;
  /// Timer for ESC-alone disambiguation
  Timer? _escTimer;
  /// Current terminal width in columns
  int _termWidth = WellKnown.defaultTerminalWidth;
  /// Current terminal height in rows
  int _termHeight = WellKnown.defaultTerminalHeight;

  Program(this._model, {
    int fps = WellKnown.defaultFps,
    bool syncSupported = false,
    bool useCellRenderer = false,
    bool useKittyKeyboard = false,
    bool useMouse = false,
  })  : _fpsThrottle = FpsThrottle(fps: fps),
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

  /// Queues a message for processing in the event loop
  void enqueue(Msg msg) {
    _msgQueue.add(msg);
  }

  /// Starts the program: enters raw mode, alt screen, installs signals, begins event loop
  void run() {
    _runner.enterRawMode();
    _altScreen.enter();
    if (_useMouse) {
      stdout.write(enableMouse());
    }
    if (_useKittyKeyboard) {
      stdout.write(enableKittyKeyboard(WellKnown.kittyAllEvents));
    }
    stdout.flush();
    _guard.arm();
    _signalHandler.install();

    _stdinSub = stdin.listen(_onStdinData);

    _eventLoop();
  }

  void _onStdinData(List<int> bytes) {
    for (final byte in bytes) {
      if (byte == WellKnown.escapeByte) {
        _inEscapeSequence = true;
        _escTimer?.cancel();
        _escTimer = Timer(WellKnown.escDisambiguationDelay, () {
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

  /// Main event loop: processes messages and renders frames until quit
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
        sleep(WellKnown.eventLoopSleep);
      }
    }
    _shutdown();
  }

  /// Processes a single message, dispatching to the model or handling it directly
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

  /// Dispatches a message to the model's update function and fires any resulting command
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

  /// Renders the current model view to the terminal via diff-based output
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

  /// Shuts down: cancels subscriptions, disables features, restores terminal
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
