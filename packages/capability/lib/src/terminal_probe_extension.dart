import 'dart:async';

import 'package:parser/terminal_parser.dart' show TerminalParser;
import 'package:terminal/terminal.dart' show SystemIo;

/// Generic probe helper for terminal capability queries.
///
/// Sends [query] via [io], waits for a parser event of type [T] from
/// [io.inputStream], and returns the result transformed by [onEvent].
/// If [timeout] is reached, [onTimeout] provides a fallback value.
/// An optional [where] predicate can filter matching events.
Future<R> probeTerminal<T, R>({
  required String query,
  required SystemIo io,
  required TerminalParser parser,
  required Duration timeout,
  required R Function(T event) onEvent,
  required R Function() onTimeout,
  bool Function(T event)? where,
}) async {
  final filter = where ?? (_) => true;
  io.write(query);
  await io.flush();
  try {
    final matchedEvent = await io.inputStream
        .expand((bytes) => parser.advance(bytes))
        .where((event) => event is T)
        .cast<T>()
        .firstWhere(filter)
        .timeout(timeout);

    return onEvent(matchedEvent);
  } on TimeoutException {
    return onTimeout();
  }
}
