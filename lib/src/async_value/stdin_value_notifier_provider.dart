import 'package:meta/meta.dart' show internal;
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../io/stdin_stream_provider.dart';
import '../notifier/value_notifier.dart';

/// Synchronously holds the latest stdin bytes; updates on every stream event.
///
/// Watches [stdinStreamProvider] and is disposed with the provider.
// TODO change naming for this! including the folder
@internal
final stdinValueNotifierProvider = Provider<Raw<ValueNotifier<List<int>>>>((
  ref,
) {
  final stream = ref.watch(stdinStreamProvider);
  final notifier = ValueNotifier<List<int>>([]);
  final subscription = stream.listen((event) => notifier.value = event);
  ref.onDispose(() {
    subscription.cancel();
    notifier.dispose();
  });
  return notifier;
});
