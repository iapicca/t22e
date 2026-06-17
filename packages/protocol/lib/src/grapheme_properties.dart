/// Grapheme break property constants for Unicode segmentation,
/// plus character width sentinel values.
final class GraphemeProperties {
  GraphemeProperties._();

  /// Grapheme break property: ZWJ.
  static const int graphemePropZwj = 1;

  /// Grapheme break property: variation selector.
  static const int graphemePropVariationSelector = 2;

  /// Grapheme break property: regional indicator.
  static const int graphemePropRegionalIndicator = 3;

  /// Grapheme break property: combining mark.
  static const int graphemePropCombiningMark = 4;

  /// Grapheme break property: emoji modifier.
  static const int graphemePropEmojiModifier = 5;

  /// Grapheme break property: tag sequence.
  static const int graphemePropTag = 6;

  /// Grapheme break property: Hangul leading consonant (choseong).
  static const int graphemePropHangulLeading = 7;

  /// Grapheme break property: Hangul vowel (jungseong).
  static const int graphemePropHangulVowel = 8;

  /// Grapheme break property: Hangul trailing consonant (jongseong).
  static const int graphemePropHangulTrailing = 9;

  /// Grapheme break property: extended pictographic.
  static const int graphemePropExtendedPictographic = 10;

  /// Grapheme break property: invisible character.
  static const int graphemePropInvisible = 11;

  /// Width in columns for a wide (CJK) character.
  static const int wideCharWidth = 2;

  /// Width in columns for zero-width characters.
  static const int zeroCharWidth = 0;
}
