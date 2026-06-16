/// Unicode codepoint range boundaries for character classification.
final class UnicodeRanges {
  UnicodeRanges._();

  /// Start of variation selector range.
  static const int codepointVariationSelectorStart = 0xFE00;

  /// End of variation selector range.
  static const int codepointVariationSelectorEnd = 0xFE0F;

  /// Start of variation selector supplement.
  static const int codepointVariationSelectorSuppStart = 0xE0100;

  /// End of variation selector supplement.
  static const int codepointVariationSelectorSuppEnd = 0xE01EF;

  /// Start of regional indicator symbol range.
  static const int codepointRegionalIndicatorStart = 0x1F1E6;

  /// End of regional indicator symbol range.
  static const int codepointRegionalIndicatorEnd = 0x1F1FF;

  /// Start of combining diacritical marks.
  static const int codepointCombiningDiacriticalStart = 0x0300;

  /// End of combining diacritical marks.
  static const int codepointCombiningDiacriticalEnd = 0x036F;

  /// Start of combining diacritical marks extended.
  static const int codepointCombiningDiacriticalExtStart = 0x1AB0;

  /// End of combining diacritical marks extended.
  static const int codepointCombiningDiacriticalExtEnd = 0x1AFF;

  /// Start of combining diacritical marks supplement.
  static const int codepointCombiningDiacriticalSuppStart = 0x1DC0;

  /// End of combining diacritical marks supplement.
  static const int codepointCombiningDiacriticalSuppEnd = 0x1DFF;

  /// Start of combining marks for symbols.
  static const int codepointCombiningMarksSymbolsStart = 0x20D0;

  /// End of combining marks for symbols.
  static const int codepointCombiningMarksSymbolsEnd = 0x20FF;

  /// Start of combining half marks.
  static const int codepointCombiningHalfMarksStart = 0xFE20;

  /// End of combining half marks.
  static const int codepointCombiningHalfMarksEnd = 0xFE2F;

  /// Start of emoji skin-tone modifier range.
  static const int codepointEmojiModifierStart = 0x1F3FB;

  /// End of emoji skin-tone modifier range.
  static const int codepointEmojiModifierEnd = 0x1F3FF;

  /// Tag codepoint (used with variation selector supplement).
  static const int codepointTag = 0xE0020;

  /// Start of Hangul Jamo leading consonants.
  static const int codepointHangulLeadingStart = 0x1100;

  /// End of Hangul Jamo leading consonants.
  static const int codepointHangulLeadingEnd = 0x115F;

  /// Start of Hangul Jamo vowels.
  static const int codepointHangulVowelStart = 0x1160;

  /// End of Hangul Jamo vowels.
  static const int codepointHangulVowelEnd = 0x11A2;

  /// Start of Hangul syllables.
  static const int codepointHangulSyllableStart = 0xAC00;

  /// End of Hangul syllables.
  static const int codepointHangulSyllableEnd = 0xD7AF;

  /// Start of Hangul Jamo trailing consonants.
  static const int codepointHangulTrailingStart = 0x11A8;

  /// End of Hangul Jamo trailing consonants.
  static const int codepointHangulTrailingEnd = 0x11F9;

  /// Start of extended pictographic (emoticons) range.
  static const int codepointExtendedPictographicStart = 0x1F900;

  /// End of extended pictographic (emoticons) range.
  static const int codepointExtendedPictographicEnd = 0x1F9FF;
}
