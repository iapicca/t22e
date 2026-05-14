import 'dart:async';
import 'dart:io';

import 'package:ansi/ansi.dart' show enableKittyKeyboard, disableKittyKeyboard;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:parser/terminal_parser.dart'
    show KeyboardEnhancementFlagsEvent, TerminalParser;
import 'result.dart' show KeyboardProtocol;

/// Probes whether the terminal supports the Kitty keyboard protocol.
class KeyboardProbe {
  /// Enables Kitty keyboard flags and checks for a response.
  Future<KeyboardProtocol> probe({
    Duration timeout = Defaults.defaultProbeTimeout,
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

    stdout.write(enableKittyKeyboard(Defaults.kittyDisambiguate));
    await stdout.flush();

    final result = await completer.future;
    await sub.cancel();
    if (result == KeyboardProtocol.basic) {
      stdout.write(disableKittyKeyboard());
    }
    return result;
  }
}
