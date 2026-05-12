import '../well_known.dart' show WellKnown;
import 'engine.dart';
import 'events.dart';

/// Interprets parsed OSC sequences into terminal events
final class OscParser {
  /// Parses an OSC sequence into an Event, or null if unrecognized
  Event? parse(OscSequenceData data) {
    final content = data.content;
    final semicolon = content.indexOf(';');
    if (semicolon == -1) return null;

    final pnStr = content.substring(0, semicolon);
    final pn = int.tryParse(pnStr);
    if (pn == null) return null;

    final value = content.substring(semicolon + 1);

    return switch (pn) {
      WellKnown.oscTitle || 1 || 2 => InternalEvent('title_changed', {'title': value}),
      WellKnown.oscHyperlink => _parseHyperlink(value),
      WellKnown.oscFgQuery => _parseColor(value, WellKnown.oscFgQuery),
      WellKnown.oscBgQuery => _parseColor(value, WellKnown.oscBgQuery),
      WellKnown.oscClipboard => _parseClipboard(value),
      _ => null,
    };
  }

  InternalEvent? _parseHyperlink(String value) {
    final firstSemicolon = value.indexOf(';');
    if (firstSemicolon == -1) return null;
    final uri = value.substring(firstSemicolon + 1);
    return InternalEvent('hyperlink', {'uri': uri});
  }

  ClipboardEvent? _parseClipboard(String value) {
    final semicolon = value.indexOf(';');
    if (semicolon == -1) return null;
    final clipboard = value.substring(0, semicolon);
    final base64 = value.substring(semicolon + 1);
    return ClipboardEvent(clipboard, base64.isEmpty ? null : base64);
  }

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
