/// DCS (Device Control String) final and intermediate bytes.
final class DcsCodes {
  DcsCodes._();

  /// 'p' DCS final byte for Kitty graphics transmission.
  static const int dcsKittyGraphicsP = 0x70;

  /// 'q' DCS final byte for Kitty graphics query.
  static const int dcsKittyGraphicsQ = 0x71;

  /// '+' intermediate byte for Kitty DCS sequences.
  static const int dcsKittyIntermediate = 0x2B;
}
