import 'package:core/core.dart' show ColorProfile;
import 'package:protocol/protocol.dart' show Defaults;

/// Sealed base class for probe results (Supported or Unavailable).
sealed class QueryResult<T> {
  const QueryResult();
}

/// A successful probe result with a value.
final class Supported<T> extends QueryResult<T> {
  /// The probe result value.
  final T value;
  const Supported(this.value);
}

/// An unsuccessful probe result (e.g. timed out).
final class Unavailable<T> extends QueryResult<T> {
  const Unavailable();
}

/// Parsed DA1 response: terminal ID and attribute list.
class Da1Result {
  /// Terminal model ID.
  final int terminalId;
  /// Additional DA1 attributes.
  final List<int> attributes;
  const Da1Result(this.terminalId, this.attributes);
}

/// Supported keyboard protocol types.
enum KeyboardProtocol { basic, kitty }

/// Complete terminal capability information gathered by the pipeline.
class Capabilities {
  /// DA1 device attributes result.
  final QueryResult<Da1Result> da1;
  /// Detected color profile.
  final ColorProfile colorProfile;
  /// Whether synchronized updates (DECSET 2026) are supported.
  final bool syncSupported;
  /// Detected keyboard protocol.
  final KeyboardProtocol keyboardProtocol;
  /// Terminal height in rows.
  final int rows;
  /// Terminal width in columns.
  final int cols;

  const Capabilities({
    this.da1 = const Unavailable(),
    this.colorProfile = ColorProfile.ansi16,
    this.syncSupported = false,
    this.keyboardProtocol = KeyboardProtocol.basic,
    this.rows = Defaults.defaultTerminalHeight,
    this.cols = Defaults.defaultTerminalWidth,
  });
}
