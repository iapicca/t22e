import 'dart:typed_data';

extension type const UnicodeWidthProperty._(
  (int start, int end, int width) property
) {
  int get start => property.$1;
  int get end => property.$2;
  int get width => property.$3;

  const UnicodeWidthProperty(int start, int end, int width) 
    : this._((start, end, width));
}

final class UnicodeTable {
  const UnicodeTable._();

  static const int maxCodepoint = 0x10FFFF;
  static const int tableLength = maxCodepoint + 1;

  static const int widthMask = 0x03;
  static const int emojiFlag = 0x04;
  static const int printableFlag = 0x08;
  static const int privateUseFlag = 0x10;

  static const int width0NotPrintable = 0x00;
  static const int width1Printable = 0x09;
  static const int width2Printable = 0x0A;
  static const int width2PrintableEmoji = 0x0E;
  static const int width1PrintablePrivateUse = 0x19;

  static const List<UnicodeWidthProperty> wellKnownCodepointRanges = [
    // Default fallback: width 1, printable (FIRST, overwritten by all below)
    UnicodeWidthProperty(0x0000, maxCodepoint, width1Printable),

    // === Width 0: control characters ===
    UnicodeWidthProperty(0x0000, 0x001F, width0NotPrintable),
    UnicodeWidthProperty(0x007F, 0x009F, width0NotPrintable),
    UnicodeWidthProperty(0x00AD, 0x00AD, width0NotPrintable),

    // === Width 0: combining diacritical marks ===
    UnicodeWidthProperty(0x0300, 0x036F, width0NotPrintable),
    UnicodeWidthProperty(0x0483, 0x0489, width0NotPrintable),
    UnicodeWidthProperty(0x0591, 0x05BD, width0NotPrintable),
    UnicodeWidthProperty(0x05BF, 0x05BF, width0NotPrintable),
    UnicodeWidthProperty(0x05C1, 0x05C2, width0NotPrintable),
    UnicodeWidthProperty(0x05C4, 0x05C5, width0NotPrintable),
    UnicodeWidthProperty(0x05C7, 0x05C7, width0NotPrintable),
    UnicodeWidthProperty(0x0610, 0x061A, width0NotPrintable),
    UnicodeWidthProperty(0x064B, 0x065F, width0NotPrintable),
    UnicodeWidthProperty(0x0670, 0x0670, width0NotPrintable),
    UnicodeWidthProperty(0x06D6, 0x06DC, width0NotPrintable),
    UnicodeWidthProperty(0x06DF, 0x06E4, width0NotPrintable),
    UnicodeWidthProperty(0x06E7, 0x06E8, width0NotPrintable),
    UnicodeWidthProperty(0x06EA, 0x06ED, width0NotPrintable),
    UnicodeWidthProperty(0x0711, 0x0711, width0NotPrintable),
    UnicodeWidthProperty(0x0730, 0x074A, width0NotPrintable),
    UnicodeWidthProperty(0x07A6, 0x07B0, width0NotPrintable),
    UnicodeWidthProperty(0x07EB, 0x07F3, width0NotPrintable),
    UnicodeWidthProperty(0x0816, 0x0819, width0NotPrintable),
    UnicodeWidthProperty(0x081B, 0x0823, width0NotPrintable),
    UnicodeWidthProperty(0x0825, 0x0827, width0NotPrintable),
    UnicodeWidthProperty(0x0829, 0x082D, width0NotPrintable),
    UnicodeWidthProperty(0x0859, 0x085B, width0NotPrintable),
    UnicodeWidthProperty(0x08D4, 0x08E1, width0NotPrintable),
    UnicodeWidthProperty(0x08E3, 0x0902, width0NotPrintable),
    UnicodeWidthProperty(0x093A, 0x093A, width0NotPrintable),
    UnicodeWidthProperty(0x093C, 0x093C, width0NotPrintable),
    UnicodeWidthProperty(0x0941, 0x0948, width0NotPrintable),
    UnicodeWidthProperty(0x094D, 0x094D, width0NotPrintable),
    UnicodeWidthProperty(0x0951, 0x0957, width0NotPrintable),
    UnicodeWidthProperty(0x0962, 0x0963, width0NotPrintable),
    UnicodeWidthProperty(0x0981, 0x0981, width0NotPrintable),
    UnicodeWidthProperty(0x09BC, 0x09BC, width0NotPrintable),
    UnicodeWidthProperty(0x09C1, 0x09C4, width0NotPrintable),
    UnicodeWidthProperty(0x09CD, 0x09CD, width0NotPrintable),
    UnicodeWidthProperty(0x09E2, 0x09E3, width0NotPrintable),
    UnicodeWidthProperty(0x0A01, 0x0A02, width0NotPrintable),
    UnicodeWidthProperty(0x0A3C, 0x0A3C, width0NotPrintable),
    UnicodeWidthProperty(0x0A41, 0x0A42, width0NotPrintable),
    UnicodeWidthProperty(0x0A47, 0x0A48, width0NotPrintable),
    UnicodeWidthProperty(0x0A4B, 0x0A4D, width0NotPrintable),
    UnicodeWidthProperty(0x0A70, 0x0A71, width0NotPrintable),
    UnicodeWidthProperty(0x0A81, 0x0A82, width0NotPrintable),
    UnicodeWidthProperty(0x0ABC, 0x0ABC, width0NotPrintable),
    UnicodeWidthProperty(0x0AC1, 0x0AC5, width0NotPrintable),
    UnicodeWidthProperty(0x0AC7, 0x0AC8, width0NotPrintable),
    UnicodeWidthProperty(0x0ACD, 0x0ACD, width0NotPrintable),
    UnicodeWidthProperty(0x0AE2, 0x0AE3, width0NotPrintable),
    UnicodeWidthProperty(0x0B01, 0x0B01, width0NotPrintable),
    UnicodeWidthProperty(0x0B3C, 0x0B3C, width0NotPrintable),
    UnicodeWidthProperty(0x0B3F, 0x0B3F, width0NotPrintable),
    UnicodeWidthProperty(0x0B41, 0x0B44, width0NotPrintable),
    UnicodeWidthProperty(0x0B4D, 0x0B4D, width0NotPrintable),
    UnicodeWidthProperty(0x0B56, 0x0B56, width0NotPrintable),
    UnicodeWidthProperty(0x0B62, 0x0B63, width0NotPrintable),
    UnicodeWidthProperty(0x0B82, 0x0B82, width0NotPrintable),
    UnicodeWidthProperty(0x0BC0, 0x0BC0, width0NotPrintable),
    UnicodeWidthProperty(0x0BCD, 0x0BCD, width0NotPrintable),
    UnicodeWidthProperty(0x0C3E, 0x0C40, width0NotPrintable),
    UnicodeWidthProperty(0x0C46, 0x0C48, width0NotPrintable),
    UnicodeWidthProperty(0x0C4A, 0x0C4D, width0NotPrintable),
    UnicodeWidthProperty(0x0C55, 0x0C56, width0NotPrintable),
    UnicodeWidthProperty(0x0C62, 0x0C63, width0NotPrintable),
    UnicodeWidthProperty(0x0CBC, 0x0CBC, width0NotPrintable),
    UnicodeWidthProperty(0x0CBF, 0x0CBF, width0NotPrintable),
    UnicodeWidthProperty(0x0CC6, 0x0CC6, width0NotPrintable),
    UnicodeWidthProperty(0x0CCC, 0x0CCD, width0NotPrintable),
    UnicodeWidthProperty(0x0CE2, 0x0CE3, width0NotPrintable),
    UnicodeWidthProperty(0x0D41, 0x0D44, width0NotPrintable),
    UnicodeWidthProperty(0x0D4D, 0x0D4D, width0NotPrintable),
    UnicodeWidthProperty(0x0D62, 0x0D63, width0NotPrintable),
    UnicodeWidthProperty(0x0DCA, 0x0DCA, width0NotPrintable),
    UnicodeWidthProperty(0x0DD2, 0x0DD4, width0NotPrintable),
    UnicodeWidthProperty(0x0DD6, 0x0DD6, width0NotPrintable),
    UnicodeWidthProperty(0x0E31, 0x0E31, width0NotPrintable),
    UnicodeWidthProperty(0x0E34, 0x0E3A, width0NotPrintable),
    UnicodeWidthProperty(0x0E47, 0x0E4E, width0NotPrintable),
    UnicodeWidthProperty(0x0EB1, 0x0EB1, width0NotPrintable),
    UnicodeWidthProperty(0x0EB4, 0x0EB9, width0NotPrintable),
    UnicodeWidthProperty(0x0EBB, 0x0EBC, width0NotPrintable),
    UnicodeWidthProperty(0x0EC8, 0x0ECD, width0NotPrintable),
    UnicodeWidthProperty(0x0F18, 0x0F19, width0NotPrintable),
    UnicodeWidthProperty(0x0F35, 0x0F35, width0NotPrintable),
    UnicodeWidthProperty(0x0F37, 0x0F37, width0NotPrintable),
    UnicodeWidthProperty(0x0F39, 0x0F39, width0NotPrintable),
    UnicodeWidthProperty(0x0F71, 0x0F7E, width0NotPrintable),
    UnicodeWidthProperty(0x0F80, 0x0F84, width0NotPrintable),
    UnicodeWidthProperty(0x0F86, 0x0F87, width0NotPrintable),
    UnicodeWidthProperty(0x0F90, 0x0F97, width0NotPrintable),
    UnicodeWidthProperty(0x0F99, 0x0FBC, width0NotPrintable),
    UnicodeWidthProperty(0x0FC6, 0x0FC6, width0NotPrintable),
    UnicodeWidthProperty(0x102D, 0x1030, width0NotPrintable),
    UnicodeWidthProperty(0x1032, 0x1037, width0NotPrintable),
    UnicodeWidthProperty(0x1039, 0x103A, width0NotPrintable),
    UnicodeWidthProperty(0x103D, 0x103E, width0NotPrintable),
    UnicodeWidthProperty(0x1058, 0x1059, width0NotPrintable),
    UnicodeWidthProperty(0x105E, 0x1060, width0NotPrintable),
    UnicodeWidthProperty(0x1071, 0x1074, width0NotPrintable),
    UnicodeWidthProperty(0x1082, 0x1082, width0NotPrintable),
    UnicodeWidthProperty(0x1085, 0x1086, width0NotPrintable),
    UnicodeWidthProperty(0x108D, 0x108D, width0NotPrintable),
    UnicodeWidthProperty(0x109D, 0x109D, width0NotPrintable),

    // === Width 0: zero-width spaces and format characters ===
    UnicodeWidthProperty(0x200B, 0x200F, width0NotPrintable),
    UnicodeWidthProperty(0x2028, 0x202E, width0NotPrintable),
    UnicodeWidthProperty(0x2060, 0x2069, width0NotPrintable),

    // === Width 0: variation selectors and combining half marks ===
    UnicodeWidthProperty(0xFE00, 0xFE0F, width0NotPrintable),
    UnicodeWidthProperty(0xFE20, 0xFE2F, width0NotPrintable),

    // === Width 2 BMP: CJK and wide characters ===
    UnicodeWidthProperty(0x1100, 0x115F, width2Printable),
    UnicodeWidthProperty(0x2329, 0x232A, width2Printable),
    UnicodeWidthProperty(0x2E80, 0x2EFF, width2Printable),
    UnicodeWidthProperty(0x2F00, 0x2FDF, width2Printable),
    UnicodeWidthProperty(0x3000, 0x303E, width2Printable),
    UnicodeWidthProperty(0x3041, 0x3096, width2Printable),
    UnicodeWidthProperty(0x309B, 0x30FF, width2Printable),
    UnicodeWidthProperty(0x3105, 0x312D, width2Printable),
    UnicodeWidthProperty(0x3131, 0x318E, width2Printable),
    UnicodeWidthProperty(0x3190, 0x31EF, width2Printable),
    UnicodeWidthProperty(0x31F0, 0x321E, width2Printable),
    UnicodeWidthProperty(0x3220, 0x3247, width2Printable),
    UnicodeWidthProperty(0x3250, 0x32FE, width2Printable),
    UnicodeWidthProperty(0x3300, 0x33FF, width2Printable),
    UnicodeWidthProperty(0x3400, 0x4DBF, width2Printable),
    UnicodeWidthProperty(0x4E00, 0x9FFF, width2Printable),
    UnicodeWidthProperty(0xA000, 0xA4CF, width2Printable),
    UnicodeWidthProperty(0xA4D0, 0xA4FF, width2Printable),
    UnicodeWidthProperty(0xA500, 0xA63F, width2Printable),
    UnicodeWidthProperty(0xA640, 0xA69F, width2Printable),
    UnicodeWidthProperty(0xA700, 0xA7BF, width2Printable),
    UnicodeWidthProperty(0xA7C0, 0xA7FF, width2Printable),
    UnicodeWidthProperty(0xA800, 0xA82F, width2Printable),
    UnicodeWidthProperty(0xA840, 0xA87F, width2Printable),
    UnicodeWidthProperty(0xA880, 0xA8DF, width2Printable),
    UnicodeWidthProperty(0xA8E0, 0xA8FF, width2Printable),
    UnicodeWidthProperty(0xA900, 0xA92F, width2Printable),
    UnicodeWidthProperty(0xA930, 0xA95F, width2Printable),
    UnicodeWidthProperty(0xA960, 0xA97F, width2Printable),
    UnicodeWidthProperty(0xA980, 0xA9DF, width2Printable),
    UnicodeWidthProperty(0xAA00, 0xAA5F, width2Printable),
    UnicodeWidthProperty(0xAA60, 0xAA7F, width2Printable),
    UnicodeWidthProperty(0xAA80, 0xAAFF, width2Printable),
    UnicodeWidthProperty(0xAB00, 0xAB2F, width2Printable),
    UnicodeWidthProperty(0xAB30, 0xAB6F, width2Printable),
    UnicodeWidthProperty(0xAB70, 0xABFF, width2Printable),
    UnicodeWidthProperty(0xAC00, 0xD7AF, width2Printable),
    UnicodeWidthProperty(0xD7B0, 0xD7FF, width2Printable),
    UnicodeWidthProperty(0xF900, 0xFAFF, width2Printable),
    UnicodeWidthProperty(0xFE10, 0xFE1F, width2Printable),
    UnicodeWidthProperty(0xFE30, 0xFE6F, width2Printable),
    UnicodeWidthProperty(0xFE70, 0xFEFF, width2Printable),
    UnicodeWidthProperty(0xFF01, 0xFF60, width2Printable),
    UnicodeWidthProperty(0xFFE0, 0xFFE6, width2Printable),

    // Override CJK combining marks back to width 0 (within Hiragana range above)
    UnicodeWidthProperty(0x3099, 0x309A, width0NotPrintable),

    // Private Use Area
    UnicodeWidthProperty(0xE000, 0xF8FF, width1PrintablePrivateUse),

    // === Width 2 above BMP: CJK Extension B through F ===
    UnicodeWidthProperty(0x20000, 0x2A6DF, width2Printable),
    UnicodeWidthProperty(0x2A700, 0x2B73F, width2Printable),
    UnicodeWidthProperty(0x2B740, 0x2B81F, width2Printable),
    UnicodeWidthProperty(0x2B820, 0x2CEAF, width2Printable),
    UnicodeWidthProperty(0x2CEB0, 0x2EBEF, width2Printable),
    UnicodeWidthProperty(0x2F800, 0x2FA1F, width2Printable),

    // Kana Supplement
    UnicodeWidthProperty(0x1B000, 0x1B0FF, width2Printable),
    UnicodeWidthProperty(0x1B100, 0x1B12F, width2Printable),

    // === Emoji (width 2, printable, emoji flag) ===
    UnicodeWidthProperty(0x1F004, 0x1F004, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F0CF, 0x1F0CF, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F18E, 0x1F19A, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F200, 0x1F251, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F300, 0x1F320, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F32D, 0x1F335, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F337, 0x1F37C, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F37E, 0x1F393, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F3A0, 0x1F3CA, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F3CF, 0x1F3D3, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F3E0, 0x1F3F0, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F3F4, 0x1F3F4, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F3F8, 0x1F43E, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F440, 0x1F440, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F442, 0x1F4FC, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F4FF, 0x1F53D, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F54B, 0x1F54E, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F550, 0x1F567, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F57A, 0x1F57A, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F595, 0x1F596, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F5A4, 0x1F5A4, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F5FB, 0x1F64F, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F680, 0x1F6C5, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F6CC, 0x1F6CC, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F6D0, 0x1F6D2, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F6EB, 0x1F6EC, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F6F3, 0x1F6F8, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F910, 0x1F93A, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F93C, 0x1F945, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F947, 0x1F94C, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F950, 0x1F96B, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F980, 0x1F997, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F9C0, 0x1F9C0, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F9D0, 0x1F9E6, width2PrintableEmoji),

    // === Width 0 above BMP: variation selectors supplement ===
    UnicodeWidthProperty(0xE0100, 0xE01EF, width0NotPrintable),
  ];
}

