import 'engine.dart';
import 'events.dart';

final class EscParser {
  Event? parse(EscSequenceData data) {
    final intermediates = data.intermediates;
    final fb = data.finalByte;

    if (intermediates.contains(0x4F)) {
      return switch (fb) {
        0x50 => KeyEvent(keyCode: KeyCode.f1),
        0x51 => KeyEvent(keyCode: KeyCode.f2),
        0x52 => KeyEvent(keyCode: KeyCode.f3),
        0x53 => KeyEvent(keyCode: KeyCode.f4),
        _ => null,
      };
    }

    if (intermediates.contains(0x4F) && fb == 0x52) {
      return KeyEvent(keyCode: KeyCode.f3);
    }

    return switch (fb) {
      0x63 => InternalEvent('reset'),
      0x37 => InternalEvent('screen_save'),
      0x38 => InternalEvent('screen_restore'),
      0x4D => InternalEvent('scroll_reverse'),
      _ => null,
    };
  }
}
