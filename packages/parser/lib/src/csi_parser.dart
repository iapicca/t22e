import 'package:protocol/protocol.dart' show Defaults;
import 'engine.dart';
import 'events.dart';

/// Parses CSI sequences into events.
Event? parseCsi(SequenceData data) {
  final sequenceData = data as CsiSequenceData;
  final params = sequenceData.params;
  final intermediates = sequenceData.intermediates;
  final finalByte = sequenceData.finalByte;

  if (intermediates.contains(Defaults.csiExtendedIntermediate)) {
    return _parseCsiExtended(params, finalByte);
  }

  if (intermediates.contains(Defaults.csiKittyQueryIntermediate) &&
      finalByte == Defaults.csiFinalKittyKey) {
    return _parseCsiKittyKeyboard(params);
  }

  return switch (finalByte) {
    Defaults.csiFinalUp => _createCsiKeyEvent(KeyCode.up, params),
    Defaults.csiFinalDown => _createCsiKeyEvent(KeyCode.down, params),
    Defaults.csiFinalRight => _createCsiKeyEvent(KeyCode.right, params),
    Defaults.csiFinalLeft => _createCsiKeyEvent(KeyCode.left, params),
    Defaults.csiFinalHome => _createCsiKeyEvent(KeyCode.home, params),
    Defaults.csiFinalEnd => _createCsiKeyEvent(KeyCode.end, params),
    Defaults.csiFinalF1 => _createCsiFKeyEvent(1, params),
    Defaults.csiFinalF2 => _createCsiFKeyEvent(2, params),
    Defaults.csiFinalCursorPos when params.length >= 2 => CursorPositionEvent(
      params[0],
      params[1],
    ),
    Defaults.csiFinalCursorPos => _createCsiFKeyEvent(3, params),
    Defaults.csiFinalF4 => _createCsiFKeyEvent(4, params),
    Defaults.csiFinalTilde => _parseCsiTildeKey(params),
    Defaults.csiFinalMouse => _parseCsiSgrMouse(params),
    Defaults.csiFinalDA
        when intermediates.contains(Defaults.csiKittyQueryIntermediate) =>
      PrimaryDeviceAttributesEvent(
        List.unmodifiable(params.length >= 2 ? params.sublist(1) : params),
      ),
    _ => null,
  };
}

/// Parses tilde-terminated key sequences.
Event? _parseCsiTildeKey(List<int> params) {
  if (params.isEmpty) return null;
  final code = params[0];
  return switch (code) {
    1 || 7 => _createCsiKeyEvent(KeyCode.home, params),
    4 || 8 => _createCsiKeyEvent(KeyCode.end, params),
    5 => _createCsiKeyEvent(KeyCode.pageUp, params),
    6 => _createCsiKeyEvent(KeyCode.pageDown, params),
    2 => _createCsiKeyEvent(KeyCode.insert, params),
    3 => _createCsiKeyEvent(KeyCode.delete, params),
    11 => _createCsiFKeyEvent(1, params),
    12 => _createCsiFKeyEvent(2, params),
    13 => _createCsiFKeyEvent(3, params),
    14 => _createCsiFKeyEvent(4, params),
    15 => _createCsiFKeyEvent(5, params),
    17 => _createCsiFKeyEvent(6, params),
    18 => _createCsiFKeyEvent(7, params),
    19 => _createCsiFKeyEvent(8, params),
    20 => _createCsiFKeyEvent(9, params),
    21 => _createCsiFKeyEvent(10, params),
    23 => _createCsiFKeyEvent(11, params),
    24 => _createCsiFKeyEvent(12, params),
    _ => null,
  };
}

/// Parses extended CSI sequences with intermediate bytes.
Event? _parseCsiExtended(List<int> params, int finalByte) {
  if (finalByte == Defaults.csiFinalMouse && params.length >= 3) {
    return _parseCsiSgrMouseParams(params);
  }
  return null;
}

/// Parses Kitty keyboard protocol sequences.
Event? _parseCsiKittyKeyboard(List<int> params) {
  if (params.isEmpty) return null;
  final code = params[0];
  final modifiers = params.length > 1 ? params[1] : 0;
  final eventType = params.length > 2 ? params[2] : 0;

  final keyModifiers = _kittyModifiersFromBits(modifiers);
  final type = eventType == 2
      ? KeyEventType.up
      : (eventType == 3 ? KeyEventType.repeat : KeyEventType.down);

  if (code >= Defaults.byteRangePrintableLow &&
      code <= Defaults.byteRangePrintableHigh) {
    return KeyEvent(
      keyCode: KeyCode.char,
      modifiers: keyModifiers,
      type: type,
      codepoint: code,
    );
  }

  final mappedKeyCode = _kittyKeyCodeMap[code];
  if (mappedKeyCode != null) {
    return KeyEvent(
      keyCode: mappedKeyCode,
      modifiers: keyModifiers,
      type: type,
    );
  }

  return null;
}