final class UnicodeLookup {
  const UnicodeLookup._();

  static final Uint8List _propertyTable = () {
    final table = Uint8List(UnicodeTable.tableLength);

    for (final range in UnicodeTable.wellKnownCodepointRanges) {
      final start = range.start;
      final end = range.end;
      final property = range.width;

      if (start < 0) continue;

      for (var cp = start; cp <= end && cp < UnicodeTable.tableLength; cp++) {
        table[cp] = property;
      }
    }
    return table;
  }();

  static int _lookupProperties(int codepoint) =>
      (codepoint < 0 || codepoint > UnicodeTable.maxCodepoint)
          ? 0
          : _propertyTable[codepoint];

  // MARK: - Public API

  static int charWidth(int codepoint) =>
      _lookupProperties(codepoint) & UnicodeTable.widthMask;

  static bool isEmoji(int codepoint) =>
      (_lookupProperties(codepoint) & UnicodeTable.emojiFlag) != 0;

  static bool isPrintable(int codepoint) =>
      (_lookupProperties(codepoint) & UnicodeTable.printableFlag) != 0;

  static bool isPrivateUse(int codepoint) =>
      (_lookupProperties(codepoint) & UnicodeTable.privateUseFlag) != 0;

  static bool isAmbiguousWidth(int codepoint) =>
      (_lookupProperties(codepoint) & UnicodeTable.widthMask) == 3;
}

// Top-level shims for backward compatibility with existing callers.
int charWidthFromTable(int codepoint) => UnicodeLookup.charWidth(codepoint);
bool isEmojiFromTable(int codepoint) => UnicodeLookup.isEmoji(codepoint);
bool isPrintableFromTable(int codepoint) =>
    UnicodeLookup.isPrintable(codepoint);
bool isPrivateUseFromTable(int codepoint) =>
    UnicodeLookup.isPrivateUse(codepoint);
bool isAmbiguousWidthFromTable(int codepoint) =>
    UnicodeLookup.isAmbiguousWidth(codepoint);
