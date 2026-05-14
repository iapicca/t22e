import 'package:protocol/protocol.dart' show Defaults;
import 'engine.dart';
import 'events.dart';

/// Parses DCS sequences (Kitty graphics protocol).
final class DcsParser {
  /// Dispatches a DCS sequence based on final byte and intermediates.
  Event? parse(SequenceData data) {
    final d = data as DcsSequenceData;
    if (d.finalByte == Defaults.dcsKittyGraphicsP &&
        d.intermediates.contains(Defaults.dcsKittyIntermediate)) {
      return InternalEvent('kitty_graphics');
    }

    if (d.finalByte == Defaults.dcsKittyGraphicsQ &&
        d.intermediates.contains(Defaults.dcsKittyIntermediate)) {
      return InternalEvent('kitty_graphics');
    }

    return null;
  }
}
