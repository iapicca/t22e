import '../loop/well_known.dart' show WellKnown;

enum VtState { ground, escape, escapeIntermediate, csiEntry, csiParam, csiIntermediate, csiIgnore, oscString, dcsEntry, dcsParam, dcsIntermediate, dcsIgnore, dcsPassthrough }

sealed class SequenceData {
  const SequenceData();
}

final class CharData extends SequenceData {
  final int codepoint;
  const CharData(this.codepoint);
}

final class CsiSequenceData extends SequenceData {
  final List<int> params;
  final List<int> intermediates;
  final int finalByte;
  const CsiSequenceData(this.params, this.intermediates, this.finalByte);
}

final class EscSequenceData extends SequenceData {
  final List<int> intermediates;
  final int finalByte;
  const EscSequenceData(this.intermediates, this.finalByte);
}

final class OscSequenceData extends SequenceData {
  final String content;
  const OscSequenceData(this.content);
}

final class DcsSequenceData extends SequenceData {
  final List<int> params;
  final List<int> intermediates;
  final int finalByte;
  final String? data;
  const DcsSequenceData(this.params, this.intermediates, this.finalByte, [this.data]);
}

int _byteClass(int b) {
  if (b == WellKnown.escapeByte) return 1;
  if (b == WellKnown.csiIntroducerByte) return 2;
  if (b == WellKnown.oscIntroducerByte) return 3;
  if (b == WellKnown.dcsIntroducerByte) return 4;
  if (b == WellKnown.apcIntroducerByte) return 5;
  if (b == WellKnown.bellByte || b == WellKnown.stringTerminatorByte) return 6;
  if (b >= WellKnown.byteRangeGraphicLow && b <= WellKnown.byteRangeGraphicHigh) return 8;
  if (b >= WellKnown.byteRangeParamLow && b <= WellKnown.byteRangeParamHigh) return 9;
  if (b >= WellKnown.byteRangeUpperLow && b <= WellKnown.byteRangeUpperHigh) return 10;
  if (b >= WellKnown.byteRangeC1Low && b <= WellKnown.byteRangeC1High) return 11;
  if (b >= WellKnown.byteRangeC1bLow && b <= WellKnown.byteRangeC1bHigh) return 11;
  if (b >= WellKnown.byteRangeControlSkipLow && b <= WellKnown.byteRangeControlSkipHigh) return 12;
  if (b == WellKnown.stringTerminatorByte) return 6;
  if (b >= WellKnown.byteRangeControlLow && b <= WellKnown.byteRangeControlHigh) return 13;
  if (b >= WellKnown.byteRangeControlLow2 && b <= WellKnown.byteRangeControlHigh2) return 13;
  return 13;
}

class Vt500Engine {
  VtState _state = VtState.ground;
  final _params = <int>[];
  final _intermediates = <int>[];
  final _oscBuffer = StringBuffer();
  final _dcsBuffer = StringBuffer();
  int _dcsFinalByte = 0;
  final _dcsParams = <int>[];
  final _dcsIntermediates = <int>[];
  bool _oscExpectSt = false;
  bool _dcsExpectSt = false;

  SequenceData? advance(int b) {
    final byte = b & 0xFF;

    switch (_state) {
      case VtState.ground:
        return _onGround(byte);

      case VtState.escape:
        return _onEscape(byte);

      case VtState.escapeIntermediate:
        return _onEscapeIntermediate(byte);

      case VtState.csiEntry:
        return _onCsiEntry(byte);

      case VtState.csiParam:
        return _onCsiParam(byte);

      case VtState.csiIntermediate:
        return _onCsiIntermediate(byte);

      case VtState.csiIgnore:
        return _onCsiIgnore(byte);

      case VtState.oscString:
        return _onOscString(byte);

      case VtState.dcsEntry:
        return _onDcsEntry(byte);

      case VtState.dcsParam:
        return _onDcsParam(byte);

      case VtState.dcsIntermediate:
        return _onDcsIntermediate(byte);

      case VtState.dcsIgnore:
        return _onDcsIgnore(byte);

      case VtState.dcsPassthrough:
        return _onDcsPassthrough(byte);
    }
  }

  SequenceData? _execute(int byte) {
    return null;
  }

