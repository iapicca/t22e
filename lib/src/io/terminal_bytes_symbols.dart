import 'package:meta/meta.dart' show internal;

/// Byte range bounds used by the `terminal_bytes.dart` byte predicates.
///
/// File-scoped: the sole consumer is `terminal_bytes.dart`. Constants here
/// are pure data; no provider or barrel re-export.
@internal
final class TerminalBytesSymbols {
  const TerminalBytesSymbols._();

  /// Exclusive upper bound of the control byte range (`< 0x20`).
  static const int controlMax = 0x20;

  /// Inclusive lower bound of the CSI parameter range (`0x30`–`0x3F`).
  static const int csiParamMin = 0x30;

  /// Inclusive upper bound of the CSI parameter range (`0x30`–`0x3F`).
  static const int csiParamMax = 0x3F;

  /// Inclusive lower bound of the CSI intermediate range (`0x20`–`0x2F`).
  static const int csiIntermediateMin = 0x20;

  /// Inclusive upper bound of the CSI intermediate range (`0x20`–`0x2F`).
  static const int csiIntermediateMax = 0x2F;

  /// Inclusive lower bound of the CSI final range (`0x40`–`0x7E`).
  static const int csiFinalMin = 0x40;

  /// Inclusive upper bound of the CSI final range (`0x40`–`0x7E`).
  static const int csiFinalMax = 0x7E;
}