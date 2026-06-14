import 'width.dart';
import 'package:protocol/protocol.dart'
    show GraphemeProperties, UnicodeCodepoints, UnicodeRanges;

/// Describes a grapheme cluster: rune range [start, end) and column width.
typedef GraphemeCluster = ({int start, int end, int columnWidth});

/// Returns the grapheme break property for a codepoint.
int _graphemeBreakProperty(int codepoint) {
  if (codepoint == UnicodeCodepoints.codepointZwj) {
    return GraphemeProperties.graphemePropZwj;
  }
  if (codepoint >= UnicodeRanges.codepointVariationSelectorStart &&
      codepoint <= UnicodeRanges.codepointVariationSelectorEnd) {
    return GraphemeProperties.graphemePropVariationSelector;
  }
  if (codepoint >= UnicodeRanges.codepointRegionalIndicatorStart &&
      codepoint <= UnicodeRanges.codepointRegionalIndicatorEnd) {
    return GraphemeProperties.graphemePropRegionalIndicator;
  }
  if ((codepoint >= UnicodeRanges.codepointCombiningDiacriticalStart &&
          codepoint <= UnicodeRanges.codepointCombiningDiacriticalEnd) ||
      (codepoint >= UnicodeRanges.codepointCombiningDiacriticalExtStart &&
          codepoint <= UnicodeRanges.codepointCombiningDiacriticalExtEnd) ||
      (codepoint >= UnicodeRanges.codepointCombiningDiacriticalSuppStart &&
          codepoint <= UnicodeRanges.codepointCombiningDiacriticalSuppEnd) ||
      (codepoint >= UnicodeRanges.codepointCombiningMarksSymbolsStart &&
          codepoint <= UnicodeRanges.codepointCombiningMarksSymbolsEnd) ||
      (codepoint >= UnicodeRanges.codepointCombiningHalfMarksStart &&
          codepoint <= UnicodeRanges.codepointCombiningHalfMarksEnd)) {
    return GraphemeProperties.graphemePropCombiningMark;
  }
  if (codepoint >= UnicodeRanges.codepointEmojiModifierStart &&
      codepoint <= UnicodeRanges.codepointEmojiModifierEnd) {
    return GraphemeProperties.graphemePropEmojiModifier;
  }
  if (codepoint == UnicodeRanges.codepointTag ||
      (codepoint >= UnicodeRanges.codepointVariationSelectorSuppStart &&
          codepoint <= UnicodeRanges.codepointVariationSelectorSuppEnd)) {
    return GraphemeProperties.graphemePropTag;
  }
  if (codepoint >= UnicodeRanges.codepointHangulLeadingStart &&
      codepoint <= UnicodeRanges.codepointHangulLeadingEnd) {
    return GraphemeProperties.graphemePropHangulLeading;
  }
  if ((codepoint >= UnicodeRanges.codepointHangulVowelStart &&
          codepoint <= UnicodeRanges.codepointHangulVowelEnd) ||
      (codepoint >= UnicodeRanges.codepointHangulSyllableStart &&
          codepoint <= UnicodeRanges.codepointHangulSyllableEnd)) {
    return GraphemeProperties.graphemePropHangulVowel;
  }
  if (codepoint >= UnicodeRanges.codepointHangulTrailingStart &&
      codepoint <= UnicodeRanges.codepointHangulTrailingEnd) {
    return GraphemeProperties.graphemePropHangulTrailing;
  }
  if (codepoint >= UnicodeRanges.codepointExtendedPictographicStart &&
      codepoint <= UnicodeRanges.codepointExtendedPictographicEnd) {
    return GraphemeProperties.graphemePropExtendedPictographic;
  }
  if (codepoint == UnicodeCodepoints.codepointSoftHyphen ||
      codepoint == UnicodeCodepoints.codepointArabicFormatChar ||
      codepoint == UnicodeCodepoints.codepointMongolianVowelSeparator ||
      (codepoint >= UnicodeCodepoints.codepointEnQuadStart &&
          codepoint <= UnicodeCodepoints.codepointEnQuadEnd) ||
      codepoint == UnicodeCodepoints.codepointLineSeparator ||
      codepoint == UnicodeCodepoints.codepointParagraphSeparator ||
      (codepoint >= UnicodeCodepoints.codepointBidiOverrideStart &&
          codepoint <= UnicodeCodepoints.codepointBidiOverrideEnd) ||
      (codepoint >= UnicodeCodepoints.codepointWordJoinerStart &&
          codepoint <= UnicodeCodepoints.codepointWordJoinerEnd) ||
      codepoint == UnicodeCodepoints.codepointBidiIsolateLri ||
      codepoint == UnicodeCodepoints.codepointBidiIsolateRli ||
      codepoint == UnicodeCodepoints.codepointBidiIsolateFsi ||
      (codepoint >= UnicodeCodepoints.codepointBidiIsolatePdiStart &&
          codepoint <= UnicodeCodepoints.codepointBidiIsolatePdiEnd) ||
      codepoint == UnicodeCodepoints.codepointBomZwnbsp) {
    return GraphemeProperties.graphemePropInvisible;
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
      if (prop == GraphemeProperties.graphemePropZwj ||
          prop == GraphemeProperties.graphemePropVariationSelector ||
          prop == GraphemeProperties.graphemePropCombiningMark ||
          prop == GraphemeProperties.graphemePropEmojiModifier) {
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
