import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:core/core.dart' show ColorProfile;
import 'package:protocol/protocol.dart' show Defaults;

import 'da1_query.dart' show Da1Query;

part 'capabilities.freezed.dart';

/// Supported keyboard protocol types.
/// Keyboard protocol types: basic or Kitty enhanced protocol.
enum KeyboardProtocol { basic, kitty }

/// Complete terminal capability information gathered by the pipeline.
@freezed
abstract class Capabilities with _$Capabilities {
  const Capabilities._();

  const factory Capabilities({
    required Da1Query da1,
    required ColorProfile colorProfile,
    required bool syncSupported,
    required KeyboardProtocol keyboardProtocol,
    required int rows,
    required int cols,
  }) = _Capabilities;

  /// Capabilities with all default values.
  factory Capabilities.defaults() => Capabilities(
        da1: const Da1Query.unsupported(),
        colorProfile: ColorProfile.ansi16,
        syncSupported: false,
        keyboardProtocol: KeyboardProtocol.basic,
        rows: Defaults.defaultTerminalHeight,
        cols: Defaults.defaultTerminalWidth,
      );
}
