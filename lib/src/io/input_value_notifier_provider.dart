import 'package:meta/meta.dart' show internal;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../notifier/value_notifier.dart' show ValueNotifier;
import 'input_stream_provider.dart' show inputStreamProvider;

part 'input_value_notifier_provider.g.dart';

/// Synchronously holds the latest stdin bytes as a [ValueNotifier].
///
/// Reads [inputStreamProvider] via `ref.read` and pushes every byte chunk into
/// the notifier. The framework reacts only to this provider.
@riverpod
@internal
ValueNotifier<List<int>> inputValueNotifier(Ref ref) {
  final controller = ref.read(inputStreamProvider);
  final notifier = ValueNotifier<List<int>>([]);
  final subscription = controller.stream.listen((bytes) => notifier.value = bytes);
  ref.onDispose(() {
    subscription.cancel();
    notifier.dispose();
  });
  return notifier;
}
