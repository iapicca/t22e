/// ESC and SS3 sequence final bytes.
final class EscFinals {
  EscFinals._();

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
}
