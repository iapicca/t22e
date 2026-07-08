import 'package:meta/meta.dart' show internal;

/// Codepoint range bounds used by [charWidth].
///
/// Constants are pure data; no provider or barrel re-export.
@internal
final class CharWidthSymbols {
  const CharWidthSymbols._();

  /// Zero-Width Joiner (U+200D).
  static const int zwj = 0x200D;

  /// Combining-mark block lower bound for the coarse classifier.
  static const int combiningMarkMin = 0x0300;

  /// Combining-mark block upper bound for the coarse classifier.
  static const int combiningMarkMax = 0x036F;

  /// Combining diacritical marks block lower bound (subset of above).
  static const int combiningDiacriticalMin = 0x0300;

  /// Combining diacritical marks block upper bound (subset of above).
  static const int combiningDiacriticalMax = 0x036F;

  /// Variation selectors block lower bound (U+FE00-FE0F).
  static const int variationSelectorMin = 0xFE00;

  /// Variation selectors block upper bound (U+FE00-FE0F).
  static const int variationSelectorMax = 0xFE0F;

  /// Variation selectors supplement block lower bound (U+E0100-E01EF).
  static const int variationSelectorSuppMin = 0xE0100;

  /// Variation selectors supplement block upper bound (U+E0100-E01EF).
  static const int variationSelectorSuppMax = 0xE01EF;

  /// Hangul Jamo block lower bound (U+1100-11FF).
  static const int hangulJamoMin = 0x1100;

  /// Hangul Jamo block upper bound (U+1100-11FF).
  static const int hangulJamoMax = 0x11FF;

  /// CJK radicals and Kangxi block lower bound (U+2E80-2EFF).
  static const int cjkRadicalsMin = 0x2E80;

  /// CJK radicals and Kangxi block upper bound (U+2E80-2EFF).
  static const int cjkRadicalsMax = 0x2EFF;

  /// Hiragana block lower bound (U+3040-309F).
  static const int hiraganaMin = 0x3040;

  /// Katakana block upper bound (U+30A0-30FF).
  static const int katakanaMax = 0x30FF;

  /// CJK symbols and punctuation block lower bound (U+3000-303F).
  static const int cjkSymbolsMin = 0x3000;

  /// CJK symbols and punctuation block upper bound (U+3000-303F).
  static const int cjkSymbolsMax = 0x303F;

  /// CJK unified ideographs block lower bound (U+4E00-9FFF).
  static const int cjkUnifiedMin = 0x4E00;

  /// CJK unified ideographs block upper bound (U+4E00-9FFF).
  static const int cjkUnifiedMax = 0x9FFF;

  /// CJK compatibility ideographs block lower bound (U+F900-FAFF).
  static const int cjkCompatIdeographMin = 0xF900;

  /// CJK compatibility ideographs block upper bound (U+F900-FAFF).
  static const int cjkCompatIdeographMax = 0xFAFF;

  /// Hangul syllables block lower bound (U+AC00-D7AF).
  static const int hangulSyllablesMin = 0xAC00;

  /// Hangul syllables block upper bound (U+AC00-D7AF).
  static const int hangulSyllablesMax = 0xD7AF;

  /// Fullwidth forms block lower bound (U+FF00-FFEF).
  static const int fullwidthFormsMin = 0xFF00;

  /// Fullwidth forms block upper bound (U+FF00-FFEF).
  static const int fullwidthFormsMax = 0xFFEF;

  /// BMP high surrogate lower bound (U+D800-DBFF).
  static const int surrogateMin = 0xD800;

  /// BMP high surrogate upper bound (U+D800-DBFF).
  static const int surrogateMax = 0xDBFF;

  /// Miscellaneous symbols block lower bound (U+2600-26FF).
  static const int miscSymbolsMin = 0x2600;

  /// Miscellaneous symbols block upper bound (U+27BF).
  static const int miscSymbolsMax = 0x27BF;

  /// CJK extension supplementary planes block lower bound (U+20000-2FFFF).
  static const int cjkExtensionSuppMin = 0x20000;

  /// CJK extension supplementary planes block upper bound (U+20000-2FFFF).
  static const int cjkExtensionSuppMax = 0x2FFFF;

  /// Emoji supplementary planes block lower bound (U+1F300-1FAFF).
  static const int emojiSuppMin = 0x1F300;

  /// Emoji supplementary planes block upper bound (U+1F300-1FAFF).
  static const int emojiSuppMax = 0x1FAFF;
}