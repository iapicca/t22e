import 'package:characters/characters.dart';
import 'package:meta/meta.dart' show internal;

import 'char_width.dart' show charWidth;

/// A single Unicode grapheme cluster.
///
/// Const construction is unchecked at the grapheme layer (grapheme-count
/// validation requires the `characters` package, which cannot run at compile
/// time). Callers using [Grapheme] in const contexts are trusted to pass a
/// single grapheme cluster; the [Grapheme.validated] factory enforces the
/// single-cluster requirement at runtime and should be used at dynamic
/// text-to-cell boundaries.
@internal
extension type const Grapheme._(String _value) implements String {
  /// Creates a grapheme from [string].
  ///
  /// Const construction trusts the caller. Use [Grapheme.validated] for
  /// runtime single-cluster enforcement at dynamic boundaries.
  const Grapheme(String string) : _value = string;

  /// Creates a grapheme validated at runtime to be a single cluster.
  ///
  /// Throws [ArgumentError] if [string] is empty or contains more than one
  /// grapheme cluster. Combining marks attached to a base character count as
  /// part of the same cluster (e.g. `e\u{0301}` is one grapheme).
  factory Grapheme.validated(String string) {
    if (string.isEmpty) {
      throw ArgumentError.value(string, 'string', 'grapheme must be non-empty');
    }
    if (Characters(string).length != 1) {
      throw ArgumentError.value(
        string,
        'string',
        'must be a single grapheme cluster',
      );
    }
    return Grapheme(string);
  }

  /// The single-cell space grapheme.
  static const Grapheme space = Grapheme(' ');

  /// The backing string.
  String get string => _value;

  /// Terminal cell width (0, 1, or 2) derived from the leading codepoint.
  int get width => charWidth(_value);
}