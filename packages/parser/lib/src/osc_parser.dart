import 'package:protocol/protocol.dart' show Defaults;
import 'engine.dart';
import 'events.dart';

/// Parses OSC sequences (title, hyperlink, color queries, clipboard).
final class OscParser {
  /// Dispatches an OSC sequence by parameter number.
  Event? parse(SequenceData data) {
    final content = (data as OscSequenceData).content;
    final semicolon = content.indexOf(';');
    if (semicolon == -1) return null;

    final pnStr = content.substring(0, semicolon);
    final pn = int.tryParse(pnStr);
    if (pn == null) return null;

    final value = content.substring(semicolon + 1);

    return switch (pn) {
      Defaults.oscTitle ||
      1 ||
      2 => InternalEvent('title_changed', {'title': value}),
      Defaults.oscHyperlink => _parseHyperlink(value),
      Defaults.oscFgQuery => _parseColor(value, Defaults.oscFgQuery),
      Defaults.oscBgQuery => _parseColor(value, Defaults.oscBgQuery),
      Defaults.oscClipboard => _parseClipboard(value),
      _ => null,
    };
  }

  /// Parses an OSC 8 hyperlink value (params;uri).
  InternalEvent? _parseHyperlink(String value) {
    final firstSemicolon = value.indexOf(';');
    if (firstSemicolon == -1) return null;
    final uri = value.substring(firstSemicolon + 1);
    return InternalEvent('hyperlink', {'uri': uri});
  }

  /// Parses an OSC 52 clipboard value.
  ClipboardEvent? _parseClipboard(String value) {
    final semicolon = value.indexOf(';');
    if (semicolon == -1) return null;
    final clipboard = value.substring(0, semicolon);
    final base64 = value.substring(semicolon + 1);
    return ClipboardEvent(clipboard, base64.isEmpty ? null : base64);
  }

  /// Parses an OSC 10/11 color query response (rgb:RR/GG/BB).
  ColorQueryEvent? _parseColor(String value, int colorNumber) {
    if (!value.startsWith('rgb:')) return null;

    final rgbParts = value.substring(4).split('/');
    if (rgbParts.length != 3) return null;

    try {
      final r = int.parse(rgbParts[0].substring(0, 2), radix: 16);
      final g = int.parse(rgbParts[1].substring(0, 2), radix: 16);
      final b = int.parse(rgbParts[2].substring(0, 2), radix: 16);
      return ColorQueryEvent(colorNumber, r, g, b);
    } catch (_) {
      return null;
    }
  }
}
