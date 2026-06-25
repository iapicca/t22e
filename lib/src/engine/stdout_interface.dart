import 'dart:async' show unawaited;
import 'dart:io' show IOSink, stdout;

import 'package:meta/meta.dart' show internal;

mixin StdoutInterface {
  void write(String ansi);
}

/// Wraps an [IOSink] and flushes generated ANSI strings.
@internal
class StdoutWriter with StdoutInterface {
  /// Creates a writer that writes to [sink], defaulting to `dart:io` stdout.
  StdoutWriter({IOSink? sink}) : _sink = sink ?? stdout;

  final IOSink _sink;

  /// Writes [ansi] to the sink and flushes it.
  @override
  void write(String ansi) {
    _sink.write(ansi);
    unawaited(_sink.flush());
  }
}
