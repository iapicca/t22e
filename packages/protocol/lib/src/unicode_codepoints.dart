/// Individual Unicode codepoint constants for control characters,
/// whitespace, bidi formatting, and formatting marks.
final class UnicodeCodepoints {
  UnicodeCodepoints._();

  /// Space character codepoint.
  static const int codepointSpace = 0x20;

  /// DEL (delete) control character.
  static const int codepointDel = 0x7F;

  /// Ideographic space codepoint (CJK fullwidth space).
  static const int codepointIdeographicSpace = 0x3000;

  /// Zero-width joiner (ZWJ) codepoint.
  static const int codepointZwj = 0x200D;

  /// Soft hyphen codepoint.
  static const int codepointSoftHyphen = 0x00AD;

  /// Arabic format character (ALM).
  static const int codepointArabicFormatChar = 0x061C;

  /// Mongolian vowel separator.
  static const int codepointMongolianVowelSeparator = 0x180E;

  /// En quad (start of fixed-width space range).
  static const int codepointEnQuadStart = 0x2000;

  /// Hair space (end of fixed-width space range).
  static const int codepointEnQuadEnd = 0x200A;

  /// Line separator.
  static const int codepointLineSeparator = 0x2028;

  /// Paragraph separator.
  static const int codepointParagraphSeparator = 0x2029;

  /// Start of bidi overrides / embedding marks.
  static const int codepointBidiOverrideStart = 0x202A;

  /// End of bidi overrides / embedding marks.
  static const int codepointBidiOverrideEnd = 0x202E;

  /// Word joiner.
  static const int codepointWordJoinerStart = 0x2060;

  /// End of invisible operators range.
  static const int codepointWordJoinerEnd = 0x2064;

  /// Left-to-right isolate.
  static const int codepointBidiIsolateLri = 0x2066;

  /// Right-to-left isolate.
  static const int codepointBidiIsolateRli = 0x2067;

  /// First strong isolate.
  static const int codepointBidiIsolateFsi = 0x2068;

  /// Pop directional isolate (start of range).
  static const int codepointBidiIsolatePdiStart = 0x2069;

  /// End of bidi isolate control range.
  static const int codepointBidiIsolatePdiEnd = 0x206F;

  /// Byte order mark / zero-width no-break space.
  static const int codepointBomZwnbsp = 0xFEFF;
}
