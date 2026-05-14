/// Central repository of all terminal protocol constants and escape codes.
final class Defaults {
  Defaults._();

  // ── C0 control bytes ──

  /// ESC control byte.
  static const int escapeByte = 0x1B;
  /// BEL (bell) control byte.
  static const int bellByte = 0x07;
  /// CR (carriage return) control byte.
  static const int carriageReturnByte = 0x0D;
  /// LF (line feed) control byte.
  static const int lineFeedByte = 0x0A;

  // ── C1 8-bit control bytes ──

  /// ST (string terminator) byte.
  static const int stringTerminatorByte = 0x9C;
  /// CSI introducer byte (8-bit form).
  static const int csiIntroducerByte = 0x9B;
  /// OSC introducer byte (8-bit form).
  static const int oscIntroducerByte = 0x9D;
  /// DCS introducer byte (8-bit form).
  static const int dcsIntroducerByte = 0x90;
  /// SOS introducer byte.
  static const int sosIntroducerByte = 0x98;
  /// PM introducer byte.
  static const int pmIntroducerByte = 0x9E;
  /// APC introducer byte.
  static const int apcIntroducerByte = 0x9F;

  // ── escape sequence introducer strings ──

  /// ESC character string.
  static const String esc = '\x1b';
  /// CSI sequence prefix string.
  static const String csi = '\x1b[';
  /// OSC sequence prefix string.
  static const String osc = '\x1b]';
  /// DCS sequence prefix string.
  static const String dcs = '\x1bP';
  /// String terminator sequence.
  static const String st = '\x1b\\';
  /// BEL character string.
  static const String bel = '\x07';

  // ── 7-bit escape sequence entry bytes ──

  /// '[' byte that starts a CSI sequence.
  static const int csiEntryByte = 0x5B;
  /// ']' byte that starts an OSC sequence.
  static const int oscEntryByte = 0x5D;
  /// 'P' byte that starts a DCS sequence.
  static const int dcsEntryByte = 0x50;
  /// '\' byte that ends a DCS sequence.
  static const int dcsStByte = 0x5C;
  /// 'O' byte that starts an SS3 sequence.
  static const int ss3Byte = 0x4F;
  /// '?' prefix for DEC private parameters.
  static const int decPrivatePrefix = 0x3F;

  // ── byte classification ranges ──

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

  // ── parameter delimiters ──

  /// Semicolon byte separating CSI parameters.
  static const int semicolonByte = 0x3B;
  /// '<' byte prefixing extended CSI intermediate.
  static const int intermediatePrefixByte = 0x3C;

  // ── SGR (Select Graphic Rendition) parameter values ──

  /// Reset all SGR attributes.
  static const int sgrReset = 0;
  /// Bold / increased intensity.
  static const int sgrBold = 1;
  /// Faint / decreased intensity.
  static const int sgrFaint = 2;
  /// Italicized text.
  static const int sgrItalic = 3;
  /// Underlined text.
  static const int sgrUnderline = 4;
  /// Blinking text.
  static const int sgrBlink = 5;
  /// Reverse/inverse video.
  static const int sgrReverse = 7;
  /// Strikethrough text.
  static const int sgrStrikethrough = 9;
  /// Overlined text.
  static const int sgrOverline = 53;
  /// Turn off bold and faint.
  static const int sgrNoBoldFaint = 22;
  /// Turn off italic.
  static const int sgrNoItalic = 23;
  /// Turn off underline.
  static const int sgrNoUnderline = 24;
  /// Turn off blink.
  static const int sgrNoBlink = 25;
  /// Turn off reverse.
  static const int sgrNoReverse = 27;
  /// Turn off strikethrough.
  static const int sgrNoStrikethrough = 29;
  /// Turn off overline.
  static const int sgrNoOverline = 55;

  // ── ANSI color SGR base codes ──

  /// Foreground ANSI 16-color base index.
  static const int sgrFgAnsiBase = 30;
  /// Background ANSI 16-color base index.
  static const int sgrBgAnsiBase = 40;
  /// Foreground bright ANSI base index.
  static const int sgrFgBrightBase = 90;
  /// Background bright ANSI base index.
  static const int sgrBgBrightBase = 100;
  /// Extended foreground color prefix.
  static const int sgrFgExtended = 38;
  /// Extended background color prefix.
  static const int sgrBgExtended = 48;
  /// Reset foreground to default.
  static const int sgrFgReset = 39;
  /// Reset background to default.
  static const int sgrBgReset = 49;
  /// Indexed 256-color selector for extended sequences.
  static const int sgrColor256 = 5;
  /// RGB color selector for extended sequences.
  static const int sgrColorRgb = 2;

