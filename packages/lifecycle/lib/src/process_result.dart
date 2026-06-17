import 'package:freezed_annotation/freezed_annotation.dart';

part 'process_result.freezed.dart';

/// Successful exit code (zero).
const exitCodeOk = 0;

/// Result of a process execution: success with output or timeout.
@freezed
sealed class ProcessResult with _$ProcessResult {
  const ProcessResult._();

  const factory ProcessResult.success({
    required int exitCode,
    @Default('') String stdout,
    @Default('') String stderr,
  }) = ProcessSuccess;

  const factory ProcessResult.timeout(Duration duration) = ProcessTimeout;
}
