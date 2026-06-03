import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'cmd.dart';
import 'msg.dart';

part 'providers.g.dart';

/// Factory provider that creates an [EveryCmd] managed by Riverpod.
///
/// Riverpod handles disposal automatically via [ref.onDispose].
///
/// Example:
/// ```dart
/// final container = ProviderContainer();
/// final cmd = container.read(everyCmdProvider(const Duration(seconds: 1)));
/// cmd.execute((msg) => print(msg));
/// container.dispose();
/// ```
@riverpod
EveryCmd everyCmd(Ref ref, Duration interval) {
  final cmd = EveryCmd(interval, (now) => const ClearScreenMsg());
  ref.onDispose(cmd.dispose);
  return cmd;
}
