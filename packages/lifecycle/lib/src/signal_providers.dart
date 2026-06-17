import 'dart:io' as dart_io;

import 'package:riverpod/riverpod.dart';

/// Stream of SIGINT (Ctrl+C) signals.
final sigintStreamProvider = Provider<Stream<dart_io.ProcessSignal>>(
  (ref) => dart_io.ProcessSignal.sigint.watch(),
);

/// Stream of SIGTERM (termination request) signals.
final sigtermStreamProvider = Provider<Stream<dart_io.ProcessSignal>>(
  (ref) => dart_io.ProcessSignal.sigterm.watch(),
);
