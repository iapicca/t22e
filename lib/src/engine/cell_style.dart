/// Style flags that can be applied to a terminal cell.
enum CellStyle {
  /// Bold text.
  bold,

  /// Italic text.
  italic,

  /// Underlined text.
  underline,

  /// Inverse foreground and background.
  inverse,

  /// Continuation cell for a wide (2-cell) glyph.
  ///
  /// Internal layout metadata: marks the second cell occupied by a wide
  /// character so the diff engine and ANSI writer skip it. Never emitted as
  /// an SGR parameter.
  continuation,
}
