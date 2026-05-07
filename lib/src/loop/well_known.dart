final class WellKnown {
  WellKnown._();

  static const int escapeByte = 0x1B;
  static const int bellByte = 0x07;
  static const int stringTerminatorByte = 0x9C;
  static const int csiIntroducerByte = 0x9B;
  static const int oscIntroducerByte = 0x9D;
  static const int dcsIntroducerByte = 0x90;
  static const int sosIntroducerByte = 0x98;
  static const int pmIntroducerByte = 0x9E;
  static const int apcIntroducerByte = 0x9F;

  static const int byteRangeLowest = 0x00;
  static const int byteRangeControlLow = 0x00;
  static const int byteRangeControlHigh = 0x17;
  static const int byteRangeControlSkipLow = 0x18;
  static const int byteRangeControlSkipHigh = 0x1A;
  static const int byteRangeControlLow2 = 0x19;
  static const int byteRangeControlHigh2 = 0x1F;
  static const int byteRangePrintableLow = 0x20;
  static const int byteRangePrintableHigh = 0x7E;
  static const int byteRangeGraphicLow = 0x20;
  static const int byteRangeGraphicHigh = 0x2F;
  static const int byteRangeParamLow = 0x30;
  static const int byteRangeParamHigh = 0x3F;
  static const int byteRangeDigitLow = 0x30;
  static const int byteRangeDigitHigh = 0x39;
  static const int byteRangeUpperLow = 0x40;
  static const int byteRangeUpperHigh = 0x7E;
  static const int byteRangeC1Low = 0x80;
  static const int byteRangeC1High = 0x8F;
  static const int byteRangeC1bLow = 0x90;
  static const int byteRangeC1bHigh = 0x9A;
  static const int semicolonByte = 0x3B;
  static const int intermediatePrefixByte = 0x3C;
  static const int dcsStByte = 0x5C;
  static const int csiEntryByte = 0x5B;
  static const int oscEntryByte = 0x5D;
  static const int dcsEntryByte = 0x50;
  static const int ss3Byte = 0x4F;

  static const Duration escDisambiguationDelay = Duration(milliseconds: 10);
  static const Duration eventLoopSleep = Duration(milliseconds: 1);
  static const Duration defaultProbeTimeout = Duration(seconds: 1);

  static const int defaultFps = 60;

  static const int da1TerminalIdDefault = 0;
  static const int colorProfileAnsiCount = 16;
  static const int colorProfileIndexedCount = 256;
  static const int indexedColorCubeStart = 16;
  static const int indexedColorCubeSize = 6;
  static const int indexedColorGrayStart = 232;
  static const int indexedColorGrayCount = 24;
  static const int ansiBrightOffset = 60;
  static const int ansiColorMax = 15;
  static const int ansiDarkThreshold = 8;
}
