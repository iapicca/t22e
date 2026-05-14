import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:core/core.dart' show ColorProfile;
import 'package:protocol/protocol.dart' show Defaults;

part 'result.freezed.dart';

@Freezed(genericArgumentFactories: true)
sealed class QueryResult<T> with _$QueryResult<T> {
  const factory QueryResult.supported(T value) = Supported<T>;
  const factory QueryResult.unavailable() = Unavailable<T>;
}

/// Parsed DA1 response: terminal ID and attribute list.
@freezed
abstract class Da1Result with _$Da1Result {
  const factory Da1Result(int terminalId, List<int> attributes) = _Da1Result;
}

/// Supported keyboard protocol types.
enum KeyboardProtocol { basic, kitty }

/// Complete terminal capability information gathered by the pipeline.
@freezed
abstract class Capabilities with _$Capabilities {
  const Capabilities._();

  const factory Capabilities({
    @Default(Unavailable<Da1Result>()) QueryResult<Da1Result> da1,
    @Default(ColorProfile.ansi16) ColorProfile colorProfile,
    @Default(false) bool syncSupported,
    @Default(KeyboardProtocol.basic) KeyboardProtocol keyboardProtocol,
    @Default(Defaults.defaultTerminalHeight) int rows,
    @Default(Defaults.defaultTerminalWidth) int cols,
  }) = _Capabilities;
}
