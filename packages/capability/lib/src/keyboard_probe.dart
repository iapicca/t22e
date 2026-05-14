import 'dart:async';

import 'package:ansi/ansi.dart' show enableKittyKeyboard, disableKittyKeyboard;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:parser/terminal_parser.dart'
    show KeyboardEnhancementFlagsEvent, TerminalParser;
import 'package:terminal/terminal.dart' show TerminalIo, RealTerminalIo;
import 'result.dart' show KeyboardProtocol;

class KeyboardProbe {
  final TerminalIo _io;

  KeyboardProbe({TerminalIo? io}) : _io = io ?? const RealTerminalIo();

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
}
