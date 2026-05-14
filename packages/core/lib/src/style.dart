import 'color.dart';
import 'package:protocol/protocol.dart' show Defaults;

/// Text styling with SGR attributes (bold, italic, underline, etc.) and colors.
class TextStyle {
  /// Foreground color (null = inherit).
  final Color? foreground;
  /// Background color (null = inherit).
  final Color? background;

  /// Bold.
  final bool? bold;
  /// Dim/faint.
  final bool? dim;
  /// Italic.
  final bool? italic;
  /// Underline.
  final bool? underline;
  /// Blink.
  final bool? blink;
  /// Reverse video.
  final bool? reverse;
  /// Strikethrough.
  final bool? strikethrough;
  /// Overline.
  final bool? overline;

  /// Forced width hint.
  final int? width;
  /// Forced height hint.
  final int? height;
  /// Word wrap flag for layout.
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

  /// An empty text style with all fields null.
  static const empty = TextStyle();

  /// True if no attributes are set (all fields are null).
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

  /// Merges another style on top (non-null fields override).
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

  /// Downgrades colors to match the given color profile.
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

  /// Maps a ColorProfile to the corresponding ColorKind.
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

  /// Inherits style from a parent (non-null fields in this take priority).
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

  /// Factory for the default hyperlink style (blue, underlined).
  factory TextStyle.link({String? uri}) {
    return TextStyle(
      foreground: const Color.rgb(
        Defaults.linkColorRed,
        Defaults.linkColorGreen,
        Defaults.linkColorBlue,
      ),
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
  int get hashCode => Object.hash(
    foreground,
    background,
    bold,
    dim,
    italic,
    underline,
    blink,
    reverse,
    strikethrough,
    overline,
    width,
    height,
    wordWrap,
  );

  @override
  String toString() => 'TextStyle(${_describe()})';

  /// Produces a human-readable description of the active attributes.
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
