import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'raw_mode.dart';
import 'terminal_io.dart';
import 'system_io.dart';
import 'native_io.dart';

part 'providers.g.dart';

@riverpod
SystemIo systemIo(Ref ref) => const NativeIo();

@riverpod
TerminalIo terminalIo(Ref ref) {
  return TerminalIo(io: ref.watch(systemIoProvider));
}

@riverpod
RawModeInterface rawMode(Ref ref) {
  final mode = RawMode();
  mode.init();
  ref.onDispose(mode.dispose);
  return mode;
}
