/// Central repository of FFI symbol name constants.
final class SymbolsFFI {
  SymbolsFFI._();

  // ── libc function names ──

  /// Symbol name for POSIX tcgetattr (read terminal attributes).
  static const String tcGetAttrName = 'tcgetattr';

  /// Symbol name for POSIX tcsetattr (set terminal attributes).
  static const String tcSetAttrName = 'tcsetattr';

  /// Symbol name for C malloc (allocate memory).
  static const String mallocName = 'malloc';

  /// Symbol name for C free (release memory).
  static const String freeName = 'free';

  // ── libc library paths ──

  /// macOS system library path.
  static const String libcMacOS = 'libSystem.dylib';

  /// Linux libc path (glibc 6).
  static const String libcLinux6 = 'libc.so.6';

  /// Linux libc path (glibc 7).
  static const String libcLinux7 = 'libc.so.7';
}
