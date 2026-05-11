import 'package:protocol/protocol.dart' show Defaults;
import 'engine.dart';
import 'events.dart';

final class EscParser {
  Event? parse(EscSequenceData data) {
    final intermediates = data.intermediates;
    final fb = data.finalByte;

    if (intermediates.contains(Defaults.ss3Byte)) {
      return switch (fb) {
        Defaults.escSs3F1 => KeyEvent(keyCode: KeyCode.f1),
        Defaults.escSs3F2 => KeyEvent(keyCode: KeyCode.f2),
        Defaults.escSs3F3 => KeyEvent(keyCode: KeyCode.f3),
        Defaults.escSs3F4 => KeyEvent(keyCode: KeyCode.f4),
        _ => null,
      };
    }

    if (intermediates.contains(Defaults.ss3Byte) && fb == Defaults.escSs3F3) {
      return KeyEvent(keyCode: KeyCode.f3);
    }

    return switch (fb) {
      Defaults.escFinalReset => InternalEvent('reset'),
      Defaults.escFinalSaveCursor => InternalEvent('screen_save'),
      Defaults.escFinalRestoreCursor => InternalEvent('screen_restore'),
      Defaults.escFinalScrollReverse => InternalEvent('scroll_reverse'),
      _ => null,
    };
  }
}
