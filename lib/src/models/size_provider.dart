import 'package:meta/meta.dart' show internal;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'size.dart' show Size;

part 'size_provider.g.dart';

/// Settable terminal-size state; defaults to `Size(80, 24)`.
@riverpod
@internal
class TerminalSize extends _$TerminalSize {
  @override
  Size build() => const Size(80, 24);

  /// Replaces the current terminal size with [value].
  void set(Size value) => state = value;
}