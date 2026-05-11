final class Defaults {
  Defaults._();

  // ── C0 control bytes ──

  static const int escapeByte = 0x1B;
  static const int bellByte = 0x07;
  static const int carriageReturnByte = 0x0D;
  static const int lineFeedByte = 0x0A;

  // ── C1 8-bit control bytes ──

  static const int stringTerminatorByte = 0x9C;
  static const int csiIntroducerByte = 0x9B;
  static const int oscIntroducerByte = 0x9D;
  static const int dcsIntroducerByte = 0x90;
  static const int sosIntroducerByte = 0x98;
  static const int pmIntroducerByte = 0x9E;
  static const int apcIntroducerByte = 0x9F;

  // ── escape sequence introducer strings ──

  static const String esc = '\x1b';
  static const String csi = '\x1b[';
  static const String osc = '\x1b]';
  static const String dcs = '\x1bP';
  static const String st = '\x1b\\';
  static const String bel = '\x07';

  // ── 7-bit escape sequence entry bytes ──

  static const int csiEntryByte = 0x5B;
  static const int oscEntryByte = 0x5D;
  static const int dcsEntryByte = 0x50;
  static const int dcsStByte = 0x5C;
  static const int ss3Byte = 0x4F;
  static const int decPrivatePrefix = 0x3F;

  // ── byte classification ranges ──

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

  // ── parameter delimiters ──

  static const int semicolonByte = 0x3B;
  static const int intermediatePrefixByte = 0x3C;

  // ── SGR (Select Graphic Rendition) parameter values ──

  static const int sgrReset = 0;
  static const int sgrBold = 1;
  static const int sgrFaint = 2;
  static const int sgrItalic = 3;
  static const int sgrUnderline = 4;
  static const int sgrBlink = 5;
  static const int sgrReverse = 7;
  static const int sgrStrikethrough = 9;
  static const int sgrOverline = 53;
  static const int sgrNoBoldFaint = 22;
  static const int sgrNoItalic = 23;
  static const int sgrNoUnderline = 24;
  static const int sgrNoBlink = 25;
  static const int sgrNoReverse = 27;
  static const int sgrNoStrikethrough = 29;
  static const int sgrNoOverline = 55;

  // ── ANSI color SGR base codes ──

  static const int sgrFgAnsiBase = 30;
  static const int sgrBgAnsiBase = 40;
  static const int sgrFgBrightBase = 90;
  static const int sgrBgBrightBase = 100;
  static const int sgrFgExtended = 38;
  static const int sgrBgExtended = 48;
  static const int sgrFgReset = 39;
  static const int sgrBgReset = 49;
  static const int sgrColor256 = 5;
  static const int sgrColorRgb = 2;

  // ── SGR final byte ──

  static const int csiFinalSgr = 0x6D;

  // ── CSI final bytes (cursor, display, modes) ──

  static const int csiFinalUp = 0x41;
  static const int csiFinalDown = 0x42;
  static const int csiFinalRight = 0x43;
  static const int csiFinalLeft = 0x44;
  static const int csiFinalCup = 0x48;
  static const int csiFinalHome = 0x48;
  static const int csiFinalEnd = 0x46;
  static const int csiFinalCha = 0x47;
  static const int csiFinalEd = 0x4A;
  static const int csiFinalEl = 0x4B;
  static const int csiFinalDecset = 0x68;
  static const int csiFinalDecrst = 0x6C;
  static const int csiFinalSaveCursor = 0x73;
  static const int csiFinalRestoreCursor = 0x75;
  static const int csiFinalDsr = 0x6E;
  static const int csiFinalDA = 0x63;

  // ── CSI final bytes (input events) ──

  static const int csiFinalF1 = 0x50;
  static const int csiFinalF2 = 0x51;
  static const int csiFinalCursorPos = 0x52;
  static const int csiFinalF4 = 0x53;
  static const int csiFinalTilde = 0x7E;
  static const int csiFinalMouse = 0x4D;

  // ── CSI intermediate bytes ──

  static const int csiExtendedIntermediate = 0x3C;
  static const int csiKittyQueryIntermediate = 0x3E;
  static const int csiDecDollar = 0x24;

  // ── CSI final byte for Kitty keyboard ──

  static const int csiFinalKittyKey = 0x75;

  // ── ESC sequence final bytes ──

  static const int escFinalReset = 0x63;
  static const int escFinalSaveCursor = 0x37;
  static const int escFinalRestoreCursor = 0x38;
  static const int escFinalScrollReverse = 0x4D;
  static const int escSs3F1 = 0x50;
  static const int escSs3F2 = 0x51;
  static const int escSs3F3 = 0x52;
  static const int escSs3F4 = 0x53;

  // ── DCS final / intermediate bytes ──

  static const int dcsKittyGraphicsP = 0x70;
  static const int dcsKittyGraphicsQ = 0x71;
  static const int dcsKittyIntermediate = 0x2B;

  // ── OSC PSN (parameter sub-number) codes ──

  static const int oscTitle = 0;
  static const int oscHyperlink = 8;
  static const int oscFgQuery = 10;
  static const int oscBgQuery = 11;
  static const int oscClipboard = 52;

  // ── modifier bit masks ──

  static const int modShift = 1;
  static const int modAlt = 2;
  static const int modCtrl = 4;
  static const int modMeta = 8;

  // ── mouse parsing ──

  static const int mouseWheelUpCode = 64;
  static const int mouseWheelDownCode = 65;
  static const int mouseDragBit = 32;
  static const int mouseButtonMask = 3;
  static const int mouseButtonLeft = 0;
  static const int mouseButtonMiddle = 1;
  static const int mouseButtonRight = 2;

  // ── Kitty keyboard protocol ──

  static const int kittyDisambiguate = 1;
  static const int kittyAllEvents = 3;
  static const int kittyEventUp = 2;
  static const int kittyEventRepeat = 3;

  // ── Kitty key code map bytes ──

  static const int kittyKeyEscape = 0x1B;
  static const int kittyKeyTab = 0x09;
  static const int kittyKeyEnter = 0x0D;
  static const int kittyKeyBackspace = 0x08;
  static const int kittyKeyBackspaceAlt = 0x7F;
  static const int kittyKeyHome = 0x01;
  static const int kittyKeyEnd = 0x04;
  static const int kittyKeyPageUp = 0x05;
  static const int kittyKeyPageDown = 0x06;
  static const int kittyKeyInsert = 0x02;
  static const int kittyKeyDelete = 0x03;
  static const int kittyKeyDeleteAlt = 0x1A;

  // ── DEC private mode numbers ──

  static const int decModeMouseNormal = 1000;
  static const int decModeMouseButton = 1002;
  static const int decModeMouseSgr = 1006;
  static const int decModeFocus = 1004;
  static const int decModeBracketedPaste = 2004;
  static const int decModeSync = 2026;
  static const int decModeAltScreen = 1049;
  static const int decModeCursorVisible = 25;

  // ── cursor style values ──

  static const int cursorStyleBlinkingBlock = 1;
  static const int cursorStyleSteadyBlock = 2;
  static const int cursorStyleBlinkingUnderline = 3;
  static const int cursorStyleSteadyUnderline = 4;
  static const int cursorStyleBlinkingBar = 5;
  static const int cursorStyleSteadyBar = 6;

  // ── erase display modes ──

  static const int eraseDisplayBelow = 0;
  static const int eraseDisplayAbove = 1;
  static const int eraseDisplayAll = 2;
  static const int eraseDisplaySaved = 3;

  // ── erase line modes ──

  static const int eraseLineRight = 0;
  static const int eraseLineLeft = 1;
  static const int eraseLineAll = 2;

  // ── DA1 (device attributes) ──

  static const int da1TerminalIdDefault = 0;
  static const int da1AttrIndexed256 = 22;
  static const int da1AttrTrueColor = 28;

  // ── color profiles ──

  static const int colorProfileAnsiCount = 16;
  static const int colorProfileIndexedCount = 256;
  static const int indexedColorCubeStart = 16;
  static const int indexedColorCubeSize = 6;
  static const int indexedColorGrayStart = 232;
  static const int indexedColorGrayCount = 24;
  static const int ansiBrightOffset = 60;
  static const int ansiColorMax = 15;
  static const int ansiDarkThreshold = 8;

  // ── default link color (RGB) ──

  static const int linkColorRed = 0;
  static const int linkColorGreen = 102;
  static const int linkColorBlue = 204;

  // ── RGB color composition ──

  static const int rgbComponentMax = 255;
  static const int rgbRedShift = 16;
  static const int rgbGreenShift = 8;
  static const int rgbBlueMask = 0xFF;

  // ── byte bit operations ──

  static const int bitShift8 = 8;
  static const int bitShift16 = 16;
  static const int bitShift24 = 24;
  static const int byteMask = 0xFF;

  // ── termios local mode flags ──

  static const int termiosEcho = 0x00000008;
  static const int termiosICanon = 0x00000002;
  static const int termiosISig = 0x00000001;
  static const int termiosIExten = 0x00008000;

  // ── termios struct layout ──

  static const int termiosStructSize = 60;
  static const int termiosOffsetIFlag = 0;
  static const int termiosOffsetOFlag = 4;
  static const int termiosOffsetCFlag = 8;
  static const int termiosOffsetLFlag = 12;
  static const int termiosOffsetCCMin = 17;
  static const int termiosOffsetCCTime = 18;
  static const int termiosVminRaw = 1;
  static const int termiosVtimeRaw = 0;

  // ── tcsetattr action ──

  static const int tcsaNow = 0;

  // ── standard file descriptors ──

  static const int stdinFd = 0;

  // ── libc library names ──

  static const String libcMacOS = 'libSystem.dylib';
  static const String libcLinux6 = 'libc.so.6';
  static const String libcLinux7 = 'libc.so.7';

  // ── environment string constants ──

  static const String envColortermTruecolor = 'truecolor';
  static const String envColorterm24bit = '24bit';
  static const String envTermSuffix256Color = '-256color';
  static const String envTermSuffixTrueColor = '-truecolor';
  static const String envTermSuffixDirect = '-direct';

  // ── timing / duration defaults ──

  static const Duration escDisambiguationDelay = Duration(milliseconds: 10);
  static const Duration eventLoopSleep = Duration(milliseconds: 1);
  static const Duration defaultProbeTimeout = Duration(seconds: 1);
  static const Duration spinnerAnimInterval = Duration(milliseconds: 80);
  static const Duration progressAnimInterval = Duration(milliseconds: 100);
  static const Duration cursorBlinkInterval = Duration(milliseconds: 500);

  // ── rendering / FPS ──

  static const int defaultFps = 60;
  static const int microsecondsPerSecond = 1000000;

  // ── default terminal / viewport sizes ──

  static const int defaultTerminalWidth = 80;
  static const int defaultTerminalHeight = 24;
  static const int defaultViewportHeight = 10;
  static const int defaultScrollStep = 3;
  static const int defaultProgressBarWidth = 20;
  static const int scrollbarMinViewportHeight = 2;

  // ── dialog layout ──

  static const double dialogWidthRatio = 0.6;
  static const double dialogHeightRatio = 0.4;
  static const int dialogMinWidth = 20;
  static const int dialogMinHeight = 5;
  static const int dialogHMargin = 4;
  static const int dialogButtonBarHeight = 3;
  static const int dialogContentClampHigh = 100;

  // ── text input ──

  static const int textInputNoMaxLength = -1;

  // ── layout / geometry sentinels ──

  static const int unbounded = 0x7FFFFFFF;

  // ── Unicode codepoints (control / whitespace) ──

  static const int codepointSpace = 0x20;
  static const int codepointDel = 0x7F;
  static const int codepointIdeographicSpace = 0x3000;
  static const int codepointZwj = 0x200D;

  // ── Unicode box-drawing / UI glyphs ──

  static const String charFullBlock = '\u2588';
  static const String charLightShade = '\u2591';
  static const String charBullet = '\u2022';
  static const String charCheckMark = '\u2713';
  static const String charRightTriangle = '\u25B6';
  static const String charUpTriangle = '\u25B2';
  static const String charDownTriangle = '\u25BC';

  // ── border glyph sets ──

  static const String borderSingle = '│─┌┐└┘';
  static const String borderDouble = '║═╔╗╚╝';
  static const String borderRounded = '│─╭╮╰╯';
  static const String borderThick = '┃━┏┓┗┛';

  // ── braille spinner frames ──

  static const List<String> spinnerFrames = [
    '\u280B',
    '\u2819',
    '\u2839',
    '\u2838',
    '\u283C',
    '\u2834',
    '\u2826',
    '\u2827',
    '\u2807',
    '\u280F',
  ];

  // ── grapheme break property values ──

  static const int graphemePropZwj = 1;
  static const int graphemePropVariationSelector = 2;
  static const int graphemePropRegionalIndicator = 3;
  static const int graphemePropCombiningMark = 4;
  static const int graphemePropEmojiModifier = 5;
  static const int graphemePropExtendedPictographic = 10;
  static const int graphemePropInvisible = 11;

  // ── Unicode width constants ──

  static const int wideCharWidth = 2;
  static const int zeroCharWidth = 0;

  // ── signal handler ──

  static const int exitCodeOk = 0;
}
