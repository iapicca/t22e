import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'terminal_io.dart';
import 'system_io.dart';

part 'system_io_provider.g.dart';

@riverpod
SystemIo systemIo(Ref ref) => const TerminalIo();
