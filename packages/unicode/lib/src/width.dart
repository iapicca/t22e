import 'tables.dart';
import 'package:protocol/protocol.dart' show Defaults;

int charWidth(int codepoint) => charWidthFromTable(codepoint);
bool isWide(int codepoint) =>
    charWidthFromTable(codepoint) == Defaults.wideCharWidth;
bool isZeroWidth(int codepoint) =>
    charWidthFromTable(codepoint) == Defaults.zeroCharWidth;
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
