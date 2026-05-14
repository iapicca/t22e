import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:protocol/protocol.dart' show Defaults;

import 'color_profile.dart';

export 'color_profile.dart';
part 'color.freezed.dart';

/// Extension type for validated ANSI 16-color codes (0–15).
extension type AnsiColor._(int _code) {
  AnsiColor(int code)
    : _code = code,
      assert(
        code >= 0 && code <= Defaults.ansiColorMax,
        'ANSI code out of range',
      );

  int get code => _code;
}

/// Extension type for validated indexed 256-color palette entries (0–255).
extension type IndexedColor._(int _index) {
  IndexedColor(int index)
    : _index = index,
      assert(
        index >= 0 && index < Defaults.colorProfileIndexedCount,
        'index out of range',
      );

  int get index => _index;
}

/// A terminal color stored as exact RGB, with conversion getters.
@freezed
abstract class Color with _$Color {
  const Color._();

  @Assert('red >= 0 && red <= ${Defaults.rgbComponentMax}')
  @Assert('green >= 0 && green <= ${Defaults.rgbComponentMax}')
  @Assert('blue >= 0 && blue <= ${Defaults.rgbComponentMax}')
  const factory Color({
    @Default(0) int red,
    @Default(0) int green,
    @Default(0) int blue,
  }) = _Color;

  factory Color.fromAnsi(AnsiColor ansi) {
    final (r, g, b) = _ansiToRgb(ansi.code);
    return Color(red: r, green: g, blue: b);
  }

  factory Color.fromIndexed(IndexedColor indexed) {
    final (r, g, b) = _indexToRgb(indexed.index);
    return Color(red: r, green: g, blue: b);
  }

  /// Nearest indexed 256-color palette entry.
  int get index => _rgbToIndexed(red, green, blue);

  /// Nearest ANSI 16-color match.
  AnsiColor get ansi => AnsiColor(_indexedToAnsi(index));

  /// Generates the SGR escape sequence for this color.
  String sgrSequence({
    bool background = false,
    ColorProfile profile = ColorProfile.trueColor,
  }) {
    switch (profile) {
      case ColorProfile.noColor:
        return background
            ? '${Defaults.csi}${Defaults.sgrBgReset}m'
            : '${Defaults.csi}${Defaults.sgrFgReset}m';
      case ColorProfile.ansi16:
        final code = ansi.code;
        final off = background
            ? Defaults.sgrBgAnsiBase
            : Defaults.sgrFgAnsiBase;
        if (code < Defaults.ansiDarkThreshold) {
          return '${Defaults.csi}${off + code}m';
        }
        return '${Defaults.csi}'
            '${off + Defaults.ansiBrightOffset + code - Defaults.ansiDarkThreshold}m';
      case ColorProfile.indexed256:
        final prefix = background
            ? Defaults.sgrBgExtended
            : Defaults.sgrFgExtended;
        return '${Defaults.csi}$prefix;${Defaults.sgrColor256};${index}m';
      case ColorProfile.trueColor:
        final prefix = background
            ? Defaults.sgrBgExtended
            : Defaults.sgrFgExtended;
        return '${Defaults.csi}$prefix;${Defaults.sgrColorRgb};$red;$green;${blue}m';
    }
  }

  // ── internal conversion helpers ──

  static (int, int, int) _ansiToRgb(int code) {
    return switch (code) {
      0 => (0, 0, 0),
      1 => (153, 0, 0),
      2 => (0, 153, 0),
      3 => (153, 153, 0),
      4 => (0, 0, 153),
      5 => (153, 0, 153),
      6 => (0, 153, 153),
      7 => (153, 153, 153),
      8 => (68, 68, 68),
      9 => (255, 0, 0),
      10 => (0, 255, 0),
      11 => (255, 255, 0),
      12 => (0, 0, 255),
      13 => (255, 0, 255),
      14 => (0, 255, 255),
      15 => (255, 255, 255),
      _ => (0, 0, 0),
    };
  }

  static (int, int, int) _indexToRgb(int index) {
    if (index < Defaults.indexedColorCubeStart) return _ansiToRgb(index);
    if (index >= Defaults.indexedColorGrayStart) {
      final v =
          (index - Defaults.indexedColorGrayStart) * _grayStep + _grayBase;
      return (v, v, v);
    }
    final i = index - Defaults.indexedColorCubeStart;
    final cubeArea = Defaults.indexedColorCubeSize;
    final r = (i ~/ (cubeArea * cubeArea)) * _cubeStep;
    final g = ((i % (cubeArea * cubeArea)) ~/ cubeArea) * _cubeStep;
    final b = (i % cubeArea) * _cubeStep;
    return (r, g, b);
  }

  static int _rgbToIndexed(int r, int g, int b) {
    var bestDist = double.infinity;
    var bestIdx = 0;

    final cubeStart = Defaults.indexedColorCubeStart;
    final cubeSize = Defaults.indexedColorCubeSize;
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

    final grayStart = Defaults.indexedColorGrayStart;
    final grayCount = Defaults.indexedColorGrayCount;
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

  static int _indexedToAnsi(int index) {
    if (index < Defaults.indexedColorCubeStart) return index;
    const map = [0, 4, 2, 6, 1, 5, 3, 7, 8, 12, 10, 14, 9, 13, 11, 15];
    final gray = index - Defaults.indexedColorGrayStart;
    if (gray >= 0 && gray < Defaults.indexedColorGrayCount) {
      return gray < 12 ? 8 : 15;
    }
    final cubeSize = Defaults.indexedColorCubeSize;
    final cube = index - Defaults.indexedColorCubeStart;
    final cubeR = cube ~/ (cubeSize * cubeSize);
    final cubeG = (cube % (cubeSize * cubeSize)) ~/ cubeSize;
    final cubeB = cube % cubeSize;
    final ansiR = cubeR < 3 ? 0 : 1;
    final ansiG = cubeG < 3 ? 0 : 1;
    final ansiB = cubeB < 3 ? 0 : 1;
    final ansiIdx = ansiR * 4 + ansiG * 2 + ansiB;
    final ansi = map[ansiIdx];
    final maxVal = [cubeR, cubeG, cubeB]
        .where((v) => v >= 3)
        .fold(0, (a, b) => a > b ? a : b);
    return maxVal >= 5 ? ansi + 8 : ansi;
  }

  static double _redmeanDistance(
    int r1,
    int g1,
    int b1,
    int r2,
    int g2,
    int b2,
  ) {
    final rBar = (r1 + r2) ~/ 2;
    final dr = r1 - r2;
    final dg = g1 - g2;
    final db = b1 - b2;
    return (2 + rBar / 256) * dr * dr +
        4 * dg * dg +
        (2 + (255 - rBar) / 256) * db * db;
  }

  static const int _cubeStep =
      Defaults.rgbComponentMax ~/ (Defaults.indexedColorCubeSize - 1);
  static const int _grayStep = 10;
  static const int _grayBase = 8;
}
