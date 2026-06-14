import 'package:protocol/protocol.dart'
    show ControlBytes, SgrCodes, ColorConstants;

import 'color_profile.dart';

export 'color_profile.dart';

/// Extension type for validated ANSI 16-color codes (0–15).
extension type AnsiColor._(int _code) {
  AnsiColor(int code)
    : _code = code,
      assert(
        code >= 0 && code <= ColorConstants.ansiColorMax,
        'ANSI code out of range',
      );

  /// The validated ANSI color code (0–15).
  int get code => _code;
}

/// Extension type for validated indexed 256-color palette entries (0–255).
extension type IndexedColor._(int _index) {
  IndexedColor(int index)
    : _index = index,
      assert(
        index >= 0 && index < ColorConstants.colorProfileIndexedCount,
        'index out of range',
      );

  /// The validated palette index (0–255).
  int get index => _index;
}

/// A terminal color stored as exact RGB, with conversion getters.
extension type Color._((int, int, int) _rgb) {
  const Color({int red = 0, int green = 0, int blue = 0})
    : assert(
        red >= 0 && red <= ColorConstants.rgbComponentMax,
        'red out of range',
      ),
      assert(
        green >= 0 && green <= ColorConstants.rgbComponentMax,
        'green out of range',
      ),
      assert(
        blue >= 0 && blue <= ColorConstants.rgbComponentMax,
        'blue out of range',
      ),
      _rgb = (red, green, blue);

  // ── ANSI 16-color constants ──

  const Color.black() : _rgb = (0, 0, 0);
  const Color.red() : _rgb = (153, 0, 0);
  const Color.green() : _rgb = (0, 153, 0);
  const Color.yellow() : _rgb = (153, 153, 0);
  const Color.blue() : _rgb = (0, 0, 153);
  const Color.magenta() : _rgb = (153, 0, 153);
  const Color.cyan() : _rgb = (0, 153, 153);
  const Color.white() : _rgb = (153, 153, 153);
  const Color.brightBlack() : _rgb = (68, 68, 68);
  const Color.brightRed() : _rgb = (255, 0, 0);
  const Color.brightGreen() : _rgb = (0, 255, 0);
  const Color.brightYellow() : _rgb = (255, 255, 0);
  const Color.brightBlue() : _rgb = (0, 0, 255);
  const Color.brightMagenta() : _rgb = (255, 0, 255);
  const Color.brightCyan() : _rgb = (0, 255, 255);
  const Color.brightWhite() : _rgb = (255, 255, 255);

  /// Red component (0–255).
  int get red => _rgb.$1;

  /// Green component (0–255).
  int get green => _rgb.$2;

  /// Blue component (0–255).
  int get blue => _rgb.$3;
}

// ── Public extensions ──

/// Converts an ANSI color code to its RGB equivalent.
extension AnsiToColor on AnsiColor {
  Color toColor() => _ansiToRgb[code]!;
}

/// Converts a 256-color palette index to its RGB equivalent.
extension IndexedToColor on IndexedColor {
  Color toColor() {
    final (r, g, b) = _indexToRgb(index);
    return Color(red: r, green: g, blue: b);
  }
}

/// Finds the nearest 256-color palette index for an RGB color.
extension ColorIndex on Color {
  int get index => _rgbToIndexed(red, green, blue);
}

/// Converts an RGB color to its nearest ANSI 16-color equivalent.
extension ColorAnsi on Color {
  AnsiColor get ansi => AnsiColor(_indexedToAnsi(index));
}

/// Generates SGR escape sequences for this color based on profile.
extension ColorSgr on Color {
  String sgrSequence({
    bool background = false,
    ColorProfile profile = ColorProfile.trueColor,
  }) {
    switch (profile) {
      case ColorProfile.noColor:
        return background
            ? '${ControlBytes.csi}${SgrCodes.sgrBgReset}m'
            : '${ControlBytes.csi}${SgrCodes.sgrFgReset}m';
      case ColorProfile.ansi16:
        final code = ansi.code;
        final off = background
            ? SgrCodes.sgrBgAnsiBase
            : SgrCodes.sgrFgAnsiBase;
        if (code < ColorConstants.ansiDarkThreshold) {
          return '${ControlBytes.csi}${off + code}m';
        }
        return '${ControlBytes.csi}'
            '${off + ColorConstants.ansiBrightOffset + code - ColorConstants.ansiDarkThreshold}m';
      case ColorProfile.indexed256:
        final prefix = background
            ? SgrCodes.sgrBgExtended
            : SgrCodes.sgrFgExtended;
        return '${ControlBytes.csi}$prefix;${SgrCodes.sgrColor256};${index}m';
      case ColorProfile.trueColor:
        final prefix = background
            ? SgrCodes.sgrBgExtended
            : SgrCodes.sgrFgExtended;
        return '${ControlBytes.csi}$prefix;${SgrCodes.sgrColorRgb};$red;$green;${blue}m';
    }
  }
}

