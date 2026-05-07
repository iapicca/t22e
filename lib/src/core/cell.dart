import 'style.dart';

class Cell {
  final String char;
  final TextStyle style;
  final bool wideContinuation;
  final String? hyperlink;

  const Cell({
    this.char = ' ',
    this.style = TextStyle.empty,
    this.wideContinuation = false,
    this.hyperlink,
  });

  Cell copyWith({String? char, TextStyle? style, bool? wideContinuation, String? hyperlink}) {
    return Cell(
      char: char ?? this.char,
      style: style ?? this.style,
      wideContinuation: wideContinuation ?? this.wideContinuation,
      hyperlink: hyperlink ?? this.hyperlink,
    );
  }

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
