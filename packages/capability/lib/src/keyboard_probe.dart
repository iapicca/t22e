import 'dart:async';

import 'package:ansi/ansi.dart' show enableKittyKeyboard, disableKittyKeyboard;
import 'package:notifier/notifier.dart' show Disposable;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:parser/terminal_parser.dart'
    show KeyboardEnhancementFlagsEvent, TerminalParser;
import 'package:terminal/terminal.dart' show TerminalIo;
import 'result.dart' show KeyboardProtocol;

/// TODO this should just be a function!
class KeyboardProbe with Disposable {
  final TerminalIo io;

  KeyboardProbe({required this.io});

  Future<KeyboardProtocol> probe({
    Duration timeout = Defaults.defaultProbeTimeout,
  }) async {
    check();
    final parser = TerminalParser();
    final completer = Completer<KeyboardProtocol>();
    /// TODO what the fuck is this?!
    final timer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.complete(KeyboardProtocol.basic);
      }
    });

    late final StreamSubscription<List<int>> sub;
    sub = io.inputStream.listen((bytes) {
      final events = parser.advance(bytes);
      for (final event in events) {
        if (event is KeyboardEnhancementFlagsEvent) {
          timer.cancel();
          sub.cancel();
          completer.complete(KeyboardProtocol.kitty);
        }
      }
    });

    io.write(enableKittyKeyboard(Defaults.kittyDisambiguate));
    await io.flush();

    final result = await completer.future;
    await sub.cancel();
    if (result == KeyboardProtocol.basic) {
      io.write(disableKittyKeyboard());
    }
    return result;
  }

  // ignore: unnecessary_overrides
  @override
  void dispose(String? message) {
    super.dispose(message);
  }
}
