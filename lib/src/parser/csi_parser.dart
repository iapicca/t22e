import '../well_known.dart' show WellKnown;
import 'engine.dart';
import 'events.dart';

/// Interprets parsed CSI sequences into higher-level terminal events
final class CsiParser {
  /// Parses a CSI sequence into an Event, or null if unrecognized
  Event? parse(CsiSequenceData data) {
    final params = data.params;
    final intermediates = data.intermediates;
    final fb = data.finalByte;

    if (intermediates.contains(WellKnown.csiExtendedIntermediate)) {
      return _parseExtended(params, fb);
    }

    if (intermediates.contains(WellKnown.csiKittyQueryIntermediate) && fb == WellKnown.csiFinalKittyKey) {
      return _parseKittyKey(params);
    }

    return switch (fb) {
      WellKnown.csiFinalUp => _keyEvent(KeyCode.up, params),
      WellKnown.csiFinalDown => _keyEvent(KeyCode.down, params),
      WellKnown.csiFinalRight => _keyEvent(KeyCode.right, params),
      WellKnown.csiFinalLeft => _keyEvent(KeyCode.left, params),
      WellKnown.csiFinalHome => _keyEvent(KeyCode.home, params),
      WellKnown.csiFinalEnd => _keyEvent(KeyCode.end, params),
      WellKnown.csiFinalF1 => _fKey(1, params),
      WellKnown.csiFinalF2 => _fKey(2, params),
      WellKnown.csiFinalCursorPos when params.length >= 2 => CursorPositionEvent(params[0], params[1]),
      WellKnown.csiFinalCursorPos => _fKey(3, params),
      WellKnown.csiFinalF4 => _fKey(4, params),
      WellKnown.csiFinalTilde => _parseTilde(params),
      WellKnown.csiFinalMouse => _parseSgrMouse(params),
      WellKnown.csiFinalDA when intermediates.contains(WellKnown.csiKittyQueryIntermediate) =>
          PrimaryDeviceAttributesEvent(List.unmodifiable(params.length >= 2 ? params.sublist(1) : params)),
      _ => null,
    };
  }

  /// Parses tilde-encoded key sequences (e.g. ~1=Home)
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

  /// Parses extended CSI sequences (intermediate '<')
  Event? _parseExtended(List<int> params, int fb) {
    if (fb == WellKnown.csiFinalMouse && params.length >= 3) {
      return _parseSgrMouseParams(params);
    }
    return null;
  }

  /// Parses a Kitty keyboard protocol key event
  Event? _parseKittyKey(List<int> params) {
    if (params.isEmpty) return null;
    final code = params[0];
    final modifiers = params.length > 1 ? params[1] : 0;
    final eventType = params.length > 2 ? params[2] : 0;

    final mods = _kittyModifiers(modifiers);
    final type = eventType == 2 ? KeyEventType.up : (eventType == 3 ? KeyEventType.repeat : KeyEventType.down);

    if (code >= WellKnown.byteRangePrintableLow && code <= WellKnown.byteRangePrintableHigh) {
      return KeyEvent(keyCode: KeyCode.char, modifiers: mods, type: type, codepoint: code);
    }

    final mapped = _kittyCodeMap[code];
    if (mapped != null) {
      return KeyEvent(keyCode: mapped, modifiers: mods, type: type);
    }

    return null;
  }

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

  /// Creates KeyModifiers from Kitty modifier bitmask
  KeyModifiers _kittyModifiers(int mod) {
    return KeyModifiers(
      shift: (mod & WellKnown.modShift) != 0,
      alt: (mod & WellKnown.modAlt) != 0,
      ctrl: (mod & WellKnown.modCtrl) != 0,
      meta: (mod & WellKnown.modMeta) != 0,
    );
  }

  /// Parses SGR mouse sequence parameters into a MouseEvent
  Event? _parseSgrMouse(List<int> params) {
    if (params.length < 3) return null;
    return _parseSgrMouseParams(params);
  }

  /// Parses SGR mouse parameters (shared by normal and extended paths)
  Event? _parseSgrMouseParams(List<int> params) {
    final cb = params[0];
    final x = params[1] - 1;
    final y = params[2] - 1;

    if (cb == WellKnown.mouseWheelUpCode) return MouseEvent(button: MouseButton.wheelUp, action: MouseAction.press, x: x, y: y);
    if (cb == WellKnown.mouseWheelDownCode) return MouseEvent(button: MouseButton.wheelDown, action: MouseAction.press, x: x, y: y);

    if ((cb & WellKnown.mouseDragBit) != 0 && (cb & WellKnown.mouseButtonMask) != 3) {
      final button = _mouseButtonFromCode(cb & WellKnown.mouseButtonMask);
      return MouseEvent(button: button, action: MouseAction.drag, x: x, y: y);
    }

    if ((cb & WellKnown.mouseDragBit) != 0) {
      return MouseEvent(button: MouseButton.none, action: MouseAction.release, x: x, y: y);
    }

    final button = _mouseButtonFromCode(cb & WellKnown.mouseButtonMask);
    return MouseEvent(button: button, action: MouseAction.press, x: x, y: y);
  }

  /// Maps a button code (0-2) to the MouseButton enum
  MouseButton _mouseButtonFromCode(int code) {
    return switch (code) {
      0 => MouseButton.left,
      1 => MouseButton.middle,
      2 => MouseButton.right,
      _ => MouseButton.none,
    };
  }

  /// Creates a KeyEvent from a key code and modifier parameter
  KeyEvent _keyEvent(KeyCode code, List<int> params) {
    final mod = params.length > 1 ? params[1] : (params.isNotEmpty ? params[0] : 1);
    return KeyEvent(keyCode: code, modifiers: _modifiersFromParam(mod));
  }

  /// Creates a KeyEvent for function key Fn
  KeyEvent _fKey(int n, List<int> params) {
    final mod = params.length > 1 ? params[1] : 1;
    final code = KeyCode.values.firstWhere(
      (k) => k.index == KeyCode.f1.index + (n - 1),
      orElse: () => KeyCode.f1,
    );
    return KeyEvent(keyCode: code, modifiers: _modifiersFromParam(mod));
  }

  /// Extracts KeyModifiers from a modifier parameter value
  KeyModifiers _modifiersFromParam(int param) {
    return KeyModifiers(
      shift: (param & WellKnown.modShift) != 0,
      alt: (param & WellKnown.modAlt) != 0,
      ctrl: (param & WellKnown.modCtrl) != 0,
      meta: (param & WellKnown.modMeta) != 0,
    );
  }
}
