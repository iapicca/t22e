/// Interface for toggling terminal raw mode.
abstract class RawModeBackend {
  const RawModeBackend();

  /// Enables raw mode on the terminal.
  void enable();

  /// Restores the terminal to its previous mode.
  void disable();
}
