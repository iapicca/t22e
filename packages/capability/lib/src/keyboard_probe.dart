import 'dart:async';

import 'package:ansi/ansi.dart' show enableKittyKeyboard, disableKittyKeyboard;
import 'package:parser/terminal_parser.dart'
    show KeyboardEnhancementFlagsEvent, TerminalParser;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:terminal/terminal.dart' show TerminalIo;
import 'result.dart' show KeyboardProtocol;

@internal
Future<KeyboardProtocol> probeKeyboard(
  TerminalIo io,
  TerminalParser parser, {
  Duration timeout = Defaults.defaultProbeTimeout,
}) async {
  final completer = Completer<KeyboardProtocol>();
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
