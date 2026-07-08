import 'dart:async' show unawaited;
import 'dart:io' show IOSink, stdout;

import 'package:meta/meta.dart' show internal;

/// Sink contract for flushing ANSI strings to a terminal output.
@internal
mixin StdoutInterface {
  /// Writes [ansi] to the underlying sink and flushes it.
  void write(String ansi);
}

// TODO: Re-evaluate folder structure for this class.
// Options: (a) move implementation to `lib/src/io/stdout_writer.dart` while
// keeping the interface here; (b) keep both interface and implementation in
// `lib/src/engine/stdout_interface.dart`; (c) rename this file to clarify it
// contains both the interface and the default writer implementation.

/// Wraps an [IOSink] and flushes generated ANSI strings to a terminal.
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