  // ── SGR final byte ──

  /// 'm' byte terminating an SGR sequence.
  static const int csiFinalSgr = 0x6D;

  // ── CSI final bytes (cursor, display, modes) ──

  /// 'A' final byte for cursor up.
  static const int csiFinalUp = 0x41;
  /// 'B' final byte for cursor down.
  static const int csiFinalDown = 0x42;
  /// 'C' final byte for cursor right.
  static const int csiFinalRight = 0x43;
  /// 'D' final byte for cursor left.
  static const int csiFinalLeft = 0x44;
  /// 'H' final byte for cursor position (CUP).
  static const int csiFinalCup = 0x48;
  /// 'H' final byte for cursor home.
  static const int csiFinalHome = 0x48;
  /// 'F' final byte for cursor end.
  static const int csiFinalEnd = 0x46;
  /// 'G' final byte for cursor horizontal absolute.
  static const int csiFinalCha = 0x47;
  /// 'J' final byte for erase display.
  static const int csiFinalEd = 0x4A;
  /// 'K' final byte for erase line.
  static const int csiFinalEl = 0x4B;
  /// 'h' final byte for DEC private mode set.
  static const int csiFinalDecset = 0x68;
  /// 'l' final byte for DEC private mode reset.
  static const int csiFinalDecrst = 0x6C;
  /// 's' final byte for save cursor.
  static const int csiFinalSaveCursor = 0x73;
  /// 'u' final byte for restore cursor.
  static const int csiFinalRestoreCursor = 0x75;
  /// 'n' final byte for device status report.
  static const int csiFinalDsr = 0x6E;
  /// 'c' final byte for device attributes (DA1).
  static const int csiFinalDA = 0x63;

  // ── CSI final bytes (input events) ──

  /// 'P' final byte for F1 key.
  static const int csiFinalF1 = 0x50;
  /// 'Q' final byte for F2 key.
  static const int csiFinalF2 = 0x51;
  /// 'R' final byte for cursor position report.
  static const int csiFinalCursorPos = 0x52;
  /// 'S' final byte for F4 key.
  static const int csiFinalF4 = 0x53;
  /// '~' final byte for extended function keys.
  static const int csiFinalTilde = 0x7E;
  /// 'M' final byte for mouse events.
  static const int csiFinalMouse = 0x4D;

  // ── CSI intermediate bytes ──

  /// '<' intermediate for extended CSI (SGR mouse etc.).
  static const int csiExtendedIntermediate = 0x3C;
  /// '>' intermediate for Kitty keyboard queries.
  static const int csiKittyQueryIntermediate = 0x3E;
  /// '$' intermediate for DEC sequences.
  static const int csiDecDollar = 0x24;

  // ── CSI final byte for Kitty keyboard ──

  /// 'u' final byte for Kitty keyboard events.
  static const int csiFinalKittyKey = 0x75;

  // ── ESC sequence final bytes ──

  /// 'c' final byte for RIS (reset to initial state).
  static const int escFinalReset = 0x63;
  /// '7' final byte for save cursor (DECSC).
  static const int escFinalSaveCursor = 0x37;
  /// '8' final byte for restore cursor (DECRC).
  static const int escFinalRestoreCursor = 0x38;
  /// 'M' final byte for reverse index.
  static const int escFinalScrollReverse = 0x4D;
  /// SS3 'P' final byte for F1 key.
  static const int escSs3F1 = 0x50;
  /// SS3 'Q' final byte for F2 key.
  static const int escSs3F2 = 0x51;
  /// SS3 'R' final byte for F3 key.
  static const int escSs3F3 = 0x52;
  /// SS3 'S' final byte for F4 key.
  static const int escSs3F4 = 0x53;

  // ── DCS final / intermediate bytes ──

  /// 'p' DCS final byte for Kitty graphics transmission.
  static const int dcsKittyGraphicsP = 0x70;
  /// 'q' DCS final byte for Kitty graphics query.
  static const int dcsKittyGraphicsQ = 0x71;
  /// '+' intermediate byte for Kitty DCS sequences.
  static const int dcsKittyIntermediate = 0x2B;

  // ── OSC PSN (parameter sub-number) codes ──

  /// OSC 0: set window and icon title.
  static const int oscTitle = 0;
  /// OSC 8: hyperlink specification.
  static const int oscHyperlink = 8;
  /// OSC 10: query/set foreground color.
  static const int oscFgQuery = 10;
  /// OSC 11: query/set background color.
  static const int oscBgQuery = 11;
  /// OSC 52: clipboard read/write.
  static const int oscClipboard = 52;

  // ── modifier bit masks ──

