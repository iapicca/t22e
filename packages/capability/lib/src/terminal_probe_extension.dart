import 'dart:async';

import 'package:parser/terminal_parser.dart' show TerminalParser;
import 'package:terminal/terminal.dart' show TerminalInterface;

/// Extension on [TerminalInterface] providing a generic probe helper.
///
/// Sends a query to the terminal and waits for a specific parser event type.
extension TerminalProbeExtension on TerminalInterface {
  /// Writes [query] to the terminal and waits for a parser event of type [T].
  ///
  /// When the event occurs, [onEvent] transforms it into the return value [R].
  /// If [timeout] is reached, [onTimeout] provides a fallback value.
  /// An optional [where] predicate can filter matching events.
  Future<R> probe<T, R>({
    required String query,
    required TerminalParser parser,
    required Duration timeout,
    required R Function(T event) onEvent,
    required R Function() onTimeout,
    bool Function(T event)? where,
  }) async {
    final filter = where ?? (_) => true;
    write(query);
    await flush();
    try {
      final matchedEvent = await inputStream
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
}
