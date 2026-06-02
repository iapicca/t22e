import 'dart:async';

import 'package:protocol/protocol.dart' show Defaults;
import 'package:ansi/ansi.dart' show querySyncUpdate;
import 'package:notifier/notifier.dart' show Disposable;
import 'package:parser/terminal_parser.dart'
    show QuerySyncUpdateEvent, TerminalParser;
import 'package:terminal/terminal.dart' show TerminalIo;

class SyncProbe with Disposable {
  final TerminalIo io;

  SyncProbe({required this.io});

  Future<bool> probe({Duration timeout = Defaults.defaultProbeTimeout}) async {
    check();
    final parser = TerminalParser();
    final completer = Completer<bool>();
        /// TODO what the fuck is this?!
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

  // ignore: unnecessary_overrides
  @override
  void dispose(String? message) {
    super.dispose(message);
  }
}
