import 'dart:async';

import 'package:ansi/ansi.dart' show enableKittyKeyboard, disableKittyKeyboard;
import 'package:notifier/notifier.dart' show Disposable;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:parser/terminal_parser.dart'
    show KeyboardEnhancementFlagsEvent, TerminalParser;
import 'package:terminal/terminal.dart' show TerminalIo;
import 'result.dart' show KeyboardProtocol;

class KeyboardProbe with Disposable {
  final TerminalIo _io;

  KeyboardProbe({this._io = const TerminalIo()});

  Future<KeyboardProtocol> probe({
    Duration timeout = Defaults.defaultProbeTimeout,
  }) async {
    check();
    final parser = TerminalParser();
    final completer = Completer<KeyboardProtocol>();
    final timer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.complete(KeyboardProtocol.basic);
      }
    });

    late final StreamSubscription<List<int>> sub;
    sub = _io.inputStream.listen((bytes) {
      final events = parser.advance(bytes);
      for (final event in events) {
        if (event is KeyboardEnhancementFlagsEvent) {
          timer.cancel();
          sub.cancel();
          completer.complete(KeyboardProtocol.kitty);
        }
      }
    });

    _io.write(enableKittyKeyboard(Defaults.kittyDisambiguate));
    await _io.flush();

    final result = await completer.future;
    await sub.cancel();
    if (result == KeyboardProtocol.basic) {
      _io.write(disableKittyKeyboard());
    }
    return result;
  }

  // ignore: unnecessary_overrides
  @override
  void dispose(String? message) {
    super.dispose(message);
  }
}
