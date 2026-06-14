/// Environment variable keys and recognized value constants for
/// terminal capability detection.
final class Environment {
  Environment._();

  /// COLORTERM value indicating truecolor support.
  static const String envColortermTruecolor = 'truecolor';

  /// COLORTERM value indicating 24-bit support.
  static const String envColorterm24bit = '24bit';

  /// TERM suffix indicating 256-color terminal.
  static const String envTermSuffix256Color = '-256color';

  /// TERM suffix indicating truecolor terminal.
  static const String envTermSuffixTrueColor = '-truecolor';

  /// TERM suffix indicating direct color terminal.
  static const String envTermSuffixDirect = '-direct';

  /// COLORTERM environment variable key.
  static const String envKeyColorterm = 'COLORTERM';

  /// TERM environment variable key.
  static const String envKeyTerm = 'TERM';
}
