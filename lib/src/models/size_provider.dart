import 'package:meta/meta.dart' show internal;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'size.dart' show Size;

part 'size_provider.g.dart';

/// Settable terminal-size state read by widgets and ViewModels.
///
/// Defaults to `Size(80, 24)`. Application code updates it when the terminal
/// is resized; the first phase does not detect resizes itself.
@riverpod
@internal
class TerminalSize extends _$TerminalSize {
  @override
  Size build() => const Size(80, 24);

  /// Replaces the current terminal size with [value].
  void set(Size value) => state = value;
}