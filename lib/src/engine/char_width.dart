import 'package:meta/meta.dart' show internal;

import 'char_width_symbols.dart' show CharWidthSymbols;

/// Returns the terminal cell width of a single grapheme cluster.
///
/// Returns `0` for combining marks (no advance), `1` for narrow glyphs
/// (ASCII, Latin, etc.), and `2` for wide glyphs (CJK, fullwidth, common
/// emoji presentation blocks). Width is derived from the leading codepoint
/// of [grapheme]; combining marks attached to a base cluster do not change
/// the result.
@internal
int charWidth(String grapheme) {
  if (grapheme.isEmpty) return 0;
  final code = grapheme.runes.first;

  // Invisible characters: ZWJ and variation selectors.
  if (code == CharWidthSymbols.zwj || _isVariationSelector(code)) return 0;

  // Combining diacritical marks.
  if (code >= CharWidthSymbols.combiningDiacriticalMin &&
      code <= CharWidthSymbols.combiningDiacriticalMax) {
    return 0;
  }

  if (_isWide(code)) return 2;
  return 1;
}

bool _isVariationSelector(int code) =>
    (code >= CharWidthSymbols.variationSelectorMin &&
        code <= CharWidthSymbols.variationSelectorMax) ||
    (code >= CharWidthSymbols.variationSelectorSuppMin &&
        code <= CharWidthSymbols.variationSelectorSuppMax);

bool _isWide(int code) {
  // Hangul Jamo, CJK radicals, Hiragana, Katakana, CJK symbols/punctuation.
  if (code >= CharWidthSymbols.hangulJamoMin &&
      code <= CharWidthSymbols.katakanaMax) {
    return true;
  }
  // CJK symbols/punctuation (U+3000-303F) and CJK unified (U+4E00-9FFF).
  if (code >= CharWidthSymbols.cjkSymbolsMin &&
      code <= CharWidthSymbols.cjkSymbolsMax) {
    return true;
  }
  if (code >= CharWidthSymbols.cjkUnifiedMin &&
      code <= CharWidthSymbols.cjkUnifiedMax) {
    return true;
  }
  // CJK compatibility ideographs (U+F900-FAFF).
  if (code >= CharWidthSymbols.cjkCompatIdeographMin &&
      code <= CharWidthSymbols.cjkCompatIdeographMax) {
    return true;
  }
  // Hangul syllables (U+AC00-D7AF).
  if (code >= CharWidthSymbols.hangulSyllablesMin &&
      code <= CharWidthSymbols.hangulSyllablesMax) {
    return true;
  }
  // Fullwidth forms (U+FF00-FFEF).
  if (code >= CharWidthSymbols.fullwidthFormsMin &&
      code <= CharWidthSymbols.fullwidthFormsMax) {
    return true;
  }
  // Miscellaneous symbols & pictographs (U+2600-27BF).
  if (code >= CharWidthSymbols.miscSymbolsMin &&
      code <= CharWidthSymbols.miscSymbolsMax) {
    return true;
  }
  // Supplementary plane wide blocks: CJK extensions U+20000-2FFFF and
  // emoji U+1F300-1FAFF.
  if (code >= CharWidthSymbols.cjkExtensionSuppMin &&
      code <= CharWidthSymbols.cjkExtensionSuppMax) {
    return true;
  }
  if (code >= CharWidthSymbols.emojiSuppMin &&
      code <= CharWidthSymbols.emojiSuppMax) {
    return true;
  }
  return false;
}