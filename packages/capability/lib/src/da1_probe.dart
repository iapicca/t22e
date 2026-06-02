import 'dart:async';

import 'package:ansi/ansi.dart' show queryDa1;
import 'package:notifier/notifier.dart' show Disposable;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:parser/terminal_parser.dart'
    show PrimaryDeviceAttributesEvent, TerminalParser;
import 'package:terminal/terminal.dart' show TerminalIo;
import 'result.dart' show QueryResult, Da1Result;

/// TODO this should just be a function!
class Da1Probe with Disposable {
  final TerminalIo io;

  Da1Probe({required this.io});

  Future<QueryResult<Da1Result>> probe({
    Duration timeout = Defaults.defaultProbeTimeout,
  }) async {
    check();
    final parser = TerminalParser();
    final completer = Completer<QueryResult<Da1Result>>();
    final timer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.complete(const QueryResult.unavailable());
      }
    });

    late final StreamSubscription<List<int>> sub;
    sub = io.inputStream.listen((bytes) {
      final events = parser.advance(bytes);
      for (final event in events) {
        if (event is PrimaryDeviceAttributesEvent) {
          timer.cancel();
          sub.cancel();
          final id = event.params.isNotEmpty
              ? event.params[Defaults.da1TerminalIdDefault]
              : 0;
          completer.complete(
            QueryResult.supported(Da1Result(id, event.params.skip(1).toList())),
          );
        }
      }
    });

    io.write(queryDa1());
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
