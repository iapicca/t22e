import 'color.dart';
import '../well_known.dart' show WellKnown;

/// Terminal text style attributes: colors, decorations, and layout hints
class TextStyle {
  /// Foreground color, or null for default
  final Color? foreground;
  /// Background color, or null for default
  final Color? background;

  /// Bold text
  final bool? bold;
  /// Dim/faint text
  final bool? dim;
  /// Italic text
  final bool? italic;
  /// Underlined text
  final bool? underline;
  /// Blinking text
  final bool? blink;
  /// Reverse video (swap fg/bg)
  final bool? reverse;
  /// Strikethrough text
  final bool? strikethrough;
  /// Overlined text
  final bool? overline;

  /// Preferred width in columns, or null for auto
  final int? width;
  /// Preferred height in rows, or null for auto
  final int? height;
  /// Whether text should wrap to the next line
  final bool? wordWrap;

  const TextStyle({
    this.foreground,
    this.background,
    this.bold,
    this.dim,
    this.italic,
    this.underline,
    this.blink,
    this.reverse,
    this.strikethrough,
    this.overline,
    this.width,
    this.height,
    this.wordWrap,
  });

  /// An empty style with all attributes null (clear)
  static const empty = TextStyle();

  /// Whether all style attributes are null (no styling)
  bool get isClear =>
      foreground == null &&
      background == null &&
      bold == null &&
      dim == null &&
      italic == null &&
      underline == null &&
      blink == null &&
      reverse == null &&
      strikethrough == null &&
      overline == null &&
      width == null &&
      height == null &&
      wordWrap == null;

  /// Merges another style on top, with other taking precedence for non-null values
  TextStyle merge(TextStyle other) {
    if (other.isClear) return this;
    if (isClear) return other;
    return TextStyle(
      foreground: other.foreground ?? foreground,
      background: other.background ?? background,
      bold: other.bold ?? bold,
      dim: other.dim ?? dim,
      italic: other.italic ?? italic,
      underline: other.underline ?? underline,
      blink: other.blink ?? blink,
      reverse: other.reverse ?? reverse,
      strikethrough: other.strikethrough ?? strikethrough,
      overline: other.overline ?? overline,
      width: other.width ?? width,
      height: other.height ?? height,
      wordWrap: other.wordWrap ?? wordWrap,
    );
  }

  /// Converts colors to match the target color profile
  TextStyle resolveColor(ColorProfile profile) {
    if (foreground == null && background == null) return this;
    final target = _profileToKind(profile);
    final fg = foreground?.convert(target);
    final bg = background?.convert(target);
    if (identical(fg, foreground) && identical(bg, background)) return this;
    return TextStyle(
      foreground: fg,
      background: bg,
      bold: bold,
      dim: dim,
      italic: italic,
      underline: underline,
      blink: blink,
      reverse: reverse,
      strikethrough: strikethrough,
      overline: overline,
      width: width,
      height: height,
      wordWrap: wordWrap,
    );
  }

  static ColorKind _profileToKind(ColorProfile profile) {
    switch (profile) {
      case ColorProfile.noColor:
        return ColorKind.noColor;
      case ColorProfile.ansi16:
        return ColorKind.ansi;
      case ColorProfile.indexed256:
        return ColorKind.indexed;
      case ColorProfile.trueColor:
        return ColorKind.rgb;
    }
  }

  /// Inherits from a parent style: parent's null values fall through to child
  TextStyle inherit(TextStyle parent) {
    if (parent.isClear) return this;
    return TextStyle(
      foreground: foreground ?? parent.foreground,
      background: background ?? parent.background,
      bold: bold ?? parent.bold,
      dim: dim ?? parent.dim,
      italic: italic ?? parent.italic,
      underline: underline ?? parent.underline,
      blink: blink ?? parent.blink,
      reverse: reverse ?? parent.reverse,
      strikethrough: strikethrough ?? parent.strikethrough,
      overline: overline ?? parent.overline,
      width: width ?? parent.width,
      height: height ?? parent.height,
      wordWrap: wordWrap ?? parent.wordWrap,
    );
  }

  /// Factory: default link style (blue, underlined)
  factory TextStyle.link({String? uri}) {
    return TextStyle(
      foreground: const Color.rgb(WellKnown.linkColorRed, WellKnown.linkColorGreen, WellKnown.linkColorBlue),
      underline: true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TextStyle &&
          foreground == other.foreground &&
          background == other.background &&
          bold == other.bold &&
          dim == other.dim &&
          italic == other.italic &&
          underline == other.underline &&
          blink == other.blink &&
          reverse == other.reverse &&
          strikethrough == other.strikethrough &&
          overline == other.overline &&
          width == other.width &&
          height == other.height &&
          wordWrap == other.wordWrap);

  @override
  int get hashCode =>
      Object.hash(foreground, background, bold, dim, italic, underline, blink, reverse,
          strikethrough, overline, width, height, wordWrap);

  @override
  String toString() => 'TextStyle(${_describe()})';

  String _describe() {
    final parts = <String>[];
    if (foreground != null) parts.add('fg:$foreground');
    if (background != null) parts.add('bg:$background');
    if (bold == true) parts.add('bold');
    if (italic == true) parts.add('italic');
    if (underline == true) parts.add('underline');
    if (dim == true) parts.add('dim');
    if (blink == true) parts.add('blink');
    if (reverse == true) parts.add('reverse');
    if (strikethrough == true) parts.add('strikethrough');
    if (overline == true) parts.add('overline');
    return parts.isEmpty ? 'clear' : parts.join(' ');
  }
}
