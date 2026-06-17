/// Dialog layout and sizing constants.
final class DialogLayout {
  DialogLayout._();

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
}
