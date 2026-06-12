import 'package:protocol/protocol.dart' show Defaults;
import 'engine.dart';
import 'events.dart';

/// Parses ESC sequences into events (SS3 keys, reset, screen save/restore, scroll).
Event? parseEsc(SequenceData data) {
  final sequenceData = data as EscSequenceData;
  final intermediates = sequenceData.intermediates;
  final finalByte = sequenceData.finalByte;

  if (intermediates.contains(Defaults.ss3Byte)) {
    return switch (finalByte) {
      Defaults.escSs3F1 => KeyEvent(keyCode: KeyCode.f1),
      Defaults.escSs3F2 => KeyEvent(keyCode: KeyCode.f2),
      Defaults.escSs3F3 => KeyEvent(keyCode: KeyCode.f3),
      Defaults.escSs3F4 => KeyEvent(keyCode: KeyCode.f4),
      _ => null,
    };
  }

  return switch (finalByte) {
    Defaults.escFinalReset => InternalEvent(Defaults.internalEventReset),
    Defaults.escFinalSaveCursor => InternalEvent(
      Defaults.internalEventScreenSave,
    ),
    Defaults.escFinalRestoreCursor => InternalEvent(
      Defaults.internalEventScreenRestore,
    ),
    Defaults.escFinalScrollReverse => InternalEvent(
      Defaults.internalEventScrollReverse,
    ),
    _ => null,
  };
}
