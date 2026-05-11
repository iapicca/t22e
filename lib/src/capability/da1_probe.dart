import 'dart:async';
import 'dart:io';

import '../ansi/term.dart' show queryDa1;
import '../well_known.dart' show WellKnown;
import '../parser/events.dart' show PrimaryDeviceAttributesEvent;
import '../parser/parser.dart' show TerminalParser;
import 'result.dart' show QueryResult, Supported, Unavailable, Da1Result;

class Da1Probe {
  Future<QueryResult<Da1Result>> probe({
    Duration timeout = WellKnown.defaultProbeTimeout,
  }) async {
    final parser = TerminalParser();
    final completer = Completer<QueryResult<Da1Result>>();
    final timer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.complete(const Unavailable());
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
              ? event.params[WellKnown.da1TerminalIdDefault]
              : 0;
          completer.complete(
            Supported(Da1Result(id, event.params.skip(1).toList())),
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
