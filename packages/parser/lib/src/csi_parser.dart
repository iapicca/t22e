import 'package:protocol/protocol.dart' show Defaults;
import 'engine.dart';
import 'events.dart';

/// Parses CSI sequences into key, mouse, and response events.
final class CsiParser {
  /// Dispatches a CSI sequence to the appropriate handler by final byte.
  Event? parse(SequenceData data) {
    final d = data as CsiSequenceData;
    final params = d.params;
    final intermediates = d.intermediates;
    final fb = d.finalByte;

    if (intermediates.contains(Defaults.csiExtendedIntermediate)) {
      return _parseExtended(params, fb);
    }

    if (intermediates.contains(Defaults.csiKittyQueryIntermediate) &&
        fb == Defaults.csiFinalKittyKey) {
      return _parseKittyKey(params);
    }

    return switch (fb) {
      Defaults.csiFinalUp => _keyEvent(KeyCode.up, params),
      Defaults.csiFinalDown => _keyEvent(KeyCode.down, params),
      Defaults.csiFinalRight => _keyEvent(KeyCode.right, params),
      Defaults.csiFinalLeft => _keyEvent(KeyCode.left, params),
      Defaults.csiFinalHome => _keyEvent(KeyCode.home, params),
      Defaults.csiFinalEnd => _keyEvent(KeyCode.end, params),
      Defaults.csiFinalF1 => _fKey(1, params),
      Defaults.csiFinalF2 => _fKey(2, params),
      Defaults.csiFinalCursorPos when params.length >= 2 => CursorPositionEvent(
        params[0],
        params[1],
      ),
      Defaults.csiFinalCursorPos => _fKey(3, params),
      Defaults.csiFinalF4 => _fKey(4, params),
      Defaults.csiFinalTilde => _parseTilde(params),
      Defaults.csiFinalMouse => _parseSgrMouse(params),
      Defaults.csiFinalDA
          when intermediates.contains(Defaults.csiKittyQueryIntermediate) =>
        PrimaryDeviceAttributesEvent(
          List.unmodifiable(params.length >= 2 ? params.sublist(1) : params),
        ),
      _ => null,
    };
  }

  /// Parses tilde-encoded function key sequences.
  Event? _parseTilde(List<int> params) {
    if (params.isEmpty) return null;
    final n = params[0];
    return switch (n) {
      1 || 7 => _keyEvent(KeyCode.home, params),
      4 || 8 => _keyEvent(KeyCode.end, params),
      5 => _keyEvent(KeyCode.pageUp, params),
      6 => _keyEvent(KeyCode.pageDown, params),
      2 => _keyEvent(KeyCode.insert, params),
      3 => _keyEvent(KeyCode.delete, params),
      11 => _fKey(1, params),
      12 => _fKey(2, params),
      13 => _fKey(3, params),
      14 => _fKey(4, params),
      15 => _fKey(5, params),
      17 => _fKey(6, params),
      18 => _fKey(7, params),
      19 => _fKey(8, params),
      20 => _fKey(9, params),
      21 => _fKey(10, params),
      23 => _fKey(11, params),
      24 => _fKey(12, params),
      _ => null,
    };
  }

  /// Parses extended CSI sequences (SGR mouse).
  Event? _parseExtended(List<int> params, int fb) {
    if (fb == Defaults.csiFinalMouse && params.length >= 3) {
      return _parseSgrMouseParams(params);
    }
    return null;
  }

  /// Parses Kitty keyboard protocol key events.
  Event? _parseKittyKey(List<int> params) {
    if (params.isEmpty) return null;
    final code = params[0];
    final modifiers = params.length > 1 ? params[1] : 0;
    final eventType = params.length > 2 ? params[2] : 0;

    final mods = _kittyModifiers(modifiers);
    final type = eventType == 2
        ? KeyEventType.up
        : (eventType == 3 ? KeyEventType.repeat : KeyEventType.down);

    if (code >= Defaults.byteRangePrintableLow &&
        code <= Defaults.byteRangePrintableHigh) {
      return KeyEvent(
        keyCode: KeyCode.char,
        modifiers: mods,
        type: type,
        codepoint: code,
      );
    }

    final mapped = _kittyCodeMap[code];
    if (mapped != null) {
      return KeyEvent(keyCode: mapped, modifiers: mods, type: type);
    }

    return null;
  }

