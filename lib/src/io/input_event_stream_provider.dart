import 'package:riverpod/riverpod.dart';

import 'ansi_parser.dart' show InputEvent;
import 'ansi_parser_provider.dart' show ansiParserProvider;
import 'stdin_stream_provider.dart' show stdinStreamProvider;

/// Provides the parsed input-event stream from stdin.
///
/// Buffers raw bytes from [stdinStreamProvider] through [ansiParserProvider]
/// and exposes the resulting [InputEvent] stream.
final inputEventStreamProvider = Provider<Stream<InputEvent>>((ref) {
  final parser = ref.watch(ansiParserProvider);
  final bytes = ref.watch(stdinStreamProvider);

  final subscription = bytes.listen(
    parser.add,
    onError: (_) => parser.close(),
    onDone: parser.close,
  );
  ref.onDispose(subscription.cancel);

  return parser.events;
});