  SequenceData? _onGround(int byte) {
    if (byte == WellKnown.escapeByte) {
      _state = VtState.escape;
      return null;
    }
    if (byte == WellKnown.csiIntroducerByte) {
      _state = VtState.csiEntry;
      _params.clear();
      _intermediates.clear();
      return null;
    }
    if (byte == WellKnown.oscIntroducerByte) {
      _state = VtState.oscString;
      _oscBuffer.clear();
      return null;
    }
    if (byte == WellKnown.dcsIntroducerByte) {
      _state = VtState.dcsEntry;
      _dcsParams.clear();
      _dcsIntermediates.clear();
      _dcsBuffer.clear();
      return null;
    }
    if (byte >= WellKnown.byteRangePrintableLow && byte <= WellKnown.byteRangePrintableHigh) {
      return CharData(byte);
    }
    if (byte >= WellKnown.byteRangeC1Low && byte <= WellKnown.byteRangeC1High) {
      return null;
    }
    if (byte >= WellKnown.byteRangeLowest && byte <= WellKnown.byteRangeControlHigh2 && byte != WellKnown.escapeByte) {
      return null;
    }
    return null;
  }

  SequenceData? _onEscape(int byte) {
    if (byte == WellKnown.csiEntryByte) {
      _state = VtState.csiEntry;
      _params.clear();
      _intermediates.clear();
      return null;
    }
    if (byte == WellKnown.oscEntryByte) {
      _state = VtState.oscString;
      _oscBuffer.clear();
      return null;
    }
    if (byte == WellKnown.dcsEntryByte) {
      _state = VtState.dcsEntry;
      _dcsParams.clear();
      _dcsIntermediates.clear();
      _dcsBuffer.clear();
      return null;
    }
    if (byte == WellKnown.ss3Byte) {
      _intermediates.add(byte);
      _state = VtState.escapeIntermediate;
      return null;
    }
    if (byte >= WellKnown.byteRangeGraphicLow && byte <= WellKnown.byteRangeGraphicHigh) {
      _intermediates.add(byte);
      _state = VtState.escapeIntermediate;
      return null;
    }
    if (byte >= WellKnown.byteRangeParamLow && byte <= WellKnown.byteRangeUpperHigh) {
      _state = VtState.ground;
      final data = EscSequenceData(List.unmodifiable(_intermediates), byte);
      _intermediates.clear();
      return data;
    }
    if (byte == WellKnown.escapeByte) {
      _intermediates.clear();
      return null;
    }
    if (byte == WellKnown.bellByte || byte == WellKnown.stringTerminatorByte) {
      _state = VtState.ground;
      _intermediates.clear();
      return null;
    }
    _state = VtState.ground;
    _intermediates.clear();
    return null;
  }

  SequenceData? _onEscapeIntermediate(int byte) {
    if (byte >= WellKnown.byteRangeGraphicLow && byte <= WellKnown.byteRangeGraphicHigh) {
      _intermediates.add(byte);
      return null;
    }
    if (byte >= WellKnown.byteRangeParamLow && byte <= WellKnown.byteRangeUpperHigh) {
      _state = VtState.ground;
      final data = EscSequenceData(List.unmodifiable(_intermediates), byte);
      _intermediates.clear();
      return data;
    }
    if (byte == WellKnown.escapeByte) {
      _state = VtState.escape;
      _intermediates.clear();
      return null;
    }
    _state = VtState.ground;
    _intermediates.clear();
    return null;
  }

  SequenceData? _onCsiEntry(int byte) {
    if (byte >= WellKnown.byteRangeParamLow && byte <= WellKnown.byteRangeParamHigh) {
      if (byte >= WellKnown.byteRangeDigitLow && byte <= WellKnown.byteRangeDigitHigh) {
        _params.add(byte - WellKnown.byteRangeDigitLow);
      } else if (byte == WellKnown.semicolonByte) {
        _params.add(0);
      } else if (byte >= WellKnown.intermediatePrefixByte && byte <= WellKnown.byteRangeParamHigh) {
        _intermediates.add(byte);
      }
      _state = VtState.csiParam;
      return null;
    }
    if (byte >= WellKnown.byteRangeGraphicLow && byte <= WellKnown.byteRangeGraphicHigh) {
      _intermediates.add(byte);
      _state = VtState.csiIntermediate;
      return null;
    }
    if (byte >= WellKnown.byteRangeUpperLow && byte <= WellKnown.byteRangeUpperHigh) {
      _state = VtState.ground;
      final data = CsiSequenceData(List.unmodifiable(_params), List.unmodifiable(_intermediates), byte);
      _params.clear();
      _intermediates.clear();
      return data;
    }
    if (byte >= WellKnown.byteRangeLowest && byte <= WellKnown.byteRangeControlHigh2 && byte != WellKnown.escapeByte) {
      return null;
    }
    if (byte == WellKnown.escapeByte) {
      _state = VtState.escape;
      _params.clear();
      _intermediates.clear();
      return null;
    }
    _state = VtState.csiIgnore;
    _params.clear();
    _intermediates.clear();
    return null;
  }

