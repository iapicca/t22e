import 'package:meta/meta.dart';
import 'package:protocol/protocol.dart' show Defaults;
import 'engine.dart';
import 'events.dart';

@internal
Event? parseDcs(SequenceData data) {
  final sequenceData = data as DcsSequenceData;
  final finalByte = sequenceData.finalByte;
  final intermediates = sequenceData.intermediates;

  if (finalByte == Defaults.dcsKittyGraphicsP &&
      intermediates.contains(Defaults.dcsKittyIntermediate)) {
    return InternalEvent('kitty_graphics');
  }

  if (finalByte == Defaults.dcsKittyGraphicsQ &&
      intermediates.contains(Defaults.dcsKittyIntermediate)) {
    return InternalEvent('kitty_graphics');
  }

  return null;
}