  /// Shift key modifier bit.
  static const int modShift = 1;
  /// Alt key modifier bit.
  static const int modAlt = 2;
  /// Ctrl key modifier bit.
  static const int modCtrl = 4;
  /// Meta/Super key modifier bit.
  static const int modMeta = 8;

  // ── mouse parsing ──

  /// Encoded value for mouse wheel up.
  static const int mouseWheelUpCode = 64;
  /// Encoded value for mouse wheel down.
  static const int mouseWheelDownCode = 65;
  /// Mouse motion/drag indicator bit.
  static const int mouseDragBit = 32;
  /// Bitmask for extracting mouse button number.
  static const int mouseButtonMask = 3;
  /// Button code for mouse left click.
  static const int mouseButtonLeft = 0;
  /// Button code for mouse middle click.
  static const int mouseButtonMiddle = 1;
  /// Button code for mouse right click.
  static const int mouseButtonRight = 2;

  // ── Kitty keyboard protocol ──

  /// Kitty flag: disambiguate keys.
  static const int kittyDisambiguate = 1;
  /// Kitty flag: report all events.
  static const int kittyAllEvents = 3;
  /// Kitty event type: key release.
  static const int kittyEventUp = 2;
  /// Kitty event type: key repeat.
  static const int kittyEventRepeat = 3;

  // ── Kitty key code map bytes ──

  /// Kitty key code for Escape.
  static const int kittyKeyEscape = 0x1B;
  /// Kitty key code for Tab.
  static const int kittyKeyTab = 0x09;
  /// Kitty key code for Enter.
  static const int kittyKeyEnter = 0x0D;
  /// Kitty key code for Backspace.
  static const int kittyKeyBackspace = 0x08;
  /// Kitty alternate key code for Backspace.
  static const int kittyKeyBackspaceAlt = 0x7F;
  /// Kitty key code for Home.
  static const int kittyKeyHome = 0x01;
  /// Kitty key code for End.
  static const int kittyKeyEnd = 0x04;
  /// Kitty key code for Page Up.
  static const int kittyKeyPageUp = 0x05;
  /// Kitty key code for Page Down.
  static const int kittyKeyPageDown = 0x06;
  /// Kitty key code for Insert.
  static const int kittyKeyInsert = 0x02;
  /// Kitty key code for Delete.
  static const int kittyKeyDelete = 0x03;
  /// Kitty alternate key code for Delete.
  static const int kittyKeyDeleteAlt = 0x1A;

  // ── DEC private mode numbers ──

  /// DECSET/DECRST mode: normal mouse tracking (X10).
  static const int decModeMouseNormal = 1000;
  /// DECSET/DECRST mode: button-event tracking.
  static const int decModeMouseButton = 1002;
  /// DECSET/DECRST mode: SGR extended mouse.
  static const int decModeMouseSgr = 1006;
  /// DECSET/DECRST mode: focus tracking.
  static const int decModeFocus = 1004;
  /// DECSET/DECRST mode: bracketed paste.
  static const int decModeBracketedPaste = 2004;
  /// DECSET/DECRST mode: synchronized updates.
  static const int decModeSync = 2026;
  /// DECSET/DECRST mode: alternate screen buffer.
  static const int decModeAltScreen = 1049;
  /// DECSET/DECRST mode: cursor visibility.
  static const int decModeCursorVisible = 25;

  // ── cursor style values ──

  /// Blinking block cursor shape.
  static const int cursorStyleBlinkingBlock = 1;
  /// Steady block cursor shape.
  static const int cursorStyleSteadyBlock = 2;
  /// Blinking underline cursor shape.
  static const int cursorStyleBlinkingUnderline = 3;
  /// Steady underline cursor shape.
  static const int cursorStyleSteadyUnderline = 4;
  /// Blinking bar cursor shape.
  static const int cursorStyleBlinkingBar = 5;
  /// Steady bar cursor shape.
  static const int cursorStyleSteadyBar = 6;

  // ── erase display modes ──

  /// Erase from cursor to end of display.
  static const int eraseDisplayBelow = 0;
  /// Erase from cursor to beginning of display.
  static const int eraseDisplayAbove = 1;
  /// Erase entire display.
  static const int eraseDisplayAll = 2;
  /// Erase saved lines (scrollback).
  static const int eraseDisplaySaved = 3;

  // ── erase line modes ──

  /// Erase from cursor to end of line.
  static const int eraseLineRight = 0;
  /// Erase from cursor to beginning of line.
  static const int eraseLineLeft = 1;
  /// Erase entire line.
  static const int eraseLineAll = 2;

  // ── DA1 (device attributes) ──

