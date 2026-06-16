import 'package:protocol/protocol.dart' show ControlBytes;
import 'esc_finals.dart';
import 'internal_events.dart';
import 'sequence_data.dart';
import 'events.dart';

/// Parses ESC sequences into events (SS3 keys, reset, screen save/restore, scroll).
Event? parseEsc(SequenceData data) {
  final sequenceData = data as EscSequenceData;
  final intermediates = sequenceData.intermediates;
  final finalByte = sequenceData.finalByte;

  if (intermediates.contains(ControlBytes.ss3Byte)) {
    return switch (finalByte) {
      EscFinals.escSs3F1 => KeyEvent(keyCode: KeyCode.f1),
      EscFinals.escSs3F2 => KeyEvent(keyCode: KeyCode.f2),
      EscFinals.escSs3F3 => KeyEvent(keyCode: KeyCode.f3),
      EscFinals.escSs3F4 => KeyEvent(keyCode: KeyCode.f4),
      _ => null,
    };
  }

  return switch (finalByte) {
    EscFinals.escFinalReset => InternalEvent(InternalEvents.internalEventReset),
    EscFinals.escFinalSaveCursor => InternalEvent(
      InternalEvents.internalEventScreenSave,
    ),
    EscFinals.escFinalRestoreCursor => InternalEvent(
      InternalEvents.internalEventScreenRestore,
    ),
    EscFinals.escFinalScrollReverse => InternalEvent(
      InternalEvents.internalEventScrollReverse,
    ),
    _ => null,
  };
}
