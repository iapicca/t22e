import 'dart:async';

import 'package:ansi/ansi.dart' show querySyncUpdate;
import 'package:notifier/notifier.dart' show Disposable;
import 'package:parser/terminal_parser.dart'
    show QuerySyncUpdateEvent, TerminalParser;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:terminal/terminal.dart' show TerminalIo;

@internal
Future<bool> probeSync(
  TerminalIo io,
  TerminalParser parser, {
  Duration timeout = Defaults.defaultProbeTimeout,
}) async {
  final completer = Completer<bool>();
  final timer = Timer(timeout, () {
    if (!completer.isCompleted) completer.complete(false);
  });

  late final StreamSubscription<List<int>> sub;
  sub = io.inputStream.listen((bytes) {
    final events = parser.advance(bytes);
    for (final event in events) {
      if (event is QuerySyncUpdateEvent) {
        timer.cancel();
        sub.cancel();
        completer.complete(event.supported);
      }
    }
  });

  io.write(querySyncUpdate());
  await io.flush();

  final result = await completer.future;
  await sub.cancel();
  return result;
}
