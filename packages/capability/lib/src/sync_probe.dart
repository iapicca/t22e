import 'dart:async';

import 'package:protocol/protocol.dart' show Defaults;
import 'package:ansi/ansi.dart' show querySyncUpdate;
import 'package:parser/terminal_parser.dart'
    show QuerySyncUpdateEvent, TerminalParser;
import 'package:terminal/terminal.dart' show TerminalIo, RealTerminalIo;

class SyncProbe {
  final TerminalIo _io;

  SyncProbe({TerminalIo? io}) : _io = io ?? const RealTerminalIo();

  Future<bool> probe({Duration timeout = Defaults.defaultProbeTimeout}) async {
    final parser = TerminalParser();
    final completer = Completer<bool>();
    final timer = Timer(timeout, () {
      if (!completer.isCompleted) completer.complete(false);
    });

    late final StreamSubscription<List<int>> sub;
    sub = _io.inputStream.listen((bytes) {
      final events = parser.advance(bytes);
      for (final event in events) {
        if (event is QuerySyncUpdateEvent) {
          timer.cancel();
          sub.cancel();
          completer.complete(event.supported);
        }
      }
    });

    _io.write(querySyncUpdate());
    await _io.flush();

    final result = await completer.future;
    await sub.cancel();
    return result;
  }
}
