import 'package:meta/meta.dart';
import 'package:protocol/protocol.dart' show Defaults;
import 'engine.dart';
import 'events.dart';

@internal
Event? parseOsc(SequenceData data) {
  final sequenceData = data as OscSequenceData;
  final content = sequenceData.content;
  final semicolonIndex = content.indexOf(';');
  if (semicolonIndex == -1) return null;

  final parameterNumberStr = content.substring(0, semicolonIndex);
  final parameterNumber = int.tryParse(parameterNumberStr);
  if (parameterNumber == null) return null;

  final value = content.substring(semicolonIndex + 1);

  return switch (parameterNumber) {
    Defaults.oscTitle ||
    1 ||
    2 => InternalEvent('title_changed', {'title': value}),
    Defaults.oscHyperlink => _parseOscHyperlink(value),
    Defaults.oscFgQuery => _parseOscColorResponse(value, Defaults.oscFgQuery),
    Defaults.oscBgQuery => _parseOscColorResponse(value, Defaults.oscBgQuery),
    Defaults.oscClipboard => _parseOscClipboard(value),
    _ => null,
  };
}

InternalEvent? _parseOscHyperlink(String value) {
  final firstSemicolon = value.indexOf(';');
  if (firstSemicolon == -1) return null;
  final uri = value.substring(firstSemicolon + 1);
  return InternalEvent('hyperlink', {'uri': uri});
}

ClipboardEvent? _parseOscClipboard(String value) {
  final semicolonIndex = value.indexOf(';');
  if (semicolonIndex == -1) return null;
  final clipboard = value.substring(0, semicolonIndex);
  final base64Data = value.substring(semicolonIndex + 1);
  return ClipboardEvent(clipboard, base64Data.isEmpty ? null : base64Data);
}

ColorQueryEvent? _parseOscColorResponse(String value, int colorNumber) {
  if (!value.startsWith('rgb:')) return null;

  final rgbParts = value.substring(4).split('/');
  if (rgbParts.length != 3) return null;

  try {
    final red = int.parse(rgbParts[0].substring(0, 2), radix: 16);
    final green = int.parse(rgbParts[1].substring(0, 2), radix: 16);
    final blue = int.parse(rgbParts[2].substring(0, 2), radix: 16);
    return ColorQueryEvent(colorNumber, red, green, blue);
  } catch (_) {
    return null;
  }
}
