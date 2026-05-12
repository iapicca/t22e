import '../well_known.dart' show WellKnown;
import 'engine.dart';
import 'events.dart';

/// Interprets parsed ESC sequences into terminal events
final class EscParser {
  /// Parses an ESC sequence into an Event, or null if unrecognized
  Event? parse(EscSequenceData data) {
    final intermediates = data.intermediates;
    final fb = data.finalByte;

    if (intermediates.contains(WellKnown.ss3Byte)) {
      return switch (fb) {
        WellKnown.escSs3F1 => KeyEvent(keyCode: KeyCode.f1),
        WellKnown.escSs3F2 => KeyEvent(keyCode: KeyCode.f2),
        WellKnown.escSs3F3 => KeyEvent(keyCode: KeyCode.f3),
        WellKnown.escSs3F4 => KeyEvent(keyCode: KeyCode.f4),
        _ => null,
      };
    }

    if (intermediates.contains(WellKnown.ss3Byte) && fb == WellKnown.escSs3F3) {
      return KeyEvent(keyCode: KeyCode.f3);
    }

    return switch (fb) {
      WellKnown.escFinalReset => InternalEvent('reset'),
      WellKnown.escFinalSaveCursor => InternalEvent('screen_save'),
      WellKnown.escFinalRestoreCursor => InternalEvent('screen_restore'),
      WellKnown.escFinalScrollReverse => InternalEvent('scroll_reverse'),
      _ => null,
    };
  }
}
