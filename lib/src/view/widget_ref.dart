import 'package:riverpod/misc.dart' show ProviderListenable;

/// Read/subscribe handle to Riverpod providers passed to [Consumer] builders.
///
/// Mirrors flutter_riverpod's `WidgetRef` surface minus `watch` (a Flutter
/// reactivity primitive banned in t22e; see `.ai/coding-standards.md`):
/// widgets never touch the container, and rebuild-on-change is wired through
/// [listen] (which calls `markNeedsBuild` on change), not through `watch`.
abstract class WidgetRef {
  /// Creates a widget ref.
  const WidgetRef();

  /// Reads the current value of [provider] as a one-shot, never subscribing.
  T read<T>(ProviderListenable<T> provider);

  /// Subscribes to [provider] and rebuilds this subtree when it changes.
  ///
  /// One subscription per build is tracked; subscriptions are released in
  /// `dispose`. Use [read] to obtain the current value alongside this call:
  /// `ref.listen(p); final v = ref.read(p);`.
  void listen<T>(ProviderListenable<T> provider);
}