const _kittyKeyCodeMap = <int, KeyCode>{
  Defaults.kittyKeyEscape: KeyCode.escape,
  Defaults.kittyKeyTab: KeyCode.tab,
  Defaults.kittyKeyEnter: KeyCode.enter,
  Defaults.kittyKeyBackspace: KeyCode.backspace,
  Defaults.kittyKeyBackspaceAlt: KeyCode.backspace,
  Defaults.kittyKeyHome: KeyCode.home,
  Defaults.kittyKeyEnd: KeyCode.end,
  Defaults.kittyKeyPageUp: KeyCode.pageUp,
  Defaults.kittyKeyPageDown: KeyCode.pageDown,
  Defaults.kittyKeyInsert: KeyCode.insert,
  Defaults.kittyKeyDelete: KeyCode.delete,
  Defaults.kittyKeyDeleteAlt: KeyCode.delete,
};

KeyModifiers _kittyModifiersFromBits(int mod) {
  return KeyModifiers(
    shift: (mod & Defaults.modShift) != 0,
    alt: (mod & Defaults.modAlt) != 0,
    ctrl: (mod & Defaults.modCtrl) != 0,
    meta: (mod & Defaults.modMeta) != 0,
  );
}

Event? _parseCsiSgrMouse(List<int> params) {
  if (params.length < 3) return null;
  return _parseCsiSgrMouseParams(params);
}

Event? _parseCsiSgrMouseParams(List<int> params) {
  final buttonCode = params[0];
  final column = params[1] - 1;
  final row = params[2] - 1;

  if (buttonCode == Defaults.mouseWheelUpCode) {
    return MouseEvent(
      button: MouseButton.wheelUp,
      action: MouseAction.press,
      x: column,
      y: row,
    );
  }
  if (buttonCode == Defaults.mouseWheelDownCode) {
    return MouseEvent(
      button: MouseButton.wheelDown,
      action: MouseAction.press,
      x: column,
      y: row,
    );
  }

  if ((buttonCode & Defaults.mouseDragBit) != 0 &&
      (buttonCode & Defaults.mouseButtonMask) != 3) {
    final button = _mouseButtonFromCode(buttonCode & Defaults.mouseButtonMask);
    return MouseEvent(
      button: button,
      action: MouseAction.drag,
      x: column,
      y: row,
    );
  }

  if ((buttonCode & Defaults.mouseDragBit) != 0) {
    return MouseEvent(
      button: MouseButton.none,
      action: MouseAction.release,
      x: column,
      y: row,
    );
  }

  final button = _mouseButtonFromCode(buttonCode & Defaults.mouseButtonMask);
  return MouseEvent(
    button: button,
    action: MouseAction.press,
    x: column,
    y: row,
  );
}

MouseButton _mouseButtonFromCode(int code) {
  return switch (code) {
    0 => MouseButton.left,
    1 => MouseButton.middle,
    2 => MouseButton.right,
    _ => MouseButton.none,
  };
}

KeyEvent _createCsiKeyEvent(KeyCode code, List<int> params) {
  final mod = params.length > 1
      ? params[1]
      : (params.isNotEmpty ? params[0] : 1);
  return KeyEvent(keyCode: code, modifiers: _csiModifiersFromParam(mod));
}

KeyEvent _createCsiFKeyEvent(int number, List<int> params) {
  final mod = params.length > 1 ? params[1] : 1;
  final code = KeyCode.values.firstWhere(
    (k) => k.index == KeyCode.f1.index + (number - 1),
    orElse: () => KeyCode.f1,
  );
  return KeyEvent(keyCode: code, modifiers: _csiModifiersFromParam(mod));
}

KeyModifiers _csiModifiersFromParam(int param) {
  return KeyModifiers(
    shift: (param & Defaults.modShift) != 0,
    alt: (param & Defaults.modAlt) != 0,
    ctrl: (param & Defaults.modCtrl) != 0,
    meta: (param & Defaults.modMeta) != 0,
  );
}
