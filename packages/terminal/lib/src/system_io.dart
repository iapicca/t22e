import 'dart:async';

import 'package:notifier/notifier.dart' show ValueNotifier;

import 'system_context.dart';

/// Core I/O abstraction with access to terminal context.
///
/// [context] is a [ValueNotifier] that carries dimensions, platform,
/// and environment and is live-updated on SIGWINCH.
mixin SystemIo {
  /// Raw input byte stream (like stdin).
  Stream<List<int>> get inputStream;

  /// Writes [data] to standard output.
  void write(String data);

  /// Flushes the standard output buffer.
  Future<void> flush();

  /// Live-updated terminal context (dimensions, platform, environment).
  ValueNotifier<SystemContext> get context;
}
