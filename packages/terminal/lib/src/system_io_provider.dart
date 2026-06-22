import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'libc_provider.dart';
import 'terminal_io.dart';
import 'system_io.dart';

part 'system_io_provider.g.dart';


SystemIo systemIo(Ref ref) {
  final libc = ref.watch(libcProvider);
  final io = TerminalIo(libc: libc);
  io.init();
  ref.onDispose(io.dispose);
  return io;
}