  /// Default DA1 response (no attributes).
  static const int da1TerminalIdDefault = 0;
  /// DA1 attribute: 256-color support.
  static const int da1AttrIndexed256 = 22;
  /// DA1 attribute: truecolor support.
  static const int da1AttrTrueColor = 28;

  // ── color profiles ──

  /// Total standard ANSI 16 colors.
  static const int colorProfileAnsiCount = 16;
  /// Total indexed 256-color palette entries.
  static const int colorProfileIndexedCount = 256;
  /// Starting index of the 6x6x6 color cube.
  static const int indexedColorCubeStart = 16;
  /// Size of one dimension of the color cube.
  static const int indexedColorCubeSize = 6;
  /// Starting index of the grayscale ramp.
  static const int indexedColorGrayStart = 232;
  /// Number of grayscale ramp entries.
  static const int indexedColorGrayCount = 24;
  /// Offset from standard to bright ANSI SGR param.
  static const int ansiBrightOffset = 60;
  /// Maximum valid ANSI color index.
  static const int ansiColorMax = 15;
  /// Threshold below which ANSI colors are "dark".
  static const int ansiDarkThreshold = 8;

  // ── default link color (RGB) ──

  /// Red component of default link color.
  static const int linkColorRed = 0;
  /// Green component of default link color.
  static const int linkColorGreen = 102;
  /// Blue component of default link color.
  static const int linkColorBlue = 204;

  // ── RGB color composition ──

  /// Maximum value for an RGB component.
  static const int rgbComponentMax = 255;
  /// Bit shift for red component in packed RGB.
  static const int rgbRedShift = 16;
  /// Bit shift for green component in packed RGB.
  static const int rgbGreenShift = 8;
  /// Mask for extracting blue component from packed RGB.
  static const int rgbBlueMask = 0xFF;

  // ── byte bit operations ──

  /// 8-bit shift value.
  static const int bitShift8 = 8;
  /// 16-bit shift value.
  static const int bitShift16 = 16;
  /// 24-bit shift value.
  static const int bitShift24 = 24;
  /// Mask for extracting a single byte.
  static const int byteMask = 0xFF;

  // ── termios local mode flags ──

  /// ECHO flag: enable input echo.
  static const int termiosEcho = 0x00000008;
  /// ICANON flag: canonical (line) mode.
  static const int termiosICanon = 0x00000002;
  /// ISIG flag: signal handling (SIGINT etc.).
  static const int termiosISig = 0x00000001;
  /// IEXTEN flag: extended input processing.
  static const int termiosIExten = 0x00008000;

  // ── termios struct layout ──

  /// Size of termios struct in bytes (on most platforms).
  static const int termiosStructSize = 60;
  /// Byte offset of c_iflag in termios struct.
  static const int termiosOffsetIFlag = 0;
  /// Byte offset of c_oflag in termios struct.
  static const int termiosOffsetOFlag = 4;
  /// Byte offset of c_cflag in termios struct.
  static const int termiosOffsetCFlag = 8;
  /// Byte offset of c_lflag in termios struct.
  static const int termiosOffsetLFlag = 12;
  /// Byte offset of VMIN in c_cc array.
  static const int termiosOffsetCCMin = 17;
  /// Byte offset of VTIME in c_cc array.
  static const int termiosOffsetCCTime = 18;
  /// Value for VMIN in raw mode (read at least 1 byte).
  static const int termiosVminRaw = 1;
  /// Value for VTIME in raw mode (no timeout).
  static const int termiosVtimeRaw = 0;

  // ── tcsetattr action ──

  /// TCSANOW: apply termios changes immediately.
  static const int tcsaNow = 0;

  // ── standard file descriptors ──

  /// File descriptor for stdin.
  static const int stdinFd = 0;

  // ── libc library names ──

  /// macOS system library path for FFI.
  static const String libcMacOS = 'libSystem.dylib';
  /// Linux libc path (glibc 6).
  static const String libcLinux6 = 'libc.so.6';
  /// Linux libc path (glibc 7).
  static const String libcLinux7 = 'libc.so.7';

  // ── environment string constants ──

  /// COLORTERM value indicating truecolor support.
  static const String envColortermTruecolor = 'truecolor';
  /// COLORTERM value indicating 24-bit support.
  static const String envColorterm24bit = '24bit';
  /// TERM suffix indicating 256-color terminal.
  static const String envTermSuffix256Color = '-256color';
  /// TERM suffix indicating truecolor terminal.
  static const String envTermSuffixTrueColor = '-truecolor';
  /// TERM suffix indicating direct color terminal.
  static const String envTermSuffixDirect = '-direct';

