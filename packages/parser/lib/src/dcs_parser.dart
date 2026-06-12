import 'package:protocol/protocol.dart' show Defaults;
import 'sequence_data.dart';
import 'events.dart';

/// Parses DCS sequences into events (Kitty graphics).
Event? parseDcs(SequenceData data) {
  final sequenceData = data as DcsSequenceData;
  final finalByte = sequenceData.finalByte;
  final intermediates = sequenceData.intermediates;

  if (finalByte == Defaults.dcsKittyGraphicsP &&
      intermediates.contains(Defaults.dcsKittyIntermediate)) {
    return InternalEvent(Defaults.internalEventKittyGraphics);
  }

  if (finalByte == Defaults.dcsKittyGraphicsQ &&
      intermediates.contains(Defaults.dcsKittyIntermediate)) {
    return InternalEvent(Defaults.internalEventKittyGraphics);
  }

  return null;
}
