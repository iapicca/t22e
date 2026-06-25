import 'dart:async' show Stream, StreamController, StreamSubscription;
import 'dart:io' show stdin;

import 'package:meta/meta.dart' show internal;

/// Wraps a byte source as a broadcast stream for terminal input.
///
/// Multiple listeners can subscribe to [bytes]. Call [dispose] when the
/// reader is no longer needed to cancel the underlying subscription.
@internal
class StdinReader {
  /// Creates a reader that forwards bytes from [source], defaulting to stdin.
  StdinReader({Stream<List<int>>? source})
    : _source = source ?? stdin,
      _controller = StreamController<List<int>>.broadcast(sync: true) {
    _subscription = _source.listen(
      (event) => _controller.add(event),
      onError: (error) => _controller.addError(error),
      onDone: () => _controller.close(),
    );
  }

  final Stream<List<int>> _source;
  final StreamController<List<int>> _controller;
  late final StreamSubscription<List<int>> _subscription;

  /// The broadcast stream of byte chunks from the terminal.
  Stream<List<int>> get bytes => _controller.stream;

  /// Cancels the source subscription and closes the broadcast stream.
  void dispose() {
    _subscription.cancel();
    _controller.close();
  }
}
