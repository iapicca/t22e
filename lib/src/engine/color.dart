/// An ANSI 16-color code in the range 0–15.
extension type const AnsiColor._(int _code) {
  /// Creates a validated ANSI 16-color code.
  const AnsiColor({required this._code})
    : assert(_code >= 0 && _code <= _ansiColorMax, 'ANSI code out of range');

  /// The validated color code.
  int get code => _code;
}

const int _ansiColorMax = 15;

/// An indexed 256-color palette entry in the range 0–255.
extension type const IndexedColor._(int _index) {
  /// Creates a validated 256-color palette index.
  const IndexedColor({required this._index})
    : assert(
        _index >= 0 && _index < _indexedColorCount,
        'indexed color out of range',
      );

  /// The validated palette index.
  int get index => _index;
}

const int _indexedColorCount = 256;

// TODO: Add ColorSgr extension for ANSI SGR sequence generation.
// Reference implementation:
// https://raw.githubusercontent.com/iapicca/t22e/refs/heads/no_ffi/packages/core/lib/src/color.dart

/// An exact RGB terminal color.
extension type const Color._((int, int, int) _rgb) {
  /// Creates an RGB color with components in the range 0–255.
  const Color({int red = 0, int green = 0, int blue = 0})
    : assert(red >= 0 && red <= _rgbComponentMax, 'red out of range'),
      assert(green >= 0 && green <= _rgbComponentMax, 'green out of range'),
      assert(blue >= 0 && blue <= _rgbComponentMax, 'blue out of range'),
      _rgb = (red, green, blue);

  /// Black.
  const Color.black() : _rgb = (0, 0, 0);

  /// Red.
  const Color.red() : _rgb = (153, 0, 0);

  /// Green.
  const Color.green() : _rgb = (0, 153, 0);

  /// Yellow.
  const Color.yellow() : _rgb = (153, 153, 0);

  /// Blue.
  const Color.blue() : _rgb = (0, 0, 153);

  /// Magenta.
  const Color.magenta() : _rgb = (153, 0, 153);

  /// Cyan.
  const Color.cyan() : _rgb = (0, 153, 153);

  /// White.
  const Color.white() : _rgb = (153, 153, 153);

  /// Bright black.
  const Color.brightBlack() : _rgb = (68, 68, 68);

  /// Bright red.
  const Color.brightRed() : _rgb = (255, 0, 0);

  /// Bright green.
  const Color.brightGreen() : _rgb = (0, 255, 0);

  /// Bright yellow.
  const Color.brightYellow() : _rgb = (255, 255, 0);

  /// Bright blue.
  const Color.brightBlue() : _rgb = (0, 0, 255);

  /// Bright magenta.
  const Color.brightMagenta() : _rgb = (255, 0, 255);

  /// Bright cyan.
  const Color.brightCyan() : _rgb = (0, 255, 255);

  /// Bright white.
  const Color.brightWhite() : _rgb = (255, 255, 255);

  /// The red component (0–255).
  int get red => _rgb.$1;

  /// The green component (0–255).
  int get green => _rgb.$2;

  /// The blue component (0–255).
  int get blue => _rgb.$3;
}

const int _rgbComponentMax = 255;