  // ── timing / duration defaults ──

  /// Delay before processing an ESC as standalone.
  static const Duration escDisambiguationDelay = Duration(milliseconds: 10);
  /// Sleep duration in the event loop to prevent busy-wait.
  static const Duration eventLoopSleep = Duration(milliseconds: 1);
  /// Default timeout for capability probes.
  static const Duration defaultProbeTimeout = Duration(seconds: 1);
  /// Animation interval for spinner frames.
  static const Duration spinnerAnimInterval = Duration(milliseconds: 80);
  /// Animation interval for progress bar frames.
  static const Duration progressAnimInterval = Duration(milliseconds: 100);
  /// Blink interval for the text input cursor.
  static const Duration cursorBlinkInterval = Duration(milliseconds: 500);

  // ── rendering / FPS ──

  /// Default frames per second for rendering.
  static const int defaultFps = 60;
  /// Number of microseconds in one second.
  static const int microsecondsPerSecond = 1000000;

  // ── default terminal / viewport sizes ──

  /// Default terminal width in columns.
  static const int defaultTerminalWidth = 80;
  /// Default terminal height in rows.
  static const int defaultTerminalHeight = 24;
  /// Default viewport height for scrollable widgets.
  static const int defaultViewportHeight = 10;
  /// Default scroll distance in lines per step.
  static const int defaultScrollStep = 3;
  /// Default width of a progress bar in cells.
  static const int defaultProgressBarWidth = 20;
  /// Minimum viewport height for the scrollbar thumb.
  static const int scrollbarMinViewportHeight = 2;

  // ── dialog layout ──

  /// Dialog width as fraction of terminal width.
  static const double dialogWidthRatio = 0.6;
  /// Dialog height as fraction of terminal height.
  static const double dialogHeightRatio = 0.4;
  /// Minimum dialog width in columns.
  static const int dialogMinWidth = 20;
  /// Minimum dialog height in rows.
  static const int dialogMinHeight = 5;
  /// Horizontal margin inside dialog border.
  static const int dialogHMargin = 4;
  /// Height of the button bar area in dialogs.
  static const int dialogButtonBarHeight = 3;
  /// Maximum clamped content height in dialogs.
  static const int dialogContentClampHigh = 100;

  // ── text input ──

  /// Sentinel value meaning no max length for text input.
  static const int textInputNoMaxLength = -1;

  // ── layout / geometry sentinels ──

  /// Sentinel value representing unbounded/infinite size.
  static const int unbounded = 0x7FFFFFFF;

  // ── Unicode codepoints (control / whitespace) ──

  /// Space character codepoint.
  static const int codepointSpace = 0x20;
  /// DEL (delete) control character.
  static const int codepointDel = 0x7F;
  /// Ideographic space codepoint (CJK fullwidth space).
  static const int codepointIdeographicSpace = 0x3000;
  /// Zero-width joiner (ZWJ) codepoint.
  static const int codepointZwj = 0x200D;

  // ── Unicode box-drawing / UI glyphs ──

  /// Full block character for solid fill.
  static const String charFullBlock = '\u2588';
  /// Light shade character for partial fill.
  static const String charLightShade = '\u2591';
  /// Bullet character for lists.
  static const String charBullet = '\u2022';
  /// Check mark character.
  static const String charCheckMark = '\u2713';
  /// Right-pointing triangle for sort indicators.
  static const String charRightTriangle = '\u25B6';
  /// Up-pointing triangle for sort indicators.
  static const String charUpTriangle = '\u25B2';
  /// Down-pointing triangle for sort indicators.
  static const String charDownTriangle = '\u25BC';

  // ── border glyph sets ──

  /// Single-line border characters (vertical, horizontal, TL, TR, BL, BR).
  static const String borderSingle = '│─┌┐└┘';
  /// Double-line border characters.
  static const String borderDouble = '║═╔╗╚╝';
  /// Rounded-corner border characters.
  static const String borderRounded = '│─╭╮╰╯';
  /// Heavy/thick border characters.
  static const String borderThick = '┃━┏┓┗┛';

  // ── braille spinner frames ──

  /// Braille pattern frames for the spinner animation.
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
  /// Grapheme break property: extended pictographic.
  static const int graphemePropExtendedPictographic = 10;
  /// Grapheme break property: invisible character.
  static const int graphemePropInvisible = 11;

  // ── Unicode width constants ──

  /// Width in columns for a wide (CJK) character.
  static const int wideCharWidth = 2;
  /// Width in columns for zero-width characters.
  static const int zeroCharWidth = 0;

  // ── signal handler ──

  /// Standard successful exit code.
  static const int exitCodeOk = 0;
}
