import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'raw_mode.dart';
import 'termios_bindings_provider.dart';
import 'termios_provider.dart';

part 'raw_mode_provider.g.dart';

@riverpod
RawModeInterface rawMode(Ref ref) {
  final bindings = ref.watch(termiosBindingsProvider);
  final termios = ref.watch(termiosProvider);
  final mode = RawMode(bindings: bindings, termios: termios);
  mode.init();
  ref.onDispose(mode.dispose);
  return mode;
}
