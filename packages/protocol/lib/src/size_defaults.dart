/// Default terminal, viewport, widget, and layout size constants.
final class SizeDefaults {
  SizeDefaults._();

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

  /// Sentinel value representing unbounded/infinite size.
  static const int unbounded = 0x7FFFFFFF;
}
