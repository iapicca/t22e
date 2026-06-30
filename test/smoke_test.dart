import 'dart:async' show Future, StreamController, scheduleMicrotask;

import 'package:riverpod/riverpod.dart'
    show Notifier, NotifierProvider, ProviderContainer;
import 'package:t22e/t22e.dart';
import 'package:test/test.dart';

import 'fake_iosink.dart';

/// ViewModel that turns parsed stdin events into a display string.
///
/// It watches the public [inputEventStreamProvider] and updates its state on
/// every event, so a `Consumer` watching this provider rebuilds on input.
class _Display extends Notifier<String> {
  @override
  String build() {
    final stream = ref.watch(inputEventStreamProvider);
    final subscription = stream.listen((event) {
      switch (event) {
        case CharEvent(:final character):
          state = 'Key:$character';
        case KeyEvent(:final key):
          state = 'Key:${key.name}';
        case UnknownEvent():
          state = 'Key:?';
      }
    });
    ref.onDispose(subscription.cancel);
    return 'Key:none';
  }
}

final _displayProvider = NotifierProvider<_Display, String>(_Display.new);

/// Wires the full framework pipeline from a controlled stdin source to a
/// captured stdout sink.
///
/// Each rendered frame recompiles the widget tree and runs the engine pipeline
/// (layout, paint, diff, flush). Provider-driven rebuilds are coalesced into a
/// single microtask via the [Context.requestFrame] hook, so a stdin event that
/// mutates a watched provider triggers exactly one re-render.
class _SmokeHarness {
  _SmokeHarness(this._appChild, {this.size = const Size(80, 24)});

  final Widget _appChild;
  final Size size;
  final FakeIOSink sink = FakeIOSink();
  final StreamController<List<int>> _stdin =
      StreamController<List<int>>(sync: true);

  late final ProviderContainer container = ProviderContainer(
    overrides: [stdinStreamProvider.overrideWithValue(_stdin.stream)],
  );
  late final Context context = Context(container, requestFrame: _requestFrame);
  late final Pipeline _pipeline = Pipeline(
    ansiWriter: const AnsiWriter(),
    diffEngine: const DiffEngine(),
    stdoutInterface: StdoutWriter(sink: sink),
  );

  Element? _rootElement;
  bool _frameScheduled = false;

  /// All characters flushed to stdout since the last [clear].
  String get output => sink.output;

  /// Renders the initial frame.
  void start() => _renderFrame();

  /// Clears captured stdout so the next read reflects a single frame.
  void clear() => sink.clear();

  /// Feeds raw stdin bytes into the input pipeline.
  void feed(List<int> bytes) => _stdin.add(bytes);

  /// Releases the element tree, provider container, and stdin source.
  void dispose() {
    _rootElement?.dispose();
    container.dispose();
    _stdin.close();
  }

  void _renderFrame() {
    _rootElement?.dispose();
    final root = Root(terminalSize: size, child: _appChild);
    _rootElement = root.compile(context)..mount(null);
    final renderRoot = (_rootElement as RenderObjectElement).renderObject;
    _pipeline.render(renderRoot, size);
  }

  void _requestFrame() {
    if (_frameScheduled) return;
    _frameScheduled = true;
    scheduleMicrotask(() {
      _frameScheduled = false;
      _renderFrame();
    });
  }
}

/// Pumps the event queue long enough for a microtask-scheduled re-render.
Future<void> _pump() => Future<void>.delayed(Duration.zero);

void main() {
  group('smoke test: full-screen text updating on stdin', () {
    late _SmokeHarness harness;

    setUp(() {
      harness = _SmokeHarness(
        Consumer(builder: (context, ref) => Text(ref.watch(_displayProvider))),
      );
      addTearDown(harness.dispose);
    });

    // Scenario A — initial render of the full-screen text widget.
    test('initial render paints the full-screen text to stdout', () {
      harness.start();

      expect(harness.output, 'Key:none');
    });

    // Scenario B — a simulated stdin event updates the model and the output.
    test('a stdin key event updates the displayed text with a minimal diff',
        () async {
      harness.start();
      harness.clear();

      harness.feed([0x1B, 0x5B, 0x41]); // ESC [ A — Up arrow
      await _pump();

      // Only the changed tail is rewritten; the unchanged "Key:" prefix and
      // every other cell are skipped by the diff engine.
      expect(harness.output, '\x1B[1;5Hup  ');
      expect(harness.output.length, lessThan(harness.size.area));
    });

    test('a printable stdin char event updates the displayed text', () async {
      harness.start();
      harness.clear();

      harness.feed([0x61]); // 'a'
      await _pump();

      expect(harness.output, '\x1B[1;5Ha   ');
    });

    // Determinism — output is independent of the terminal dimensions.
    test('initial render is identical at a smaller terminal size', () {
      final small = _SmokeHarness(
        Consumer(builder: (context, ref) => Text(ref.watch(_displayProvider))),
        size: const Size(20, 10),
      );
      addTearDown(small.dispose);

      small.start();

      expect(small.output, 'Key:none');
    });
  });
}
