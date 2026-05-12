import 'dart:async';
import 'dart:io';

import '../ansi/term.dart' show enableKittyKeyboard, disableKittyKeyboard;
import '../well_known.dart' show WellKnown;
import '../parser/events.dart' show KeyboardEnhancementFlagsEvent;
import '../parser/parser.dart' show TerminalParser;
import 'result.dart' show KeyboardProtocol;

/// Probes whether the terminal supports the Kitty keyboard protocol
class KeyboardProbe {
  /// Enables Kitty protocol, waits for confirmation, or falls back to basic
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

    stdout.write(enableKittyKeyboard(WellKnown.kittyDisambiguate));
    await stdout.flush();

    final result = await completer.future;
    await sub.cancel();
    if (result == KeyboardProtocol.basic) {
      stdout.write(disableKittyKeyboard());
    }
    return result;
  }
}
