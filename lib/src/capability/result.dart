import '../core/color.dart' show ColorProfile;
import '../well_known.dart' show WellKnown;

/// A sealed query result: either Supported with a value or Unavailable
sealed class QueryResult<T> {
  const QueryResult();
}

/// A successful terminal capability query with a concrete value
final class Supported<T> extends QueryResult<T> {
  final T value;
  const Supported(this.value);
}

/// A terminal capability that is not supported or timed out
final class Unavailable<T> extends QueryResult<T> {
  const Unavailable();
}

/// Result from a DA1 query: terminal ID and attribute list
class Da1Result {
  final int terminalId;
  final List<int> attributes;
  const Da1Result(this.terminalId, this.attributes);
}

/// Supported keyboard protocol: basic escape sequences or Kitty protocol
enum KeyboardProtocol { basic, kitty }

/// Complete set of detected terminal capabilities
class Capabilities {
  final QueryResult<Da1Result> da1;
  final ColorProfile colorProfile;
  final bool syncSupported;
  final KeyboardProtocol keyboardProtocol;
  final int rows;
  final int cols;

  const Capabilities({
    this.da1 = const Unavailable(),
    this.colorProfile = ColorProfile.ansi16,
    this.syncSupported = false,
    this.keyboardProtocol = KeyboardProtocol.basic,
    this.rows = WellKnown.defaultTerminalHeight,
    this.cols = WellKnown.defaultTerminalWidth,
  });
}
