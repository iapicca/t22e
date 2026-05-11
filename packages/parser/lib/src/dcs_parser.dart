import 'package:protocol/protocol.dart' show Defaults;
import 'engine.dart';
import 'events.dart';

final class DcsParser {
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
