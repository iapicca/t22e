import 'package:freezed_annotation/freezed_annotation.dart';

part 'process_result.freezed.dart';

@freezed
sealed class ProcessResult with _$ProcessResult {
  const ProcessResult._();

  const factory ProcessResult.success({
    required int exitCode,
    @Default('') String stdout,
    @Default('') String stderr,
  }) = ProcessSuccess;

  factory ProcessResult.timeout(Duration duration) = ProcessTimeout;
}

class ProcessTimeout extends ProcessResult {
  final Duration duration;
  const ProcessTimeout(this.duration) : super._();

  TResult when<TResult extends Object?>({
    required TResult Function(int exitCode, String stdout, String stderr) success,
    required TResult Function(Duration duration) timeout,
  }) => timeout(duration);

  TResult map<TResult extends Object?>({
    required TResult Function(ProcessSuccess value) success,
    required TResult Function(ProcessTimeout value) timeout,
  }) => timeout(this);

  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int exitCode, String stdout, String stderr)? success,
    TResult Function(Duration duration)? timeout,
    required TResult orElse(),
  }) => timeout != null ? timeout(duration) : orElse();

  TResult maybeMap<TResult extends Object?>({
    TResult Function(ProcessSuccess value)? success,
    TResult Function(ProcessTimeout value)? timeout,
    required TResult orElse(),
  }) => timeout != null ? timeout(this) : orElse();

  @override
  int get hashCode => duration.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ProcessTimeout && other.duration == duration);

  @override
  String toString() => 'ProcessResult.timeout($duration)';
}
