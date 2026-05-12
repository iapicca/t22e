import '../well_known.dart' show WellKnown;
import 'engine.dart';
import 'events.dart';

/// Interprets parsed DCS sequences into terminal events
final class DcsParser {
  /// Parses a DCS sequence into an Event, or null if unrecognized
  Event? parse(DcsSequenceData data) {
    if (data.finalByte == WellKnown.dcsKittyGraphicsP && data.intermediates.contains(WellKnown.dcsKittyIntermediate)) {
      return InternalEvent('kitty_graphics');
    }

    if (data.finalByte == WellKnown.dcsKittyGraphicsQ && data.intermediates.contains(WellKnown.dcsKittyIntermediate)) {
      return InternalEvent('kitty_graphics');
    }

    return null;
  }
}
