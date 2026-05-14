import 'dart:async';
import 'dart:io';

import 'package:ansi/ansi.dart' show queryDa1;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:parser/terminal_parser.dart'
    show PrimaryDeviceAttributesEvent, TerminalParser;
import 'result.dart' show QueryResult, Da1Result;

/// Probes the terminal's primary device attributes (DA1).
class Da1Probe {
  /// Sends a DA1 query and parses the response.
  Future<QueryResult<Da1Result>> probe({
    Duration timeout = Defaults.defaultProbeTimeout,
  }) async {
    final parser = TerminalParser();
    final completer = Completer<QueryResult<Da1Result>>();
    final timer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.complete(const QueryResult.unavailable());
      }
    });

    late final StreamSubscription<List<int>> sub;
    sub = stdin.listen((bytes) {
      final events = parser.advance(bytes);
      for (final event in events) {
        if (event is PrimaryDeviceAttributesEvent) {
          timer.cancel();
          sub.cancel();
          final id = event.params.isNotEmpty
              ? event.params[Defaults.da1TerminalIdDefault]
              : 0;
          completer.complete(
            QueryResult.supported(Da1Result(id, event.params.skip(1).toList())),
          );
        }
      }
    });

    stdout.write(queryDa1());
    await stdout.flush();

    final result = await completer.future;
    await sub.cancel();
    return result;
  }
}
