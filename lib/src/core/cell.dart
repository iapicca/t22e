import 'style.dart';

/// A single character cell on the terminal grid, with style, width marker, and hyperlink
class Cell {
  /// The character displayed in this cell
  final String char;
  /// The text style attributes for this cell
  final TextStyle style;
  /// True if this cell is a wide-character continuation (no own content)
  final bool wideContinuation;
  /// Optional hyperlink URI for this cell
  final String? hyperlink;

  const Cell({
    this.char = ' ',
    this.style = TextStyle.empty,
    this.wideContinuation = false,
    this.hyperlink,
  });

  /// Creates a copy with optionally replaced fields
  Cell copyWith({String? char, TextStyle? style, bool? wideContinuation, String? hyperlink}) {
    return Cell(
      char: char ?? this.char,
      style: style ?? this.style,
      wideContinuation: wideContinuation ?? this.wideContinuation,
      hyperlink: hyperlink ?? this.hyperlink,
    );
  }

  /// Returns a new cell with style attributes merged from the override
  Cell mergeStyle(TextStyle override) {
    final merged = style.merge(override);
    if (identical(merged, style)) return this;
    return Cell(char: char, style: merged, wideContinuation: wideContinuation, hyperlink: hyperlink);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cell &&
          char == other.char &&
          style == other.style &&
          wideContinuation == other.wideContinuation &&
          hyperlink == other.hyperlink);

  @override
  int get hashCode => Object.hash(char, style, wideContinuation, hyperlink);

  @override
  String toString() => 'Cell($char, ${wideContinuation ? "cont" : "lead"}${hyperlink != null ? ', link=$hyperlink' : ''})';
}
