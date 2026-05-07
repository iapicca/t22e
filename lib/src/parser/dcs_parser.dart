import 'engine.dart';
import 'events.dart';

final class DcsParser {
  Event? parse(DcsSequenceData data) {
    if (data.finalByte == 0x70 && data.intermediates.contains(0x2B)) {
      return InternalEvent('kitty_graphics');
    }

    if (data.finalByte == 0x71 && data.intermediates.contains(0x2B)) {
      return InternalEvent('kitty_graphics');
    }

    return null;
  }
}
