import 'package:meta/meta.dart' show internal;

/// Byte constants used while parsing terminal input.
///
/// File-scoped: every consumer of these constants lives in
/// `ansi_parser.dart`. When a constant gains a second consumer it is
/// promoted to the project-scoped `t22eSymbols` class.
@internal
final class AnsiParserSymbols {
  const AnsiParserSymbols();

  /// ESC introducer.
  static const int esc = 0x1B;

  /// CSI introducer `'['`.
  static const int csiIntroducer = 0x5B;

  /// SS3 introducer `'O'`.
  static const int ss3Introducer = 0x4F;

  /// Ctrl+C.
  static const int ctrlC = 0x03;

  /// Ctrl+D.
  static const int ctrlD = 0x04;

  /// Horizontal tab.
  static const int tab = 0x09;

  /// Return / Enter.
  static const int enter = 0x0D;

  /// DEL.
  static const int del = 0x7F;

  /// CSI final byte for arrow up (`A`).
  static const int csiUp = 0x41;

  /// CSI final byte for arrow down (`B`).
  static const int csiDown = 0x42;

  /// CSI final byte for arrow right (`C`).
  static const int csiRight = 0x43;

  /// CSI final byte for arrow left (`D`).
  static const int csiLeft = 0x44;

  /// CSI final byte for home (`H`).
  static const int csiHome = 0x48;

  /// CSI final byte for end (`F`).
  static const int csiEnd = 0x46;

  /// CSI final byte for tilde sequences (`~`).
  static const int csiTilde = 0x7E;
}