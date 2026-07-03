import 'package:meta/meta.dart' show internal;
import 'package:riverpod/riverpod.dart';

import 'size.dart' show Size;

/// Settable terminal-size state; defaults to `Size(80, 24)`.
@internal
final terminalSizeProvider =
    NotifierProvider<TerminalSizeNotifier, Size>(TerminalSizeNotifier.new);

@internal
class TerminalSizeNotifier extends Notifier<Size> {
  @override
  Size build() => const Size(80, 24);

  /// Replaces the current terminal size with [value].
  void set(Size value) => state = value;
}