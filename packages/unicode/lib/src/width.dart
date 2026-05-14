import 'tables.dart';
import 'package:protocol/protocol.dart' show Defaults;

/// Returns the display column width of a codepoint.
int charWidth(int codepoint) => charWidthFromTable(codepoint);
/// True if the codepoint uses 2 column widths (CJK wide).
bool isWide(int codepoint) =>
    charWidthFromTable(codepoint) == Defaults.wideCharWidth;
/// True if the codepoint has zero display width.
bool isZeroWidth(int codepoint) =>
    charWidthFromTable(codepoint) == Defaults.zeroCharWidth;
/// True if the codepoint is an emoji.
bool isEmoji(int codepoint) => isEmojiFromTable(codepoint);
/// True if the codepoint is printable.
bool isPrintable(int codepoint) => isPrintableFromTable(codepoint);
/// True if the codepoint is in a Private Use Area.
bool isPrivateUse(int codepoint) => isPrivateUseFromTable(codepoint);
/// True if the codepoint has ambiguous width (varies by terminal).
bool isAmbiguousWidth(int codepoint) => isAmbiguousWidthFromTable(codepoint);

/// Computes the total display column width of a string.
int stringWidth(String s) {
  var w = 0;
  for (final rune in s.runes) {
    w += charWidth(rune);
  }
  return w;
}