// ── Internal conversion helpers ──

/// Lookup table mapping ANSI 16-color codes to RGB values.
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

/// Converts a 256-color palette index to RGB components.
(int, int, int) _indexToRgb(int index) {
  if (index < ColorConstants.indexedColorCubeStart) {
    final c = _ansiToRgb[index]!;
    return (c.red, c.green, c.blue);
  }
  if (index >= ColorConstants.indexedColorGrayStart) {
    final v =
        (index - ColorConstants.indexedColorGrayStart) * _grayStep + _grayBase;
    return (v, v, v);
  }
  final i = index - ColorConstants.indexedColorCubeStart;
  final cubeArea = ColorConstants.indexedColorCubeSize;
  final r = (i ~/ (cubeArea * cubeArea)) * _cubeStep;
  final g = ((i % (cubeArea * cubeArea)) ~/ cubeArea) * _cubeStep;
  final b = (i % cubeArea) * _cubeStep;
  return (r, g, b);
}

/// Finds the nearest 256-color palette index for the given RGB.
int _rgbToIndexed(int r, int g, int b) {
  var bestDist = double.infinity;
  var bestIdx = 0;

  final cubeStart = ColorConstants.indexedColorCubeStart;
  final cubeSize = ColorConstants.indexedColorCubeSize;
  final cubeEnd = cubeStart + cubeSize * cubeSize * cubeSize;
  final cubeStep = _cubeStep;

  for (var i = cubeStart; i < cubeEnd; i++) {
    final ci = i - cubeStart;
    final cr = (ci ~/ (cubeSize * cubeSize)) * cubeStep;
    final cg = ((ci % (cubeSize * cubeSize)) ~/ cubeSize) * cubeStep;
    final cb = (ci % cubeSize) * cubeStep;
    final dist = _redmeanDistance(r, g, b, cr, cg, cb);
    if (dist < bestDist) {
      bestDist = dist;
      bestIdx = i;
    }
  }

  final grayStart = ColorConstants.indexedColorGrayStart;
  final grayCount = ColorConstants.indexedColorGrayCount;
  for (var i = 0; i < grayCount; i++) {
    final gray = i * _grayStep + _grayBase;
    final dist = _redmeanDistance(r, g, b, gray, gray, gray);
    if (dist < bestDist) {
      bestDist = dist;
      bestIdx = grayStart + i;
    }
  }

  return bestIdx;
}

/// Converts a 256-color index to its nearest ANSI 16-color code.
int _indexedToAnsi(int index) {
  if (index < ColorConstants.indexedColorCubeStart) return index;
  const map = [0, 4, 2, 6, 1, 5, 3, 7, 8, 12, 10, 14, 9, 13, 11, 15];
  final gray = index - ColorConstants.indexedColorGrayStart;
  if (gray >= 0 && gray < ColorConstants.indexedColorGrayCount) {
    return gray < 12 ? 8 : 15;
  }
  final cubeSize = ColorConstants.indexedColorCubeSize;
  final cube = index - ColorConstants.indexedColorCubeStart;
  final cubeR = cube ~/ (cubeSize * cubeSize);
  final cubeG = (cube % (cubeSize * cubeSize)) ~/ cubeSize;
  final cubeB = cube % cubeSize;
  final ansiR = cubeR < 3 ? 0 : 1;
  final ansiG = cubeG < 3 ? 0 : 1;
  final ansiB = cubeB < 3 ? 0 : 1;
  final ansiIdx = ansiR * 4 + ansiG * 2 + ansiB;
  final ansi = map[ansiIdx];
  final maxVal = [
    cubeR,
    cubeG,
    cubeB,
  ].where((v) => v >= 3).fold(0, (a, b) => a > b ? a : b);
  return maxVal >= 5 ? ansi + 8 : ansi;
}

/// Computes perceptual color distance using red-mean formula.
double _redmeanDistance(int r1, int g1, int b1, int r2, int g2, int b2) {
  final rBar = (r1 + r2) ~/ 2;
  final dr = r1 - r2;
  final dg = g1 - g2;
  final db = b1 - b2;
  return (2 + rBar / 256) * dr * dr +
      4 * dg * dg +
      (2 + (255 - rBar) / 256) * db * db;
}

/// Step size between adjacent values in the 6x6x6 color cube.
const int _cubeStep =
    ColorConstants.rgbComponentMax ~/ (ColorConstants.indexedColorCubeSize - 1);

/// Step size between grayscale ramp entries.
const int _grayStep = 10;

/// Base brightness for grayscale ramp entries.
const int _grayBase = 8;
