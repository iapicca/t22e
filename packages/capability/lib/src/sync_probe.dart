import 'dart:async';
import 'dart:io';

import 'package:protocol/protocol.dart' show Defaults;
import 'package:ansi/ansi.dart' show querySyncUpdate;
import 'package:parser/terminal_parser.dart'
    show QuerySyncUpdateEvent, TerminalParser;

class SyncProbe {
  Future<bool> probe({Duration timeout = Defaults.defaultProbeTimeout}) async {
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
