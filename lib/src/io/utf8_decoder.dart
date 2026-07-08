import 'package:meta/meta.dart' show internal;

import 'utf8_decoder_symbols.dart' show Utf8DecoderSymbols;

/// Function signature for decoding a UTF-8 byte run to a single character.
///
/// Returns `null` when a fake chooses to signal "unrecognized". Injectable
/// via Riverpod ([utf8DecoderProvider]); the default is `utf8.decode`.
typedef Utf8Decoder = String? Function(List<int> bytes);

/// Bytes in the UTF-8 code point starting with [byte], or 0 if invalid lead.
@internal
int utf8Length(int byte) {
  if (byte < Utf8DecoderSymbols.asciiMax) return 1;
  if ((byte & Utf8DecoderSymbols.twoByteMask) ==
      Utf8DecoderSymbols.twoByteLead) {
    return 2;
  }
  if ((byte & Utf8DecoderSymbols.threeByteMask) ==
      Utf8DecoderSymbols.threeByteLead) {
    return 3;
  }
  if ((byte & Utf8DecoderSymbols.fourByteMask) ==
      Utf8DecoderSymbols.fourByteLead) {
    return 4;
  }
  return 0;
}