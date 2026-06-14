/// CSI sequence final bytes for cursor, display, mode, and input events.
final class CsiFinals {
  CsiFinals._();

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

  /// 'c' final byte for device attributes (DA1).
  static const int csiFinalDA = 0x63;

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

  /// '<' intermediate for extended CSI (SGR mouse etc.).
  static const int csiExtendedIntermediate = 0x3C;

  /// '>' intermediate for Kitty keyboard queries.
  static const int csiKittyQueryIntermediate = 0x3E;

  /// '$' intermediate for DEC sequences.
  static const int csiDecDollar = 0x24;
}
