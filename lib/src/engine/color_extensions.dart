import 'dart:math' show max;

import 'color.dart';

/// Converts an ANSI 16-color code to its RGB equivalent.
extension AnsiToColor on AnsiColor {
  /// The RGB representation of this ANSI color.
  Color toColor() => _ansiToRgb[code]!;
}

/// Converts a 256-color palette index to its RGB equivalent.
extension IndexedToColor on IndexedColor {
  /// The RGB representation of this indexed color.
  Color toColor() {
    final (red, green, blue) = _indexToRgb(index);
    return Color(red: red, green: green, blue: blue);
  }
}

/// Finds the nearest 256-color palette index for an RGB color.
extension ColorIndex on Color {
  /// The nearest 256-color palette index.
  int get index => _rgbToIndexed(red, green, blue);
}

/// Converts an RGB color to its nearest ANSI 16-color equivalent.
extension ColorAnsi on Color {
  /// The nearest ANSI 16-color code.
  AnsiColor get ansi => AnsiColor(code: _indexedToAnsi(index));
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

(int, int, int) _indexToRgb(int index) {
  if (index < _indexedColorCubeStart) {
    final color = _ansiToRgb[index]!;
    return (color.red, color.green, color.blue);
  }
  if (index >= _indexedColorGrayStart) {
    final value = (index - _indexedColorGrayStart) * _grayStep + _grayBase;
    return (value, value, value);
  }
  final cubeIndex = index - _indexedColorCubeStart;
  final area = _indexedColorCubeSize * _indexedColorCubeSize;
  final red = (cubeIndex ~/ area) * _cubeStep;
  final green = ((cubeIndex % area) ~/ _indexedColorCubeSize) * _cubeStep;
  final blue = (cubeIndex % _indexedColorCubeSize) * _cubeStep;
  return (red, green, blue);
}

int _rgbToIndexed(int red, int green, int blue) {
  var bestDistance = double.infinity;
  var bestIndex = 0;

  final cubeEnd =
      _indexedColorCubeStart +
      _indexedColorCubeSize * _indexedColorCubeSize * _indexedColorCubeSize;

  for (var index = _indexedColorCubeStart; index < cubeEnd; index++) {
    final cubeIndex = index - _indexedColorCubeStart;
    final area = _indexedColorCubeSize * _indexedColorCubeSize;
    final cubeRed = (cubeIndex ~/ area) * _cubeStep;
    final cubeGreen = ((cubeIndex % area) ~/ _indexedColorCubeSize) * _cubeStep;
    final cubeBlue = (cubeIndex % _indexedColorCubeSize) * _cubeStep;
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

  for (var index = 0; index < _indexedColorGrayCount; index++) {
    final gray = index * _grayStep + _grayBase;
    final distance = _redmeanDistance(red, green, blue, gray, gray, gray);
    if (distance < bestDistance) {
      bestDistance = distance;
      bestIndex = _indexedColorGrayStart + index;
    }
  }

  return bestIndex;
}

int _indexedToAnsi(int index) {
  if (index < _indexedColorCubeStart) return index;
  const map = [0, 4, 2, 6, 1, 5, 3, 7, 8, 12, 10, 14, 9, 13, 11, 15];
  final gray = index - _indexedColorGrayStart;
  if (gray >= 0 && gray < _indexedColorGrayCount) {
    return gray < 12 ? 8 : 15;
  }
  final cube = index - _indexedColorCubeStart;
  final area = _indexedColorCubeSize * _indexedColorCubeSize;
  final cubeRed = cube ~/ area;
  final cubeGreen = (cube % area) ~/ _indexedColorCubeSize;
  final cubeBlue = cube % _indexedColorCubeSize;
  final ansiRed = cubeRed < 3 ? 0 : 1;
  final ansiGreen = cubeGreen < 3 ? 0 : 1;
  final ansiBlue = cubeBlue < 3 ? 0 : 1;
  final ansiIndex = ansiRed * 4 + ansiGreen * 2 + ansiBlue;
  final ansi = map[ansiIndex];
  final maxValue = max(max(cubeRed, cubeGreen), cubeBlue);
  return maxValue >= 5 ? ansi + 8 : ansi;
}

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

const int _indexedColorCubeStart = 16;
const int _indexedColorGrayStart = 232;
const int _indexedColorGrayCount = 24;
const int _indexedColorCubeSize = 6;
const int _rgbComponentMax = 255;
const int _cubeStep = _rgbComponentMax ~/ (_indexedColorCubeSize - 1);
const int _grayStep = 10;
const int _grayBase = 8;
