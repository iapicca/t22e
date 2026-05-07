import 'engine.dart';
import 'events.dart';

final class CsiParser {
  Event? parse(CsiSequenceData data) {
    final params = data.params;
    final intermediates = data.intermediates;
    final fb = data.finalByte;

    // CSI final bytes are ASCII characters
    if (intermediates.contains(0x3C)) {
      return _parseExtended(params, fb);
    }

    if (intermediates.contains(0x3E) && fb == 0x75) {
      return _parseKittyKey(params);
    }

    return switch (fb) {
      0x41 => _keyEvent(KeyCode.up, params),
      0x42 => _keyEvent(KeyCode.down, params),
      0x43 => _keyEvent(KeyCode.right, params),
      0x44 => _keyEvent(KeyCode.left, params),
      0x48 => _keyEvent(KeyCode.home, params),
      0x46 => _keyEvent(KeyCode.end, params),
      0x50 => _fKey(1, params),
      0x51 => _fKey(2, params),
      0x52 when params.length >= 2 => CursorPositionEvent(params[0], params[1]),
      0x52 => _fKey(3, params),
      0x53 => _fKey(4, params),
      0x7E => _parseTilde(params),
      0x4D => _parseSgrMouse(params),
      0x63 when intermediates.contains(0x3E) =>
          PrimaryDeviceAttributesEvent(List.unmodifiable(params.length >= 2 ? params.sublist(1) : params)),
      _ => null,
    };
  }

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

  Event? _parseExtended(List<int> params, int fb) {
    if (fb == 0x4D && params.length >= 3) {
      return _parseSgrMouseParams(params);
    }
    return null;
  }

  Event? _parseKittyKey(List<int> params) {
    if (params.isEmpty) return null;
    final code = params[0];
    final modifiers = params.length > 1 ? params[1] : 0;
    final eventType = params.length > 2 ? params[2] : 0;

    final mods = _kittyModifiers(modifiers);
    final type = eventType == 2 ? KeyEventType.up : (eventType == 3 ? KeyEventType.repeat : KeyEventType.down);

    if (code >= ' '.codeUnitAt(0) && code <= '~'.codeUnitAt(0)) {
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

  KeyModifiers _kittyModifiers(int mod) {
    return KeyModifiers(
      shift: (mod & 1) != 0,
      alt: (mod & 2) != 0,
      ctrl: (mod & 4) != 0,
      meta: (mod & 8) != 0,
    );
  }

  Event? _parseSgrMouse(List<int> params) {
    if (params.length < 3) return null;
    return _parseSgrMouseParams(params);
  }

  Event? _parseSgrMouseParams(List<int> params) {
    final cb = params[0];
    final x = params[1] - 1;
    final y = params[2] - 1;

    if (cb == 64) return MouseEvent(button: MouseButton.wheelUp, action: MouseAction.press, x: x, y: y);
    if (cb == 65) return MouseEvent(button: MouseButton.wheelDown, action: MouseAction.press, x: x, y: y);

    if ((cb & 32) != 0 && (cb & 3) != 3) {
      final button = _mouseButtonFromCode(cb & 3);
      return MouseEvent(button: button, action: MouseAction.drag, x: x, y: y);
    }

    if ((cb & 32) != 0) {
      return MouseEvent(button: MouseButton.none, action: MouseAction.release, x: x, y: y);
    }

    final button = _mouseButtonFromCode(cb & 3);
    return MouseEvent(button: button, action: MouseAction.press, x: x, y: y);
  }

  MouseButton _mouseButtonFromCode(int code) {
    return switch (code) {
      0 => MouseButton.left,
      1 => MouseButton.middle,
      2 => MouseButton.right,
      _ => MouseButton.none,
    };
  }

  KeyEvent _keyEvent(KeyCode code, List<int> params) {
    final mod = params.length > 1 ? params[1] : (params.isNotEmpty ? params[0] : 1);
    return KeyEvent(keyCode: code, modifiers: _modifiersFromParam(mod));
  }

  KeyEvent _fKey(int n, List<int> params) {
    final mod = params.length > 1 ? params[1] : 1;
    final code = KeyCode.values.firstWhere(
      (k) => k.index == KeyCode.f1.index + (n - 1),
      orElse: () => KeyCode.f1,
    );
    return KeyEvent(keyCode: code, modifiers: _modifiersFromParam(mod));
  }

  KeyModifiers _modifiersFromParam(int param) {
    return KeyModifiers(
      shift: (param & 1) != 0,
      alt: (param & 2) != 0,
      ctrl: (param & 4) != 0,
      meta: (param & 8) != 0,
    );
  }
}