  SequenceData? _onCsiParam(int byte) {
    if (byte >= WellKnown.byteRangeDigitLow && byte <= WellKnown.byteRangeDigitHigh) {
      final last = _params.isEmpty ? 0 : _params.removeLast();
      _params.add(last * 10 + (byte - WellKnown.byteRangeDigitLow));
      return null;
    }
    if (byte == WellKnown.semicolonByte) {
      _params.add(0);
      return null;
    }
    if (byte >= WellKnown.intermediatePrefixByte && byte <= WellKnown.byteRangeParamHigh) {
      _intermediates.add(byte);
      _state = VtState.csiParam;
      return null;
    }
    if (byte >= WellKnown.byteRangeGraphicLow && byte <= WellKnown.byteRangeGraphicHigh) {
      _intermediates.add(byte);
      _state = VtState.csiIntermediate;
      return null;
    }
    if (byte >= WellKnown.byteRangeUpperLow && byte <= WellKnown.byteRangeUpperHigh) {
      _state = VtState.ground;
      final data = CsiSequenceData(List.unmodifiable(_params), List.unmodifiable(_intermediates), byte);
      _params.clear();
      _intermediates.clear();
      return data;
    }
    if (byte == WellKnown.escapeByte) {
      _state = VtState.escape;
      _params.clear();
      _intermediates.clear();
      return null;
    }
    _state = VtState.csiIgnore;
    _params.clear();
    _intermediates.clear();
    return null;
  }

  SequenceData? _onCsiIntermediate(int byte) {
    if (byte >= WellKnown.byteRangeGraphicLow && byte <= WellKnown.byteRangeGraphicHigh) {
      _intermediates.add(byte);
      return null;
    }
    if (byte >= WellKnown.byteRangeUpperLow && byte <= WellKnown.byteRangeUpperHigh) {
      _state = VtState.ground;
      final data = CsiSequenceData(List.unmodifiable(_params), List.unmodifiable(_intermediates), byte);
      _params.clear();
      _intermediates.clear();
      return data;
    }
    if (byte == WellKnown.escapeByte) {
      _state = VtState.escape;
      _params.clear();
      _intermediates.clear();
      return null;
    }
    _state = VtState.ground;
    _params.clear();
    _intermediates.clear();
    return null;
  }

  SequenceData? _onCsiIgnore(int byte) {
    if (byte >= WellKnown.byteRangeUpperLow && byte <= WellKnown.byteRangeUpperHigh) {
      _state = VtState.ground;
      return null;
    }
    if (byte == WellKnown.escapeByte) {
      _state = VtState.escape;
      return null;
    }
    return null;
  }

  SequenceData? _onOscString(int byte) {
    if (_oscExpectSt) {
      _oscExpectSt = false;
      if (byte == WellKnown.dcsStByte) {
        _state = VtState.ground;
        final content = _oscBuffer.toString();
        _oscBuffer.clear();
        return OscSequenceData(content);
      }
      _oscBuffer.writeCharCode(WellKnown.escapeByte);
      if (byte >= WellKnown.byteRangePrintableLow && byte <= 0x7F) {
        _oscBuffer.writeCharCode(byte);
      }
      return null;
    }
    if (byte == WellKnown.escapeByte) {
      _oscExpectSt = true;
      return null;
    }
    if (byte == WellKnown.bellByte) {
      _state = VtState.ground;
      final content = _oscBuffer.toString();
      _oscBuffer.clear();
      return OscSequenceData(content);
    }
    if (byte == WellKnown.stringTerminatorByte) {
      _state = VtState.ground;
      final content = _oscBuffer.toString();
      _oscBuffer.clear();
      return OscSequenceData(content);
    }
    if (byte >= WellKnown.byteRangePrintableLow && byte <= 0x7F) {
      _oscBuffer.writeCharCode(byte);
      return null;
    }
    return null;
  }

