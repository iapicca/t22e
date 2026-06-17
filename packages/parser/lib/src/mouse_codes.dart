/// Mouse event parsing constants.
final class MouseCodes {
  MouseCodes._();

  /// Encoded value for mouse wheel up.
  static const int mouseWheelUpCode = 64;

  /// Encoded value for mouse wheel down.
  static const int mouseWheelDownCode = 65;

  /// Mouse motion/drag indicator bit.
  static const int mouseDragBit = 32;

  /// Bitmask for extracting mouse button number.
  static const int mouseButtonMask = 3;
}
