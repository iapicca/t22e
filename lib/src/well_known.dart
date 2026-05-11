final class WellKnown {
  WellKnown._();

  // ── C0 control bytes ──

  /// ESC (escape) — starts an escape sequence
  static const int escapeByte = 0x1B;
  /// BEL (bell) — terminates OSC strings in some terminals
  static const int bellByte = 0x07;
  /// CR (carriage return)
  static const int carriageReturnByte = 0x0D;
  /// LF (line feed / newline)
  static const int lineFeedByte = 0x0A;

  // ── C1 8-bit control bytes ──

  /// ST (string terminator) — terminates OSC / DCS / APC / PM / SOS
  static const int stringTerminatorByte = 0x9C;
  /// CSI introducer (8-bit)
  static const int csiIntroducerByte = 0x9B;
  /// OSC introducer (8-bit)
  static const int oscIntroducerByte = 0x9D;
  /// DCS introducer (8-bit)
  static const int dcsIntroducerByte = 0x90;
  /// SOS introducer (8-bit)
  static const int sosIntroducerByte = 0x98;
  /// PM introducer (8-bit)
  static const int pmIntroducerByte = 0x9E;
  /// APC introducer (8-bit)
  static const int apcIntroducerByte = 0x9F;

  // ── escape sequence introducer strings ──

  /// ESC character as a string
  static const String esc = '\x1b';
  /// CSI (Control Sequence Introducer) — 7-bit equivalent '\x1b['
  static const String csi = '\x1b[';
  /// OSC (Operating System Command) — 7-bit equivalent '\x1b]'
  static const String osc = '\x1b]';
  /// DCS (Device Control String) — 7-bit equivalent '\x1bP'
  static const String dcs = '\x1bP';
  /// ST (String Terminator) — 7-bit equivalent '\x1b\\'
  static const String st = '\x1b\\';
  /// BEL character as a string
  static const String bel = '\x07';

  // ── 7-bit escape sequence entry bytes ──

  /// '[' — CSI entry byte after ESC
  static const int csiEntryByte = 0x5B;
  /// ']' — OSC entry byte after ESC
  static const int oscEntryByte = 0x5D;
  /// 'P' — DCS entry byte after ESC
  static const int dcsEntryByte = 0x50;
  /// '\' — ST byte within ESC-\\ sequences
  static const int dcsStByte = 0x5C;
  /// 'O' — SS3 (Single Shift 3) entry byte
  static const int ss3Byte = 0x4F;
  /// '?' — DEC private mode prefix
  static const int decPrivatePrefix = 0x3F;

  // ── byte classification ranges ──

  /// Lowest possible byte value
  static const int byteRangeLowest = 0x00;
  /// C0 control range: 0x00–0x17
  static const int byteRangeControlLow = 0x00;
  static const int byteRangeControlHigh = 0x17;
  /// Skippable control range: CAN (0x18) – SUB (0x1A)
  static const int byteRangeControlSkipLow = 0x18;
  static const int byteRangeControlSkipHigh = 0x1A;
  /// Second C0 control segment: 0x19–0x1F
  static const int byteRangeControlLow2 = 0x19;
  static const int byteRangeControlHigh2 = 0x1F;
  /// Printable ASCII range: SP (0x20) – '~' (0x7E)
  static const int byteRangePrintableLow = 0x20;
  static const int byteRangePrintableHigh = 0x7E;
  /// Graphic/intermediate bytes: 0x20–0x2F
  static const int byteRangeGraphicLow = 0x20;
  static const int byteRangeGraphicHigh = 0x2F;
  /// Parameter bytes: '0'–'?' (0x30–0x3F)
  static const int byteRangeParamLow = 0x30;
  static const int byteRangeParamHigh = 0x3F;
  /// Digit range: '0'–'9' (0x30–0x39)
  static const int byteRangeDigitLow = 0x30;
  static const int byteRangeDigitHigh = 0x39;
  /// Upper/middle bytes (final bytes): '@'–'~' (0x40–0x7E)
  static const int byteRangeUpperLow = 0x40;
  static const int byteRangeUpperHigh = 0x7E;
  /// C1 first half: 0x80–0x8F
  static const int byteRangeC1Low = 0x80;
  static const int byteRangeC1High = 0x8F;
  /// C1 second half: 0x90–0x9A
  static const int byteRangeC1bLow = 0x90;
  static const int byteRangeC1bHigh = 0x9A;

  // ── parameter delimiters ──

  /// ';' — semicolon separates CSI / DCS parameters
  static const int semicolonByte = 0x3B;
  /// '<' — intermediate prefix for extended CSI sequences
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
  /// Resets both bold and faint
  static const int sgrNoBoldFaint = 22;
  static const int sgrNoItalic = 23;
  static const int sgrNoUnderline = 24;
  static const int sgrNoBlink = 25;
  static const int sgrNoReverse = 27;
  static const int sgrNoStrikethrough = 29;
  static const int sgrNoOverline = 55;

  // ── ANSI color SGR base codes ──

  /// Foreground color offset for standard ANSI colors (30–37)
  static const int sgrFgAnsiBase = 30;
  /// Background color offset for standard ANSI colors (40–47)
  static const int sgrBgAnsiBase = 40;
  /// Foreground bright ANSI offset (90–97)
  static const int sgrFgBrightBase = 90;
  /// Background bright ANSI offset (100–107)
  static const int sgrBgBrightBase = 100;
  /// Extended foreground color code
  static const int sgrFgExtended = 38;
  /// Extended background color code
  static const int sgrBgExtended = 48;
  /// Reset foreground to default
  static const int sgrFgReset = 39;
  /// Reset background to default
  static const int sgrBgReset = 49;
  /// 256-color sub-parameter for SGR 38/48
  static const int sgrColor256 = 5;
  /// RGB color sub-parameter for SGR 38/48
  static const int sgrColorRgb = 2;

  // ── SGR final byte ──

  /// CSI final byte 'm' — Select Graphic Rendition
  static const int csiFinalSgr = 0x6D;

  // ── CSI final bytes (cursor, display, modes) ──

  /// 'A' — cursor up
  static const int csiFinalUp = 0x41;
  /// 'B' — cursor down
  static const int csiFinalDown = 0x42;
  /// 'C' — cursor forward / right
  static const int csiFinalRight = 0x43;
  /// 'D' — cursor backward / left
  static const int csiFinalLeft = 0x44;
  /// 'H' — cursor position (also used for home)
  static const int csiFinalCup = 0x48;
  /// Alias for csiFinalCup; used when 'H' represents the Home key
  static const int csiFinalHome = 0x48;
  /// 'F' — cursor preceding line (used as end key)
  static const int csiFinalEnd = 0x46;
  /// 'G' — cursor horizontal absolute (column)
  static const int csiFinalCha = 0x47;
  /// 'J' — erase in display
  static const int csiFinalEd = 0x4A;
  /// 'K' — erase in line
  static const int csiFinalEl = 0x4B;
  /// 'h' — DEC set mode
  static const int csiFinalDecset = 0x68;
  /// 'l' — DEC reset mode
  static const int csiFinalDecrst = 0x6C;
  /// 'm' — SGR; also used as 's' (save cursor)
  static const int csiFinalSaveCursor = 0x73;
  /// 'u' — restore cursor
  static const int csiFinalRestoreCursor = 0x75;
  /// 'n' — device status report
  static const int csiFinalDsr = 0x6E;
  /// 'c' — primary device attributes
  static const int csiFinalDA = 0x63;

  // ── CSI final bytes (input events) ──

  /// 'P' — F1 key
  static const int csiFinalF1 = 0x50;
  /// 'Q' — F2 key
  static const int csiFinalF2 = 0x51;
  /// 'R' — cursor position report / F3 key
  static const int csiFinalCursorPos = 0x52;
  /// 'S' — F4 key
  static const int csiFinalF4 = 0x53;
  /// '~' — tilde-encoded function / special keys
  static const int csiFinalTilde = 0x7E;
  /// 'M' — mouse tracking (SGR / X10)
  static const int csiFinalMouse = 0x4D;

  // ── CSI intermediate bytes ──

  /// '<' — extended CSI intermediate (SGR mouse, etc.)
  static const int csiExtendedIntermediate = 0x3C;
  /// '>' — Kitty keyboard query intermediate
  static const int csiKittyQueryIntermediate = 0x3E;
  /// '$' — DECRQM / DECRPM intermediate
  static const int csiDecDollar = 0x24;

  // ── CSI final byte for Kitty keyboard ──

  /// 'u' — Kitty keyboard protocol CSI
  static const int csiFinalKittyKey = 0x75;

  // ── ESC sequence final bytes ──

  /// 'c' — RIS (reset to initial state)
  static const int escFinalReset = 0x63;
  /// '7' — save cursor
  static const int escFinalSaveCursor = 0x37;
  /// '8' — restore cursor
  static const int escFinalRestoreCursor = 0x38;
  /// 'M' — reverse index (scroll reverse)
  static const int escFinalScrollReverse = 0x4D;
  /// 'P' — SS3 F1
  static const int escSs3F1 = 0x50;
  /// 'Q' — SS3 F2
  static const int escSs3F2 = 0x51;
  /// 'R' — SS3 F3
  static const int escSs3F3 = 0x52;
  /// 'S' — SS3 F4
  static const int escSs3F4 = 0x53;

  // ── DCS final / intermediate bytes ──

  /// 'p' — Kitty graphics protocol command
  static const int dcsKittyGraphicsP = 0x70;
  /// 'q' — Kitty graphics protocol response
  static const int dcsKittyGraphicsQ = 0x71;
  /// '+' — intermediate byte for Kitty graphics DCS
  static const int dcsKittyIntermediate = 0x2B;

  // ── OSC PSN (parameter sub-number) codes ──

  /// Window / icon title (0 = both, 1 = icon, 2 = window)
  static const int oscTitle = 0;
  /// Hyperlink
  static const int oscHyperlink = 8;
  /// Query foreground color
  static const int oscFgQuery = 10;
  /// Query background color
  static const int oscBgQuery = 11;
  /// Clipboard read / write
  static const int oscClipboard = 52;

  // ── modifier bit masks ──

  static const int modShift = 1;
  static const int modAlt = 2;
  static const int modCtrl = 4;
  static const int modMeta = 8;

  // ── mouse parsing ──

  /// SGR mouse wheel-up code
  static const int mouseWheelUpCode = 64;
  /// SGR mouse wheel-down code
  static const int mouseWheelDownCode = 65;
  /// Bit indicating mouse drag / motion
  static const int mouseDragBit = 32;
  /// Bits masking the button number
  static const int mouseButtonMask = 3;
  /// Mouse button code: left
  static const int mouseButtonLeft = 0;
  /// Mouse button code: middle
  static const int mouseButtonMiddle = 1;
  /// Mouse button code: right
  static const int mouseButtonRight = 2;

  // ── Kitty keyboard protocol ──

  /// Kitty flags: disambiguate escape codes
  static const int kittyDisambiguate = 1;
  /// Kitty flags: report all events (disambiguate + progressives)
  static const int kittyAllEvents = 3;
  /// Kitty key event type: release
  static const int kittyEventUp = 2;
  /// Kitty key event type: repeat
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

  /// Normal mouse tracking
  static const int decModeMouseNormal = 1000;
  /// Button-event mouse tracking
  static const int decModeMouseButton = 1002;
  /// SGR extended mouse
  static const int decModeMouseSgr = 1006;
  /// Focus tracking
  static const int decModeFocus = 1004;
  /// Bracketed paste
  static const int decModeBracketedPaste = 2004;
  /// Synchronized update
  static const int decModeSync = 2026;
  /// Alternate screen buffer
  static const int decModeAltScreen = 1049;
  /// Cursor visibility
  static const int decModeCursorVisible = 25;

  // ── cursor style values ──

  static const int cursorStyleBlinkingBlock = 1;
  static const int cursorStyleSteadyBlock = 2;
  static const int cursorStyleBlinkingUnderline = 3;
  static const int cursorStyleSteadyUnderline = 4;
  static const int cursorStyleBlinkingBar = 5;
  static const int cursorStyleSteadyBar = 6;

  // ── erase display modes ──

  /// Erase from cursor to end of screen
  static const int eraseDisplayBelow = 0;
  /// Erase from start of screen to cursor
  static const int eraseDisplayAbove = 1;
  /// Erase entire screen
  static const int eraseDisplayAll = 2;
  /// Erase entire screen + scrollback buffer
  static const int eraseDisplaySaved = 3;

  // ── erase line modes ──

  /// Erase from cursor to end of line
  static const int eraseLineRight = 0;
  /// Erase from start of line to cursor
  static const int eraseLineLeft = 1;
  /// Erase entire line
  static const int eraseLineAll = 2;

  // ── DA1 (device attributes) ──

  /// Terminal ID default index in response parameters
  static const int da1TerminalIdDefault = 0;
  /// DA1 attribute: 256-color support
  static const int da1AttrIndexed256 = 22;
  /// DA1 attribute: true color support
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

  /// Echo input
  static const int termiosEcho = 0x00000008;
  /// Canonical mode (line buffering)
  static const int termiosICanon = 0x00000002;
  /// Signal generation (INTR, QUIT, SUSP)
  static const int termiosISig = 0x00000001;
  /// Extended input processing
  static const int termiosIExten = 0x00008000;

  // ── termios struct layout ──

  static const int termiosStructSize = 60;
  static const int termiosOffsetIFlag = 0;
  static const int termiosOffsetOFlag = 4;
  static const int termiosOffsetCFlag = 8;
  static const int termiosOffsetLFlag = 12;
  /// c_cc[VMIN] offset
  static const int termiosOffsetCCMin = 17;
  /// c_cc[VTIME] offset
  static const int termiosOffsetCCTime = 18;
  /// VMIN value for raw (non-blocking) mode
  static const int termiosVminRaw = 1;
  /// VTIME value for raw (non-blocking) mode
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
  /// Viewport must be taller than this for scrollbar to appear
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

  /// Sentinel value for unlimited max length
  static const int textInputNoMaxLength = -1;

  // ── layout / geometry sentinels ──

  /// Maximum int for unbounded constraint dimensions
  static const int unbounded = 0x7FFFFFFF;

  // ── Unicode codepoints (control / whitespace) ──

  /// SPACE (U+0020)
  static const int codepointSpace = 0x20;
  /// DELETE (U+007F)
  static const int codepointDel = 0x7F;
  /// Ideographic space (U+3000)
  static const int codepointIdeographicSpace = 0x3000;
  /// Zero-width joiner (U+200D)
  static const int codepointZwj = 0x200D;

  // ── Unicode box-drawing / UI glyphs ──

  /// Full block '█'
  static const String charFullBlock = '\u2588';
  /// Light shade '░'
  static const String charLightShade = '\u2591';
  /// Bullet '•'
  static const String charBullet = '\u2022';
  /// Check mark '✓'
  static const String charCheckMark = '\u2713';
  /// Right-pointing triangle '▶'
  static const String charRightTriangle = '\u25B6';
  /// Up-pointing triangle '▲'
  static const String charUpTriangle = '\u25B2';
  /// Down-pointing triangle '▼'
  static const String charDownTriangle = '\u25BC';

  // ── border glyph sets ──
  /// Order: [vertical, horizontal, top-left, top-right, bottom-left, bottom-right]
  /// Single-line border
  static const String borderSingle = '│─┌┐└┘';
  /// Double-line border
  static const String borderDouble = '║═╔╗╚╝';
  /// Rounded border
  static const String borderRounded = '│─╭╮╰╯';
  /// Thick border
  static const String borderThick = '┃━┏┓┗┛';

  // ── braille spinner frames ──

  static const List<String> spinnerFrames = [
    '\u280B', '\u2819', '\u2839', '\u2838',
    '\u283C', '\u2834', '\u2826', '\u2827',
    '\u2807', '\u280F',
  ];

  // ── grapheme break property values ──

  /// ZWJ — zero-width joiner
  static const int graphemePropZwj = 1;
  /// Variation selector
  static const int graphemePropVariationSelector = 2;
  /// Regional indicator (flags)
  static const int graphemePropRegionalIndicator = 3;
  /// Combining mark
  static const int graphemePropCombiningMark = 4;
  /// Emoji modifier (skin tone)
  static const int graphemePropEmojiModifier = 5;
  /// Extended pictographic
  static const int graphemePropExtendedPictographic = 10;
  /// Invisible / format control
  static const int graphemePropInvisible = 11;

  // ── Unicode width constants ──

  /// Width of a wide (CJK / emoji) character
  static const int wideCharWidth = 2;
  /// Width of a zero-width character
  static const int zeroCharWidth = 0;

  // ── signal handler ──

  /// Clean exit code for SIGTERM
  static const int exitCodeOk = 0;
}
