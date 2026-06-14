/// Internal event kind string constants.
final class InternalEvents {
  InternalEvents._();

  /// Internal event kind for terminal reset.
  static const String internalEventReset = 'reset';

  /// Internal event kind for screen save.
  static const String internalEventScreenSave = 'screen_save';

  /// Internal event kind for screen restore.
  static const String internalEventScreenRestore = 'screen_restore';

  /// Internal event kind for scroll reverse.
  static const String internalEventScrollReverse = 'scroll_reverse';

  /// Internal event kind for Kitty graphics.
  static const String internalEventKittyGraphics = 'kitty_graphics';
}
