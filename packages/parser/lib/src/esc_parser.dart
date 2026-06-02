import 'package:meta/meta.dart';
import 'package:protocol/protocol.dart' show Defaults;
import 'engine.dart';
import 'events.dart';

@internal
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
    Defaults.escFinalReset => InternalEvent('reset'),
    Defaults.escFinalSaveCursor => InternalEvent('screen_save'),
    Defaults.escFinalRestoreCursor => InternalEvent('screen_restore'),
    Defaults.escFinalScrollReverse => InternalEvent('scroll_reverse'),
    _ => null,
  };
}
