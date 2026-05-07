import 'width.dart';

typedef GraphemeCluster = ({int start, int end, int columnWidth});

int _graphemeBreakProperty(int codepoint) {
  if (codepoint == 0x200D) return 1;
  if (codepoint >= 0xFE00 && codepoint <= 0xFE0F) return 2;
  if (codepoint >= 0x1F1E6 && codepoint <= 0x1F1FF) return 3;
  if ((codepoint >= 0x0300 && codepoint <= 0x036F) ||
      (codepoint >= 0x1AB0 && codepoint <= 0x1AFF) ||
      (codepoint >= 0x1DC0 && codepoint <= 0x1DFF) ||
      (codepoint >= 0x20D0 && codepoint <= 0x20FF) ||
      (codepoint >= 0xFE20 && codepoint <= 0xFE2F)) return 4;
  if (codepoint >= 0x1F3FB && codepoint <= 0x1F3FF) return 5;
  if (codepoint == 0xE0020 || (codepoint >= 0xE0100 && codepoint <= 0xE01EF)) return 6;
  if (codepoint >= 0x1100 && codepoint <= 0x115F) return 7;
  if ((codepoint >= 0x1160 && codepoint <= 0x11A2) ||
      (codepoint >= 0xAC00 && codepoint <= 0xD7AF)) return 8;
  if (codepoint >= 0x11A8 && codepoint <= 0x11F9) return 9;
  if (codepoint >= 0x1F900 && codepoint <= 0x1F9FF) return 10;
  if (codepoint == 0x00AD ||
      codepoint == 0x061C ||
      codepoint == 0x180E ||
      (codepoint >= 0x2000 && codepoint <= 0x200A) ||
      codepoint == 0x2028 ||
      codepoint == 0x2029 ||
      (codepoint >= 0x202A && codepoint <= 0x202E) ||
      (codepoint >= 0x2060 && codepoint <= 0x2064) ||
      codepoint == 0x2066 ||
      codepoint == 0x2067 ||
      codepoint == 0x2068 ||
      (codepoint >= 0x2069 && codepoint <= 0x206F) ||
      codepoint == 0xFEFF) return 11;
  return 0;
}

List<GraphemeCluster> graphemeClusters(String text) {
  final clusters = <GraphemeCluster>[];
  if (text.isEmpty) return clusters;

  final runes = text.runes.toList();
  var clusterStart = 0;
  var colOffset = 0;
  var clusterWidth = 0;

  for (var i = 0; i < runes.length; i++) {
    final cp = runes[i];
    final prop = _graphemeBreakProperty(cp);
    final cw = charWidth(cp);

    if (i > 0) {
      if (prop == 1 || prop == 2 || prop == 4 || prop == 5) {
        clusterWidth += cw;
        continue;
      }
      clusters.add((start: clusterStart, end: i, columnWidth: clusterWidth));
      clusterStart = i;
      colOffset += clusterWidth;
      clusterWidth = 0;
    }

    clusterWidth += cw;
  }

  clusters.add((start: clusterStart, end: runes.length, columnWidth: clusterWidth));
  return clusters;
}

int stringWidthGrapheme(String text) {
  final clusters = graphemeClusters(text);
  return clusters.fold(0, (sum, c) => sum + c.columnWidth);
}

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
