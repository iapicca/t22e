import 'package:protocol/protocol.dart'
    show ControlBytes, SgrCodes, DecModes, OscCodes;

/// Pre-built ANSI escape sequence strings for common terminal operations.
final class AnsiDefaults {
  AnsiDefaults._();

  /// SGR escape sequence to reset all text attributes.
  static const String resetAll = '${ControlBytes.csi}${SgrCodes.sgrReset}m';

  /// CSI to reset both foreground and background colors.
  static const String resetColor =
      '${ControlBytes.csi}${SgrCodes.sgrFgReset};${SgrCodes.sgrBgReset}m';

  /// Hide the terminal cursor.
  static const String hideCursor =
      '${ControlBytes.csi}?${DecModes.decModeCursorVisible}l';

  /// Show the terminal cursor.
  static const String showCursor =
      '${ControlBytes.csi}?${DecModes.decModeCursorVisible}h';

  /// Save the current cursor position.
  static const String saveCursor = '${ControlBytes.csi}s';

  /// Restore the previously saved cursor position.
  static const String restoreCursor = '${ControlBytes.csi}u';

  /// Request the current cursor position from the terminal.
  static const String requestPosition = '${ControlBytes.csi}6n';

  /// Erase the entire visible display.
  static const String eraseScreen =
      '${ControlBytes.csi}${DecModes.eraseDisplayAll}J';

  /// Erase saved lines (scrollback buffer).
  static const String eraseSavedLines =
      '${ControlBytes.csi}${DecModes.eraseDisplaySaved}J';

  /// Erase from cursor to end of line.
  static const String eraseLineToEnd =
      '${ControlBytes.csi}${DecModes.eraseLineRight}K';

  /// Erase from cursor to beginning of line.
  static const String eraseLineToStart =
      '${ControlBytes.csi}${DecModes.eraseLineLeft}K';

  /// Erase the entire current line.
  static const String eraseLineAll =
      '${ControlBytes.csi}${DecModes.eraseLineAll}K';

  /// Enter the alternate screen buffer.
  static const String enterAltScreen =
      '${ControlBytes.csi}?${DecModes.decModeAltScreen}h';

  /// Exit the alternate screen buffer.
  static const String exitAltScreen =
      '${ControlBytes.csi}?${DecModes.decModeAltScreen}l';

  /// Enable normal (X10) mouse tracking.
  static const String enableNormalMouse =
      '${ControlBytes.csi}?${DecModes.decModeMouseNormal}h';

  /// Disable all mouse tracking modes.
  static const String disableMouse =
      '${ControlBytes.csi}?${DecModes.decModeMouseNormal}l'
      '${ControlBytes.csi}?${DecModes.decModeMouseButton}l'
      '${ControlBytes.csi}?${DecModes.decModeMouseSgr}l';

  /// Enable button-event mouse tracking.
  static const String enableButtonEvents =
      '${ControlBytes.csi}?${DecModes.decModeMouseButton}h';

  /// Enable SGR extended mouse reporting.
  static const String enableSgrMouse =
      '${ControlBytes.csi}?${DecModes.decModeMouseSgr}h';

  /// Start a synchronized update batch.
  static const String startSync =
      '${ControlBytes.csi}?${DecModes.decModeSync}h';

  /// End a synchronized update batch.
  static const String endSync = '${ControlBytes.csi}?${DecModes.decModeSync}l';

  /// Enable bracketed paste mode.
  static const String enableBracketedPaste =
      '${ControlBytes.csi}?${DecModes.decModeBracketedPaste}h';

  /// Disable bracketed paste mode.
  static const String disableBracketedPaste =
      '${ControlBytes.csi}?${DecModes.decModeBracketedPaste}l';

  /// Enable focus event tracking.
  static const String enableFocusTracking =
      '${ControlBytes.csi}?${DecModes.decModeFocus}h';

  /// Disable focus event tracking.
  static const String disableFocusTracking =
      '${ControlBytes.csi}?${DecModes.decModeFocus}l';

  /// Disable the Kitty keyboard protocol.
  static const String disableKittyKeyboard = '${ControlBytes.csi}<u';

  /// Query the Kitty keyboard protocol status.
  static const String queryKittyKeyboard = '${ControlBytes.csi}?u';

  /// Query the terminal's default foreground color.
  static const String queryForegroundColor =
      '${ControlBytes.osc}${OscCodes.oscFgQuery};?${ControlBytes.bel}';

  /// Query the terminal's default background color.
  static const String queryBackgroundColor =
      '${ControlBytes.osc}${OscCodes.oscBgQuery};?${ControlBytes.bel}';

  /// Request primary device attributes (DA1).
  static const String queryDa1 = '${ControlBytes.csi}c';

  /// Query synchronized update support via DECRPM.
  static const String querySyncUpdate =
      '${ControlBytes.csi}?${DecModes.decModeSync}\$p';

  /// Soft reset the terminal.
  static const String softReset = '${ControlBytes.csi}!p';

  /// Enable all mouse tracking modes (normal, button-event, SGR).
  static const String enableMouse =
      '${ControlBytes.csi}?${DecModes.decModeMouseNormal}h'
      '${ControlBytes.csi}?${DecModes.decModeMouseButton}h'
      '${ControlBytes.csi}?${DecModes.decModeMouseSgr}h';
}
