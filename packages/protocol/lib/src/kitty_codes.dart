/// Kitty keyboard protocol constants and key code mappings.
final class KittyCodes {
  KittyCodes._();

  /// Kitty flag: disambiguate keys.
  static const int kittyDisambiguate = 1;

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

  /// 'u' final byte for Kitty keyboard events.
  static const int csiFinalKittyKey = 0x75;
}
