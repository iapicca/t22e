import 'width.dart';
import 'package:protocol/protocol.dart' show Defaults;

/// Describes a grapheme cluster: rune range [start, end) and column width.
typedef GraphemeCluster = ({int start, int end, int columnWidth});

/// Returns the grapheme break property for a codepoint.
int _graphemeBreakProperty(int codepoint) {
  if (codepoint == Defaults.codepointZwj) {
    return Defaults.graphemePropZwj;
  }
  if (codepoint >= Defaults.codepointVariationSelectorStart &&
      codepoint <= Defaults.codepointVariationSelectorEnd) {
    return Defaults.graphemePropVariationSelector;
  }
  if (codepoint >= Defaults.codepointRegionalIndicatorStart &&
      codepoint <= Defaults.codepointRegionalIndicatorEnd) {
    return Defaults.graphemePropRegionalIndicator;
  }
  if ((codepoint >= Defaults.codepointCombiningDiacriticalStart &&
          codepoint <= Defaults.codepointCombiningDiacriticalEnd) ||
      (codepoint >= Defaults.codepointCombiningDiacriticalExtStart &&
          codepoint <= Defaults.codepointCombiningDiacriticalExtEnd) ||
      (codepoint >= Defaults.codepointCombiningDiacriticalSuppStart &&
          codepoint <= Defaults.codepointCombiningDiacriticalSuppEnd) ||
      (codepoint >= Defaults.codepointCombiningMarksSymbolsStart &&
          codepoint <= Defaults.codepointCombiningMarksSymbolsEnd) ||
      (codepoint >= Defaults.codepointCombiningHalfMarksStart &&
          codepoint <= Defaults.codepointCombiningHalfMarksEnd)) {
    return Defaults.graphemePropCombiningMark;
  }
  if (codepoint >= Defaults.codepointEmojiModifierStart &&
      codepoint <= Defaults.codepointEmojiModifierEnd) {
    return Defaults.graphemePropEmojiModifier;
  }
  if (codepoint == Defaults.codepointTag ||
      (codepoint >= Defaults.codepointVariationSelectorSuppStart &&
          codepoint <= Defaults.codepointVariationSelectorSuppEnd)) {
    return Defaults.graphemePropTag;
  }
  if (codepoint >= Defaults.codepointHangulLeadingStart &&
      codepoint <= Defaults.codepointHangulLeadingEnd) {
    return Defaults.graphemePropHangulLeading;
  }
  if ((codepoint >= Defaults.codepointHangulVowelStart &&
          codepoint <= Defaults.codepointHangulVowelEnd) ||
      (codepoint >= Defaults.codepointHangulSyllableStart &&
          codepoint <= Defaults.codepointHangulSyllableEnd)) {
    return Defaults.graphemePropHangulVowel;
  }
  if (codepoint >= Defaults.codepointHangulTrailingStart &&
      codepoint <= Defaults.codepointHangulTrailingEnd) {
    return Defaults.graphemePropHangulTrailing;
  }
  if (codepoint >= Defaults.codepointExtendedPictographicStart &&
      codepoint <= Defaults.codepointExtendedPictographicEnd) {
    return Defaults.graphemePropExtendedPictographic;
  }
  if (codepoint == Defaults.codepointSoftHyphen ||
      codepoint == Defaults.codepointArabicFormatChar ||
      codepoint == Defaults.codepointMongolianVowelSeparator ||
      (codepoint >= Defaults.codepointEnQuadStart &&
          codepoint <= Defaults.codepointEnQuadEnd) ||
      codepoint == Defaults.codepointLineSeparator ||
      codepoint == Defaults.codepointParagraphSeparator ||
      (codepoint >= Defaults.codepointBidiOverrideStart &&
          codepoint <= Defaults.codepointBidiOverrideEnd) ||
      (codepoint >= Defaults.codepointWordJoinerStart &&
          codepoint <= Defaults.codepointWordJoinerEnd) ||
      codepoint == Defaults.codepointBidiIsolateLri ||
      codepoint == Defaults.codepointBidiIsolateRli ||
      codepoint == Defaults.codepointBidiIsolateFsi ||
      (codepoint >= Defaults.codepointBidiIsolatePdiStart &&
          codepoint <= Defaults.codepointBidiIsolatePdiEnd) ||
      codepoint == Defaults.codepointBomZwnbsp) {
    return Defaults.graphemePropInvisible;
  }
  return 0;
}

/// Segments text into grapheme clusters with their column widths.
List<GraphemeCluster> graphemeClusters(String text) {
  final clusters = <GraphemeCluster>[];
  if (text.isEmpty) return clusters;

  final runes = text.runes.toList();
  var clusterStart = 0;

  var clusterWidth = 0;

  for (var i = 0; i < runes.length; i++) {
    final cp = runes[i];
    final prop = _graphemeBreakProperty(cp);
    final cw = charWidth(cp);

    if (i > 0) {
      if (prop == Defaults.graphemePropZwj ||
          prop == Defaults.graphemePropVariationSelector ||
          prop == Defaults.graphemePropCombiningMark ||
          prop == Defaults.graphemePropEmojiModifier) {
        clusterWidth += cw;
        continue;
      }
      clusters.add((start: clusterStart, end: i, columnWidth: clusterWidth));
      clusterStart = i;
      clusterWidth = 0;
    }

    clusterWidth += cw;
  }

  clusters.add((
    start: clusterStart,
    end: runes.length,
    columnWidth: clusterWidth,
  ));
  return clusters;
}

/// Computes the total column width of a string respecting grapheme clusters.
int stringWidthGrapheme(String text) {
  final clusters = graphemeClusters(text);
  return clusters.fold(0, (sum, c) => sum + c.columnWidth);
}

/// Truncates a string to a maximum display width in columns.
String truncate(String text, int maxWidth) {
  final clusters = graphemeClusters(text);
  var w = 0;
  var end = 0;
  for (final c in clusters) {
    if (w + c.columnWidth > maxWidth) break;
    w += c.columnWidth;
    end = c.end;
  }
  if (end == 0) return '';
  final runeArray = text.runes.toList();
  final subRunes = runeArray.sublist(0, end);
  return String.fromCharCodes(subRunes);
}
