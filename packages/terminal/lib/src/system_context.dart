import 'package:freezed_annotation/freezed_annotation.dart';

import 'operating_system.dart';

part 'system_context.freezed.dart';

/// Environment and dimensions of the terminal at initialization time,
/// exposed through [ValueNotifier] for live resize detection.
@freezed
abstract class SystemContext with _$SystemContext {
  const factory SystemContext({
    required int width,
    required int height,
    required bool hasTerminal,
    required OperatingSystem operatingSystem,
    @Default({}) Map<String, String> environment,
  }) = _SystemContext;
}
