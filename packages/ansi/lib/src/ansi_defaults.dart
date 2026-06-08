import 'package:protocol/protocol.dart' show Defaults;

/// Pre-built ANSI escape sequence strings for common terminal operations.
final class AnsiDefaults {
  AnsiDefaults._();

  /// SGR escape sequence to reset all text attributes.
  static const String resetAll = '${Defaults.csi}${Defaults.sgrReset}m';

  /// CSI to reset both foreground and background colors.
  static const String resetColor = '${Defaults.csi}${Defaults.sgrFgReset};${Defaults.sgrBgReset}m';

  /// Hide the terminal cursor.
  static const String hideCursor = '${Defaults.csi}?${Defaults.decModeCursorVisible}l';

  /// Show the terminal cursor.
  static const String showCursor = '${Defaults.csi}?${Defaults.decModeCursorVisible}h';

  /// Save the current cursor position.
  static const String saveCursor = '${Defaults.csi}s';

  /// Restore the previously saved cursor position.
  static const String restoreCursor = '${Defaults.csi}u';

  /// Request the current cursor position from the terminal.
  static const String requestPosition = '${Defaults.csi}6n';

  /// Erase the entire visible display.
  static const String eraseScreen = '${Defaults.csi}${Defaults.eraseDisplayAll}J';

  /// Erase saved lines (scrollback buffer).
  static const String eraseSavedLines = '${Defaults.csi}${Defaults.eraseDisplaySaved}J';

  /// Erase from cursor to end of line.
  static const String eraseLineToEnd = '${Defaults.csi}${Defaults.eraseLineRight}K';

  /// Erase from cursor to beginning of line.
  static const String eraseLineToStart = '${Defaults.csi}${Defaults.eraseLineLeft}K';

  /// Erase the entire current line.
  static const String eraseLineAll = '${Defaults.csi}${Defaults.eraseLineAll}K';

  /// Enter the alternate screen buffer.
  static const String enterAltScreen = '${Defaults.csi}?${Defaults.decModeAltScreen}h';

  /// Exit the alternate screen buffer.
  static const String exitAltScreen = '${Defaults.csi}?${Defaults.decModeAltScreen}l';

  /// Enable normal (X10) mouse tracking.
  static const String enableNormalMouse = '${Defaults.csi}?${Defaults.decModeMouseNormal}h';

  /// Disable all mouse tracking modes.
  static const String disableMouse =
      '${Defaults.csi}?${Defaults.decModeMouseNormal}l'
      '${Defaults.csi}?${Defaults.decModeMouseButton}l'
      '${Defaults.csi}?${Defaults.decModeMouseSgr}l';

  /// Enable button-event mouse tracking.
  static const String enableButtonEvents = '${Defaults.csi}?${Defaults.decModeMouseButton}h';

  /// Enable SGR extended mouse reporting.
  static const String enableSgrMouse = '${Defaults.csi}?${Defaults.decModeMouseSgr}h';

  /// Start a synchronized update batch.
  static const String startSync = '${Defaults.csi}?${Defaults.decModeSync}h';

  /// End a synchronized update batch.
  static const String endSync = '${Defaults.csi}?${Defaults.decModeSync}l';

  /// Enable bracketed paste mode.
  static const String enableBracketedPaste = '${Defaults.csi}?${Defaults.decModeBracketedPaste}h';

  /// Disable bracketed paste mode.
  static const String disableBracketedPaste = '${Defaults.csi}?${Defaults.decModeBracketedPaste}l';

  /// Enable focus event tracking.
  static const String enableFocusTracking = '${Defaults.csi}?${Defaults.decModeFocus}h';

  /// Disable focus event tracking.
  static const String disableFocusTracking = '${Defaults.csi}?${Defaults.decModeFocus}l';

  /// Disable the Kitty keyboard protocol.
  static const String disableKittyKeyboard = '${Defaults.csi}<u';

  /// Query the Kitty keyboard protocol status.
  static const String queryKittyKeyboard = '${Defaults.csi}?u';

  /// Query the terminal's default foreground color.
  static const String queryForegroundColor = '${Defaults.osc}${Defaults.oscFgQuery};?${Defaults.bel}';

  /// Query the terminal's default background color.
  static const String queryBackgroundColor = '${Defaults.osc}${Defaults.oscBgQuery};?${Defaults.bel}';

  /// Request primary device attributes (DA1).
  static const String queryDa1 = '${Defaults.csi}c';

  /// Query synchronized update support via DECRPM.
  static const String querySyncUpdate = '${Defaults.csi}?${Defaults.decModeSync}\$p';

  /// Soft reset the terminal.
  static const String softReset = '${Defaults.csi}!p';

  /// Enable all mouse tracking modes (normal, button-event, SGR).
  static const String enableMouse =
      '${Defaults.csi}?${Defaults.decModeMouseNormal}h'
      '${Defaults.csi}?${Defaults.decModeMouseButton}h'
      '${Defaults.csi}?${Defaults.decModeMouseSgr}h';
}
