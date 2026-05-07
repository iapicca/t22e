import 'dart:async';
import 'dart:io';

import '../ansi/term.dart' show enableKittyKeyboard, disableKittyKeyboard;
import '../loop/well_known.dart' show WellKnown;
import '../parser/events.dart' show KeyboardEnhancementFlagsEvent;
import '../parser/parser.dart' show TerminalParser;
import 'result.dart' show KeyboardProtocol;

class KeyboardProbe {
  Future<KeyboardProtocol> probe({
    Duration timeout = WellKnown.defaultProbeTimeout,
  }) async {
    final parser = TerminalParser();
    final completer = Completer<KeyboardProtocol>();
    final timer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.complete(KeyboardProtocol.basic);
      }
    });

    late final StreamSubscription<List<int>> sub;
    sub = stdin.listen((bytes) {
      final events = parser.advance(bytes);
      for (final event in events) {
        if (event is KeyboardEnhancementFlagsEvent) {
          timer.cancel();
          sub.cancel();
          completer.complete(KeyboardProtocol.kitty);
        }
      }
    });

    stdout.write(enableKittyKeyboard(1));
    await stdout.flush();

    final result = await completer.future;
    await sub.cancel();
    if (result == KeyboardProtocol.basic) {
      stdout.write(disableKittyKeyboard());
    }
    return result;
  }
}
