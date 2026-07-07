import 'dart:math' show max;

import 'color.dart';
import 'color_extensions_symbols.dart' show ColorExtensionsSymbols;

/// Converts an ANSI 16-color code to its RGB equivalent.
extension AnsiToColor on AnsiColor {
  /// The RGB representation of this ANSI color.
  Color toColor() => _ansiToRgb[code]!;
}

/// Converts a 256-color palette index to its RGB equivalent.
extension IndexedToColor on IndexedColor {
  /// The RGB representation of this indexed color.
  Color toColor() {
  if (index < ColorExtensionsSymbols.indexedColorCubeStart) {
    final color = _ansiToRgb[index]!;
    return color;
  }
  if (index >= ColorExtensionsSymbols.indexedColorGrayStart) {
    final value = (index - ColorExtensionsSymbols.indexedColorGrayStart) * ColorExtensionsSymbols.grayStep + ColorExtensionsSymbols.grayBase;
    return Color(red: value, green: value, blue: value);
  }
  final cubeIndex = index - ColorExtensionsSymbols.indexedColorCubeStart;
  final area = ColorExtensionsSymbols.indexedColorCubeSize * ColorExtensionsSymbols.indexedColorCubeSize;
  final red = (cubeIndex ~/ area) * ColorExtensionsSymbols.cubeStep;
  final green = ((cubeIndex % area) ~/ ColorExtensionsSymbols.indexedColorCubeSize) * ColorExtensionsSymbols.cubeStep;
  final blue = (cubeIndex % ColorExtensionsSymbols.indexedColorCubeSize) * ColorExtensionsSymbols.cubeStep;
  return Color(red: red, green: green, blue: blue);
}
}

/// Finds the nearest 256-color palette index for an RGB color.
extension ColorIndex on Color {
  /// The nearest 256-color palette index.
  int get index {
  var bestDistance = double.infinity;
  var bestIndex = 0;

  final cubeEnd =
      ColorExtensionsSymbols.indexedColorCubeStart +
      ColorExtensionsSymbols.indexedColorCubeSize * ColorExtensionsSymbols.indexedColorCubeSize * ColorExtensionsSymbols.indexedColorCubeSize;

  for (var index = ColorExtensionsSymbols.indexedColorCubeStart; index < cubeEnd; index++) {
    final cubeIndex = index - ColorExtensionsSymbols.indexedColorCubeStart;
    final area = ColorExtensionsSymbols.indexedColorCubeSize * ColorExtensionsSymbols.indexedColorCubeSize;
    final cubeRed = (cubeIndex ~/ area) * ColorExtensionsSymbols.cubeStep;
    final cubeGreen = ((cubeIndex % area) ~/ ColorExtensionsSymbols.indexedColorCubeSize) * ColorExtensionsSymbols.cubeStep;
    final cubeBlue = (cubeIndex % ColorExtensionsSymbols.indexedColorCubeSize) * ColorExtensionsSymbols.cubeStep;
    final distance = _redmeanDistance(
      red,
      green,
      blue,
      cubeRed,
      cubeGreen,
      cubeBlue,
    );
    if (distance < bestDistance) {
      bestDistance = distance;
      bestIndex = index;
    }
  }

  for (var index = 0; index < ColorExtensionsSymbols.indexedColorGrayCount; index++) {
    final gray = index * ColorExtensionsSymbols.grayStep + ColorExtensionsSymbols.grayBase;
    final distance = _redmeanDistance(red, green, blue, gray, gray, gray);
    if (distance < bestDistance) {
      bestDistance = distance;
      bestIndex = ColorExtensionsSymbols.indexedColorGrayStart + index;
    }
  }

  return bestIndex;
}
}

