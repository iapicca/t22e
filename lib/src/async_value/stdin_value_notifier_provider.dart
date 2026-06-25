import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../io/stdin_stream_provider.dart';
import '../notifier/value_notifier.dart';

/// A [ValueNotifier] that synchronously holds the latest bytes from [stdin].
///
/// Watches [stdinStreamProvider] and updates its value on every stream event.
/// The notifier is initialized with an empty list and is disposed when the
/// provider is destroyed.

/// TODO change naming for this! including the folder
final stdinValueNotifierProvider = Provider<Raw<ValueNotifier<List<int>>>>((ref) {
  final stream = ref.watch(stdinStreamProvider);
  final notifier = ValueNotifier<List<int>>([]);
  final subscription = stream.listen((event) => notifier.value = event);
  ref.onDispose(() {
    subscription.cancel();
    notifier.dispose();
  });
  return notifier;
});
