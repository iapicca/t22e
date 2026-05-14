import 'package:protocol/protocol.dart' show Defaults;
import 'engine.dart';
import 'events.dart';

/// Parses ESC sequences (SS3 function keys, reset, save/restore screen).
final class EscParser {
  /// Dispatches an ESC sequence to the appropriate handler.
  Event? parse(SequenceData data) {
    final d = data as EscSequenceData;
    final intermediates = d.intermediates;
    final fb = d.finalByte;

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
