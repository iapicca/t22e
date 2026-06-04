import 'dart:io' as dart_io;

import 'package:riverpod/riverpod.dart';

final sigintStreamProvider = Provider<Stream<dart_io.ProcessSignal>>(
  (ref) => dart_io.ProcessSignal.sigint.watch(),
);

final sigtermStreamProvider = Provider<Stream<dart_io.ProcessSignal>>(
  (ref) => dart_io.ProcessSignal.sigterm.watch(),
);

final sigtstpStreamProvider = Provider<Stream<dart_io.ProcessSignal>>(
  (ref) => dart_io.ProcessSignal.sigtstp.watch(),
);

final sigcontStreamProvider = Provider<Stream<dart_io.ProcessSignal>>(
  (ref) => dart_io.ProcessSignal.sigcont.watch(),
);
