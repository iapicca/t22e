import 'style.dart';

class Cell {
  final String char;
  final TextStyle style;
  final bool wideContinuation;

  const Cell({
    this.char = ' ',
    this.style = TextStyle.empty,
    this.wideContinuation = false,
  });

  Cell copyWith({String? char, TextStyle? style, bool? wideContinuation}) {
    return Cell(
      char: char ?? this.char,
      style: style ?? this.style,
      wideContinuation: wideContinuation ?? this.wideContinuation,
    );
  }

  Cell mergeStyle(TextStyle override) {
    final merged = style.merge(override);
    if (identical(merged, style)) return this;
    return Cell(char: char, style: merged, wideContinuation: wideContinuation);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cell &&
          char == other.char &&
          style == other.style &&
          wideContinuation == other.wideContinuation);

  @override
  int get hashCode => Object.hash(char, style, wideContinuation);

  @override
  String toString() => 'Cell($char, ${wideContinuation ? "cont" : "lead"})';
}
