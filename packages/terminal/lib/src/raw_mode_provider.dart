import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'raw_mode.dart';

part 'raw_mode_provider.g.dart';

@riverpod
RawModeInterface rawMode(Ref ref) {
  final mode = RawMode();
  mode.init();
  ref.onDispose(mode.dispose);
  return mode;
}
