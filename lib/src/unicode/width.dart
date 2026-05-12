import 'tables.dart';
import '../well_known.dart' show WellKnown;

/// Returns the display width (0, 1, or 2 columns) for a single codepoint
int charWidth(int codepoint) => charWidthFromTable(codepoint);
/// Whether the codepoint is a wide (2-column) character
bool isWide(int codepoint) => charWidthFromTable(codepoint) == WellKnown.wideCharWidth;
/// Whether the codepoint has zero display width
bool isZeroWidth(int codepoint) => charWidthFromTable(codepoint) == WellKnown.zeroCharWidth;
/// Whether the codepoint is classified as an emoji
bool isEmoji(int codepoint) => isEmojiFromTable(codepoint);
/// Whether the codepoint is a printable character
bool isPrintable(int codepoint) => isPrintableFromTable(codepoint);
/// Whether the codepoint is in the private use area
bool isPrivateUse(int codepoint) => isPrivateUseFromTable(codepoint);
/// Whether the codepoint has ambiguous (context-dependent) width
bool isAmbiguousWidth(int codepoint) => isAmbiguousWidthFromTable(codepoint);

/// Returns the total display width of a string (sum of codepoint widths)
int stringWidth(String s) {
  var w = 0;
  for (final rune in s.runes) {
    w += charWidth(rune);
  }
  return w;
}
