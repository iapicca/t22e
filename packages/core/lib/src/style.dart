import 'package:freezed_annotation/freezed_annotation.dart';
import 'color.dart';
import 'package:protocol/protocol.dart' show Defaults;

part 'style.freezed.dart';

/// Text styling with SGR attributes (bold, italic, underline, etc.) and colors.
@freezed
abstract class TextStyle with _$TextStyle {
  const TextStyle._();

  const factory TextStyle({
    Color? foreground,
    Color? background,
    bool? bold,
    bool? dim,
    bool? italic,
    bool? underline,
    bool? blink,
    bool? reverse,
    bool? strikethrough,
    bool? overline,
    int? width,
    int? height,
    bool? wordWrap,
  }) = _TextStyle;

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
    return copyWith(
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
    if (profile == ColorProfile.noColor) {
      if (foreground == null && background == null) return this;
      return copyWith(foreground: null, background: null);
    }
    return this;
  }

  /// Inherits style from a parent (non-null fields in this take priority).
  TextStyle inherit(TextStyle parent) {
    if (parent.isClear) return this;
    return copyWith(
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
  static TextStyle link({String? uri}) {
    return TextStyle(
      foreground: Color(
        red: Defaults.linkColorRed,
        green: Defaults.linkColorGreen,
        blue: Defaults.linkColorBlue,
      ),
      underline: true,
    );
  }

  /// Produces a human-readable description of the active attributes.
}