  /// Mapping from Kitty key codes to logical KeyCodes.
  static const _kittyCodeMap = <int, KeyCode>{
    0x1B: KeyCode.escape,
    0x09: KeyCode.tab,
    0x0D: KeyCode.enter,
    0x08: KeyCode.backspace,
    0x7F: KeyCode.backspace,
    0x01: KeyCode.home,
    0x04: KeyCode.end,
    0x05: KeyCode.pageUp,
    0x06: KeyCode.pageDown,
    0x02: KeyCode.insert,
    0x03: KeyCode.delete,
    0x1A: KeyCode.delete,
  };

  /// Extracts KeyModifiers from Kitty modifier bits.
  KeyModifiers _kittyModifiers(int mod) {
    return KeyModifiers(
      shift: (mod & Defaults.modShift) != 0,
      alt: (mod & Defaults.modAlt) != 0,
      ctrl: (mod & Defaults.modCtrl) != 0,
      meta: (mod & Defaults.modMeta) != 0,
    );
  }

  /// Parses SGR mouse events from CSI params.
  Event? _parseSgrMouse(List<int> params) {
    if (params.length < 3) return null;
    return _parseSgrMouseParams(params);
  }

  /// Shared SGR mouse parsing logic.
  Event? _parseSgrMouseParams(List<int> params) {
    final cb = params[0];
    final x = params[1] - 1;
    final y = params[2] - 1;

    if (cb == Defaults.mouseWheelUpCode)
      return MouseEvent(
        button: MouseButton.wheelUp,
        action: MouseAction.press,
        x: x,
        y: y,
      );
    if (cb == Defaults.mouseWheelDownCode)
      return MouseEvent(
        button: MouseButton.wheelDown,
        action: MouseAction.press,
        x: x,
        y: y,
      );

    if ((cb & Defaults.mouseDragBit) != 0 &&
        (cb & Defaults.mouseButtonMask) != 3) {
      final button = _mouseButtonFromCode(cb & Defaults.mouseButtonMask);
      return MouseEvent(button: button, action: MouseAction.drag, x: x, y: y);
    }

    if ((cb & Defaults.mouseDragBit) != 0) {
      return MouseEvent(
        button: MouseButton.none,
        action: MouseAction.release,
        x: x,
        y: y,
      );
    }

    final button = _mouseButtonFromCode(cb & Defaults.mouseButtonMask);
    return MouseEvent(button: button, action: MouseAction.press, x: x, y: y);
  }

  /// Converts a mouse button code to MouseButton enum.
  MouseButton _mouseButtonFromCode(int code) {
    return switch (code) {
      0 => MouseButton.left,
      1 => MouseButton.middle,
      2 => MouseButton.right,
      _ => MouseButton.none,
    };
  }

  /// Creates a KeyEvent from a key code and CSI params (with modifiers).
  KeyEvent _keyEvent(KeyCode code, List<int> params) {
    final mod = params.length > 1
        ? params[1]
        : (params.isNotEmpty ? params[0] : 1);
    return KeyEvent(keyCode: code, modifiers: _modifiersFromParam(mod));
  }

  /// Creates a KeyEvent for function key Fn.
  KeyEvent _fKey(int n, List<int> params) {
    final mod = params.length > 1 ? params[1] : 1;
    final code = KeyCode.values.firstWhere(
      (k) => k.index == KeyCode.f1.index + (n - 1),
      orElse: () => KeyCode.f1,
    );
    return KeyEvent(keyCode: code, modifiers: _modifiersFromParam(mod));
  }

  /// Extracts KeyModifiers from a CSI numeric parameter.
  KeyModifiers _modifiersFromParam(int param) {
    return KeyModifiers(
      shift: (param & Defaults.modShift) != 0,
      alt: (param & Defaults.modAlt) != 0,
      ctrl: (param & Defaults.modCtrl) != 0,
      meta: (param & Defaults.modMeta) != 0,
    );
  }
}
