import 'package:protocol/protocol.dart' show Defaults;
import 'engine.dart';
import 'events.dart';

/// Parses DCS sequences (Kitty graphics protocol).
final class DcsParser {
  /// Dispatches a DCS sequence based on final byte and intermediates.
  Event? parse(DcsSequenceData data) {
    if (data.finalByte == Defaults.dcsKittyGraphicsP &&
        data.intermediates.contains(Defaults.dcsKittyIntermediate)) {
      return InternalEvent('kitty_graphics');
    }

    if (data.finalByte == Defaults.dcsKittyGraphicsQ &&
        data.intermediates.contains(Defaults.dcsKittyIntermediate)) {
      return InternalEvent('kitty_graphics');
    }

    return null;
  }
}
