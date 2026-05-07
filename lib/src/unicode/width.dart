import 'tables.dart';

int charWidth(int codepoint) => charWidthFromTable(codepoint);
bool isWide(int codepoint) => charWidthFromTable(codepoint) == 2;
bool isZeroWidth(int codepoint) => charWidthFromTable(codepoint) == 0;
bool isEmoji(int codepoint) => isEmojiFromTable(codepoint);
bool isPrintable(int codepoint) => isPrintableFromTable(codepoint);
bool isPrivateUse(int codepoint) => isPrivateUseFromTable(codepoint);
bool isAmbiguousWidth(int codepoint) => isAmbiguousWidthFromTable(codepoint);

int stringWidth(String s) {
  var w = 0;
  for (final rune in s.runes) {
    w += charWidth(rune);
  }
  return w;
}
