import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'termios_bindings.dart';
import 'libc_provider.dart';

part 'termios_bindings_provider.g.dart';

@riverpod
TermiosBindings termiosBindings(Ref ref) {
  final libc = ref.watch(libcProvider);
  return TermiosBindings(libc);
}
