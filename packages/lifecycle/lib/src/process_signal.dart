import 'package:freezed_annotation/freezed_annotation.dart';

part 'process_signal.freezed.dart';

/// POSIX signals that can be caught: SIGINT, SIGTERM.
@freezed
sealed class ProcessSignal with _$ProcessSignal {
  const factory ProcessSignal.sigint() = Sigint;
  const factory ProcessSignal.sigterm() = Sigterm;
}
