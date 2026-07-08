
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

/// An exact RGB terminal color.
extension type const Color._((int, int, int) _rgb) {
  /// Creates an RGB color with components in the range 0–255.
  ///
  /// Components above 255 are clamped to 255; values below 0 are passed
  /// through unchanged (callers are expected to supply non-negative inputs).
  const Color({int red = 0, int green = 0, int blue = 0})
    : _rgb = (
        red > _rgbComponentMax ? _rgbComponentMax : red,
        green > _rgbComponentMax ? _rgbComponentMax : green,
        blue > _rgbComponentMax ? _rgbComponentMax : blue,
      );

  /// Black.
  const factory Color.black() = Color._black;
  const Color._black() : this(red: 0, green: 0, blue: 0);

  /// Red.
  const factory Color.red() = Color._red;
  const Color._red() : this(red: 153, green: 0, blue: 0);

  /// Green.
  const factory Color.green() = Color._green;
  const Color._green() : this(red: 0, green: 153, blue: 0);

  /// Yellow.
  const factory Color.yellow() = Color._yellow;
  const Color._yellow() : this(red: 153, green: 153, blue: 0);

  /// Blue.
  const factory Color.blue() = Color._blue;
  const Color._blue() : this(red: 0, green: 0, blue: 153);

  /// Magenta.
  const factory Color.magenta() = Color._magenta;
  const Color._magenta() : this(red: 153, green: 0, blue: 153);

  /// Cyan.
  const factory Color.cyan() = Color._cyan;
  const Color._cyan() : this(red: 0, green: 153, blue: 153);

  /// White.
  const factory Color.white() = Color._white;
  const Color._white() : this(red: 153, green: 153, blue: 153);

  /// Bright black.
  const factory Color.brightBlack() = Color._brightBlack;
  const Color._brightBlack() : this(red: 68, green: 68, blue: 68);

  /// Bright red.
  const factory Color.brightRed() = Color._brightRed;
  const Color._brightRed() : this(red: 255, green: 0, blue: 0);

  /// Bright green.
  const factory Color.brightGreen() = Color._brightGreen;
  const Color._brightGreen() : this(red: 0, green: 255, blue: 0);

  /// Bright yellow.
  const factory Color.brightYellow() = Color._brightYellow;
  const Color._brightYellow() : this(red: 255, green: 255, blue: 0);

  /// Bright blue.
  const factory Color.brightBlue() = Color._brightBlue;
  const Color._brightBlue() : this(red: 0, green: 0, blue: 255);

  /// Bright magenta.
  const factory Color.brightMagenta() = Color._brightMagenta;
  const Color._brightMagenta() : this(red: 255, green: 0, blue: 255);

  /// Bright cyan.
  const factory Color.brightCyan() = Color._brightCyan;
  const Color._brightCyan() : this(red: 0, green: 255, blue: 255);

  /// Bright white.
  const factory Color.brightWhite() = Color._brightWhite;
  const Color._brightWhite() : this(red: 255, green: 255, blue: 255);

  /// The red component (0–255).
  int get red => _rgb.$1;

  /// The green component (0–255).
  int get green => _rgb.$2;

  /// The blue component (0–255).
  int get blue => _rgb.$3;
}

const int _rgbComponentMax = 255;
