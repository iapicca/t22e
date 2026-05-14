import 'package:freezed_annotation/freezed_annotation.dart';

part 'process_signal.freezed.dart';

@freezed
sealed class ProcessSignal with _$ProcessSignal {
  const factory ProcessSignal.sigint() = Sigint;
  const factory ProcessSignal.sigterm() = Sigterm;
  const factory ProcessSignal.sigtstp() = Sigtstp;
  const factory ProcessSignal.sigcont() = Sigcont;
}
