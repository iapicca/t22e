/// Duration defaults for probes, animations, and terminal timing.
final class TimingDefaults {
  TimingDefaults._();

  /// Default timeout for capability probes.
  static const Duration defaultProbeTimeout = Duration(seconds: 1);

  /// Animation interval for spinner frames.
  static const Duration spinnerAnimInterval = Duration(milliseconds: 80);

  /// Animation interval for progress bar frames.
  static const Duration progressAnimInterval = Duration(milliseconds: 100);

  /// Blink interval for the text input cursor.
  static const Duration cursorBlinkInterval = Duration(milliseconds: 500);
}
