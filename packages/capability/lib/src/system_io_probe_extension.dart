import 'dart:async';

import 'package:parser/terminal_parser.dart' show TerminalParser;
import 'package:terminal/terminal.dart' show SystemIo;

/// Extension on SystemIo for generic terminal capability probing.
///
/// Sends [query] via [io], waits for a parser event of type [T] from
/// [io.inputStream], and returns the result transformed by [onEvent].
/// If [timeout] is reached, [onTimeout] provides a fallback value.
/// An optional [where] predicate can filter matching events.
extension SystemIoProbeExtension on SystemIo {
  /// Generic probe helper for terminal capability queries.
  Future<R> probeTerminal<T, R>({
    required TerminalParser parser,
    required String query,
    required Duration timeout,
    required R Function(T event) onEvent,
    required R Function() onTimeout,
    bool Function(T event)? where,
  }) async {
    write(query);
    await flush();
    try {
      final matchedEvent = await inputStream
          .expand((bytes) => parser.advance(bytes))
          .where((event) => event is T)
          .cast<T>()
          .firstWhere(where ??  (_) => true)
          .timeout(timeout);
      return onEvent(matchedEvent);
    } on TimeoutException {
      return onTimeout();
    }
  }
}