/// Converts an RGB color to its nearest ANSI 16-color equivalent.
extension ColorAnsi on Color {
  /// The nearest ANSI 16-color code.
  AnsiColor get ansi {
    final code =(){
  if (index < ColorExtensionsSymbols.indexedColorCubeStart) return index;
  const map = [0, 4, 2, 6, 1, 5, 3, 7, 8, 12, 10, 14, 9, 13, 11, 15];
  final gray = index - ColorExtensionsSymbols.indexedColorGrayStart;
  if (gray >= 0 && gray < ColorExtensionsSymbols.indexedColorGrayCount) {
    return gray < 12 ? 8 : 15;
  }
  final cube = index - ColorExtensionsSymbols.indexedColorCubeStart;
  final area = ColorExtensionsSymbols.indexedColorCubeSize * ColorExtensionsSymbols.indexedColorCubeSize;
  final cubeRed = cube ~/ area;
  final cubeGreen = (cube % area) ~/ ColorExtensionsSymbols.indexedColorCubeSize;
  final cubeBlue = cube % ColorExtensionsSymbols.indexedColorCubeSize;
  final ansiRed = cubeRed < 3 ? 0 : 1;
  final ansiGreen = cubeGreen < 3 ? 0 : 1;
  final ansiBlue = cubeBlue < 3 ? 0 : 1;
  final ansiIndex = ansiRed * 4 + ansiGreen * 2 + ansiBlue;
  final ansi = map[ansiIndex];
  final maxValue = max(max(cubeRed, cubeGreen), cubeBlue);
  return maxValue >= 5 ? ansi + 8 : ansi;
}();

  return AnsiColor(code: code);
}}

/// Generates ANSI 16-color SGR escape sequences for [AnsiColor] values.
extension AnsiColorSgr on AnsiColor {
  /// The SGR escape sequence that activates this color.
  ///
  /// Set [background] to `true` to emit a background SGR sequence.
  String toSgr({bool background = false}) {
    final base = background ? ColorExtensionsSymbols.sgrBgAnsiBase : ColorExtensionsSymbols.sgrFgAnsiBase;
    final code = this.code;
    if (code < ColorExtensionsSymbols.sgrAnsiDarkThreshold) {
      return '\x1B[${base + code}m';
    }
    return '\x1B[${base + ColorExtensionsSymbols.sgrBrightOffset + (code - ColorExtensionsSymbols.sgrAnsiDarkThreshold)}m';
  }
}

/// Generates ANSI 256-color SGR escape sequences for [IndexedColor] values.
extension IndexedColorSgr on IndexedColor {
  /// The SGR escape sequence that activates this palette entry.
  ///
  /// Set [background] to `true` to emit a background SGR sequence.
  String toSgr({bool background = false}) {
    final prefix = background ? ColorExtensionsSymbols.sgrExtendedBg : ColorExtensionsSymbols.sgrExtendedFg;
    return '\x1B[$prefix;${ColorExtensionsSymbols.sgrColor256};${index}m';
  }
}

/// Generates ANSI 24-bit true-color SGR escape sequences for [Color] values.
extension ColorSgr on Color {
  /// The SGR escape sequence that activates this RGB color.
  ///
  /// Set [background] to `true` to emit a background SGR sequence.
  String toSgr({bool background = false}) {
    final prefix = background ? ColorExtensionsSymbols.sgrExtendedBg : ColorExtensionsSymbols.sgrExtendedFg;
    return '\x1B[$prefix;${ColorExtensionsSymbols.sgrColorRgb};$red;$green;${blue}m';
  }
}

const Map<int, Color> _ansiToRgb = {
  0: Color.black(),
  1: Color.red(),
  2: Color.green(),
  3: Color.yellow(),
  4: Color.blue(),
  5: Color.magenta(),
  6: Color.cyan(),
  7: Color.white(),
  8: Color.brightBlack(),
  9: Color.brightRed(),
  10: Color.brightGreen(),
  11: Color.brightYellow(),
  12: Color.brightBlue(),
  13: Color.brightMagenta(),
  14: Color.brightCyan(),
  15: Color.brightWhite(),
};


/// Redmean-weighted squared distance between two RGB colors.
double _redmeanDistance(
  int red1,
  int green1,
  int blue1,
  int red2,
  int green2,
  int blue2,
) {
  final redMean = (red1 + red2) ~/ 2;
  final deltaRed = red1 - red2;
  final deltaGreen = green1 - green2;
  final deltaBlue = blue1 - blue2;
  return (2 + redMean / 256) * deltaRed * deltaRed +
      4 * deltaGreen * deltaGreen +
      (2 + (255 - redMean) / 256) * deltaBlue * deltaBlue;
}
