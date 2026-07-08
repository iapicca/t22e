import 'package:meta/meta.dart' show internal;

/// UTF-8 lead-byte constants used by [utf8Length].
///
/// File-scoped: the sole consumer is `utf8_decoder.dart`. Constants here are
/// pure data; no provider or barrel re-export.
@internal
final class Utf8DecoderSymbols {
  const Utf8DecoderSymbols._();

  /// Upper bound of the single-byte ASCII range.
  static const int asciiMax = 0x80;

  /// Mask for a two-byte UTF-8 lead byte.
  static const int twoByteMask = 0xE0;

  /// Lead-byte value of a two-byte UTF-8 sequence.
  static const int twoByteLead = 0xC0;

  /// Mask for a three-byte UTF-8 lead byte.
  static const int threeByteMask = 0xF0;

  /// Lead-byte value of a three-byte UTF-8 sequence.
  static const int threeByteLead = 0xE0;

  /// Mask for a four-byte UTF-8 lead byte.
  static const int fourByteMask = 0xF8;

  /// Lead-byte value of a four-byte UTF-8 sequence.
  static const int fourByteLead = 0xF0;
}