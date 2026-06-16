import 'dcs_codes.dart';
import 'internal_events.dart';
import 'sequence_data.dart';
import 'events.dart';

/// Parses DCS sequences into events (Kitty graphics).
/// TODO, where is the provider?
Event? parseDcs(SequenceData data) {
  final sequenceData = data as DcsSequenceData;
  final finalByte = sequenceData.finalByte;
  final intermediates = sequenceData.intermediates;

  if (finalByte == DcsCodes.dcsKittyGraphicsP &&
      intermediates.contains(DcsCodes.dcsKittyIntermediate)) {
    return InternalEvent(InternalEvents.internalEventKittyGraphics);
  }

  if (finalByte == DcsCodes.dcsKittyGraphicsQ &&
      intermediates.contains(DcsCodes.dcsKittyIntermediate)) {
    return InternalEvent(InternalEvents.internalEventKittyGraphics);
  }

  return null;
}
