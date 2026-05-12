import 'dart:async';
import 'dart:io';

import '../well_known.dart' show WellKnown;
import '../ansi/term.dart' show querySyncUpdate;
import '../parser/events.dart' show QuerySyncUpdateEvent;
import '../parser/parser.dart' show TerminalParser;

/// Probes whether the terminal supports synchronized update (DEC mode 2026)
class SyncProbe {
  /// Queries synchronous update support, returning true/false with timeout
  Future<bool> probe({
    Duration timeout = WellKnown.defaultProbeTimeout,
  }) async {
    final parser = TerminalParser();
    final completer = Completer<bool>();
    final timer = Timer(timeout, () {
      if (!completer.isCompleted) completer.complete(false);
    });

    late final StreamSubscription<List<int>> sub;
    sub = stdin.listen((bytes) {
      final events = parser.advance(bytes);
      for (final event in events) {
        if (event is QuerySyncUpdateEvent) {
          timer.cancel();
          sub.cancel();
          completer.complete(event.supported);
        }
      }
    });

    stdout.write(querySyncUpdate());
    await stdout.flush();

    final result = await completer.future;
    await sub.cancel();
    return result;
  }
}
