import 'package:core/core.dart' show ColorProfile;
import 'package:protocol/protocol.dart' show Defaults;

sealed class QueryResult<T> {
  const QueryResult();
}

final class Supported<T> extends QueryResult<T> {
  final T value;
  const Supported(this.value);
}

final class Unavailable<T> extends QueryResult<T> {
  const Unavailable();
}

class Da1Result {
  final int terminalId;
  final List<int> attributes;
  const Da1Result(this.terminalId, this.attributes);
}

enum KeyboardProtocol { basic, kitty }

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
    this.rows = Defaults.defaultTerminalHeight,
    this.cols = Defaults.defaultTerminalWidth,
  });
}
