/// Byte classification range boundaries for the terminal parser.
final class ByteRanges {
  ByteRanges._();

  /// Lowest valid byte value.
  static const int byteRangeLowest = 0x00;

  /// Start of C0 control range.
  static const int byteRangeControlLow = 0x00;

  /// End of first C0 control sub-range.
  static const int byteRangeControlHigh = 0x17;

  /// Start of control skip range (CAN, SUB).
  static const int byteRangeControlSkipLow = 0x18;

  /// End of control skip range.
  static const int byteRangeControlSkipHigh = 0x1A;

  /// Start of second C0 control sub-range.
  static const int byteRangeControlLow2 = 0x19;

  /// End of C0 control range.
  static const int byteRangeControlHigh2 = 0x1F;

  /// Start of printable characters.
  static const int byteRangePrintableLow = 0x20;

  /// End of printable characters.
  static const int byteRangePrintableHigh = 0x7E;

  /// Start of graphic/intermediate bytes.
  static const int byteRangeGraphicLow = 0x20;

  /// End of graphic/intermediate bytes.
  static const int byteRangeGraphicHigh = 0x2F;

  /// Start of parameter bytes.
  static const int byteRangeParamLow = 0x30;

  /// End of parameter bytes.
  static const int byteRangeParamHigh = 0x3F;

  /// Start of digit bytes.
  static const int byteRangeDigitLow = 0x30;

  /// End of digit bytes.
  static const int byteRangeDigitHigh = 0x39;

  /// Start of final/uppercase bytes.
  static const int byteRangeUpperLow = 0x40;

  /// End of final/uppercase bytes.
  static const int byteRangeUpperHigh = 0x7E;

  /// Start of C1 control range.
  static const int byteRangeC1Low = 0x80;

  /// End of first C1 sub-range.
  static const int byteRangeC1High = 0x8F;

  /// Start of second C1 control sub-range.
  static const int byteRangeC1bLow = 0x90;

  /// End of second C1 sub-range.
  static const int byteRangeC1bHigh = 0x9A;
}