  SequenceData? _onDcsEntry(int byte) {
    if (byte >= WellKnown.byteRangeParamLow && byte <= WellKnown.byteRangeParamHigh) {
      if (byte >= WellKnown.byteRangeDigitLow && byte <= WellKnown.byteRangeDigitHigh) {
        _dcsParams.add(byte - WellKnown.byteRangeDigitLow);
      }
      _state = VtState.dcsParam;
      return null;
    }
    if (byte >= WellKnown.byteRangeGraphicLow && byte <= WellKnown.byteRangeGraphicHigh) {
      _dcsIntermediates.add(byte);
      _state = VtState.dcsIntermediate;
      return null;
    }
    if (byte >= WellKnown.byteRangeUpperLow && byte <= WellKnown.byteRangeUpperHigh) {
      _dcsFinalByte = byte;
      _state = VtState.dcsPassthrough;
      return null;
    }
    _state = VtState.dcsIgnore;
    return null;
  }

  SequenceData? _onDcsParam(int byte) {
    if (byte >= WellKnown.byteRangeDigitLow && byte <= WellKnown.byteRangeDigitHigh) {
      final last = _dcsParams.isEmpty ? 0 : _dcsParams.removeLast();
      _dcsParams.add(last * 10 + (byte - WellKnown.byteRangeDigitLow));
      return null;
    }
    if (byte == WellKnown.semicolonByte) {
      _dcsParams.add(0);
      return null;
    }
    if (byte >= WellKnown.byteRangeGraphicLow && byte <= WellKnown.byteRangeGraphicHigh) {
      _dcsIntermediates.add(byte);
      _state = VtState.dcsIntermediate;
      return null;
    }
    if (byte >= WellKnown.byteRangeUpperLow && byte <= WellKnown.byteRangeUpperHigh) {
      _dcsFinalByte = byte;
      _state = VtState.dcsPassthrough;
      return null;
    }
    _state = VtState.dcsIgnore;
    return null;
  }

  SequenceData? _onDcsIntermediate(int byte) {
    if (byte >= WellKnown.byteRangeGraphicLow && byte <= WellKnown.byteRangeGraphicHigh) {
      _dcsIntermediates.add(byte);
      return null;
    }
    if (byte >= WellKnown.byteRangeUpperLow && byte <= WellKnown.byteRangeUpperHigh) {
      _dcsFinalByte = byte;
      _state = VtState.dcsPassthrough;
      return null;
    }
    _state = VtState.dcsIgnore;
    return null;
  }

  SequenceData? _onDcsIgnore(int byte) {
    if (byte == WellKnown.bellByte || byte == WellKnown.stringTerminatorByte) {
      _state = VtState.ground;
      return null;
    }
    if (byte == WellKnown.escapeByte) {
      return _onGround(byte);
    }
    return null;
  }

  SequenceData? _onDcsPassthrough(int byte) {
    if (_dcsExpectSt) {
      _dcsExpectSt = false;
      if (byte == WellKnown.dcsStByte) {
        _state = VtState.ground;
        final data = _dcsBuffer.toString();
        _dcsBuffer.clear();
        if (data.isEmpty) return null;
        return DcsSequenceData(List.unmodifiable(_dcsParams), List.unmodifiable(_dcsIntermediates), _dcsFinalByte, data);
      }
      return null;
    }
    if (byte == WellKnown.bellByte || byte == WellKnown.stringTerminatorByte) {
      _state = VtState.ground;
      final data = _dcsBuffer.toString();
      _dcsBuffer.clear();
      if (data.isEmpty) return null;
      return DcsSequenceData(List.unmodifiable(_dcsParams), List.unmodifiable(_dcsIntermediates), _dcsFinalByte, data);
    }
    if (byte == WellKnown.escapeByte) {
      _dcsExpectSt = true;
      return null;
    }
    _dcsBuffer.writeCharCode(byte);
    return null;
  }

  List<SequenceData> advanceAll(List<int> bytes) {
    final results = <SequenceData>[];
    for (final byte in bytes) {
      final result = advance(byte);
      if (result != null) results.add(result);
    }
    return results;
  }

  void reset() {
    _state = VtState.ground;
    _params.clear();
    _intermediates.clear();
    _oscBuffer.clear();
    _dcsBuffer.clear();
    _dcsParams.clear();
    _dcsIntermediates.clear();
    _dcsFinalByte = 0;
  }
}
