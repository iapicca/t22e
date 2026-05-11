import 'package:protocol/protocol.dart' show Defaults;

enum VtState {
  ground,
  escape,
  escapeIntermediate,
  csiEntry,
  csiParam,
  csiIntermediate,
  csiIgnore,
  oscString,
  dcsEntry,
  dcsParam,
  dcsIntermediate,
  dcsIgnore,
  dcsPassthrough,
}

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
  const DcsSequenceData(
    this.params,
    this.intermediates,
    this.finalByte, [
    this.data,
  ]);
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

  SequenceData? _onGround(int byte) {
    if (byte == Defaults.escapeByte) {
      _state = VtState.escape;
      return null;
    }
    if (byte == Defaults.csiIntroducerByte) {
      _state = VtState.csiEntry;
      _params.clear();
      _intermediates.clear();
      return null;
    }
    if (byte == Defaults.oscIntroducerByte) {
      _state = VtState.oscString;
      _oscBuffer.clear();
      return null;
    }
    if (byte == Defaults.dcsIntroducerByte) {
      _state = VtState.dcsEntry;
      _dcsParams.clear();
      _dcsIntermediates.clear();
      _dcsBuffer.clear();
      return null;
    }
    if (byte >= Defaults.byteRangePrintableLow &&
        byte <= Defaults.byteRangePrintableHigh) {
      return CharData(byte);
    }
    if (byte >= Defaults.byteRangeC1Low && byte <= Defaults.byteRangeC1High) {
      return null;
    }
    if (byte >= Defaults.byteRangeLowest &&
        byte <= Defaults.byteRangeControlHigh2 &&
        byte != Defaults.escapeByte) {
      return null;
    }
    return null;
  }

  SequenceData? _onEscape(int byte) {
    if (byte == Defaults.csiEntryByte) {
      _state = VtState.csiEntry;
      _params.clear();
      _intermediates.clear();
      return null;
    }
    if (byte == Defaults.oscEntryByte) {
      _state = VtState.oscString;
      _oscBuffer.clear();
      return null;
    }
    if (byte == Defaults.dcsEntryByte) {
      _state = VtState.dcsEntry;
      _dcsParams.clear();
      _dcsIntermediates.clear();
      _dcsBuffer.clear();
      return null;
    }
    if (byte == Defaults.ss3Byte) {
      _intermediates.add(byte);
      _state = VtState.escapeIntermediate;
      return null;
    }
    if (byte >= Defaults.byteRangeGraphicLow &&
        byte <= Defaults.byteRangeGraphicHigh) {
      _intermediates.add(byte);
      _state = VtState.escapeIntermediate;
      return null;
    }
    if (byte >= Defaults.byteRangeParamLow &&
        byte <= Defaults.byteRangeUpperHigh) {
      _state = VtState.ground;
      final data = EscSequenceData(List.unmodifiable(_intermediates), byte);
      _intermediates.clear();
      return data;
    }
    if (byte == Defaults.escapeByte) {
      _intermediates.clear();
      return null;
    }
    if (byte == Defaults.bellByte || byte == Defaults.stringTerminatorByte) {
      _state = VtState.ground;
      _intermediates.clear();
      return null;
    }
    _state = VtState.ground;
    _intermediates.clear();
    return null;
  }

  SequenceData? _onEscapeIntermediate(int byte) {
    if (byte >= Defaults.byteRangeGraphicLow &&
        byte <= Defaults.byteRangeGraphicHigh) {
      _intermediates.add(byte);
      return null;
    }
    if (byte >= Defaults.byteRangeParamLow &&
        byte <= Defaults.byteRangeUpperHigh) {
      _state = VtState.ground;
      final data = EscSequenceData(List.unmodifiable(_intermediates), byte);
      _intermediates.clear();
      return data;
    }
    if (byte == Defaults.escapeByte) {
      _state = VtState.escape;
      _intermediates.clear();
      return null;
    }
    _state = VtState.ground;
    _intermediates.clear();
    return null;
  }

  SequenceData? _onCsiEntry(int byte) {
    if (byte >= Defaults.byteRangeParamLow &&
        byte <= Defaults.byteRangeParamHigh) {
      if (byte >= Defaults.byteRangeDigitLow &&
          byte <= Defaults.byteRangeDigitHigh) {
        _params.add(byte - Defaults.byteRangeDigitLow);
      } else if (byte == Defaults.semicolonByte) {
        _params.add(0);
      } else if (byte >= Defaults.intermediatePrefixByte &&
          byte <= Defaults.byteRangeParamHigh) {
        _intermediates.add(byte);
      }
      _state = VtState.csiParam;
      return null;
    }
    if (byte >= Defaults.byteRangeGraphicLow &&
        byte <= Defaults.byteRangeGraphicHigh) {
      _intermediates.add(byte);
      _state = VtState.csiIntermediate;
      return null;
    }
    if (byte >= Defaults.byteRangeUpperLow &&
        byte <= Defaults.byteRangeUpperHigh) {
      _state = VtState.ground;
      final data = CsiSequenceData(
        List.unmodifiable(_params),
        List.unmodifiable(_intermediates),
        byte,
      );
      _params.clear();
      _intermediates.clear();
      return data;
    }
    if (byte >= Defaults.byteRangeLowest &&
        byte <= Defaults.byteRangeControlHigh2 &&
        byte != Defaults.escapeByte) {
      return null;
    }
    if (byte == Defaults.escapeByte) {
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
    if (byte >= Defaults.byteRangeDigitLow &&
        byte <= Defaults.byteRangeDigitHigh) {
      final last = _params.isEmpty ? 0 : _params.removeLast();
      _params.add(last * 10 + (byte - Defaults.byteRangeDigitLow));
      return null;
    }
    if (byte == Defaults.semicolonByte) {
      _params.add(0);
      return null;
    }
    if (byte >= Defaults.intermediatePrefixByte &&
        byte <= Defaults.byteRangeParamHigh) {
      _intermediates.add(byte);
      _state = VtState.csiParam;
      return null;
    }
    if (byte >= Defaults.byteRangeGraphicLow &&
        byte <= Defaults.byteRangeGraphicHigh) {
      _intermediates.add(byte);
      _state = VtState.csiIntermediate;
      return null;
    }
    if (byte >= Defaults.byteRangeUpperLow &&
        byte <= Defaults.byteRangeUpperHigh) {
      _state = VtState.ground;
      final data = CsiSequenceData(
        List.unmodifiable(_params),
        List.unmodifiable(_intermediates),
        byte,
      );
      _params.clear();
      _intermediates.clear();
      return data;
    }
    if (byte == Defaults.escapeByte) {
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
    if (byte >= Defaults.byteRangeGraphicLow &&
        byte <= Defaults.byteRangeGraphicHigh) {
      _intermediates.add(byte);
      return null;
    }
    if (byte >= Defaults.byteRangeUpperLow &&
        byte <= Defaults.byteRangeUpperHigh) {
      _state = VtState.ground;
      final data = CsiSequenceData(
        List.unmodifiable(_params),
        List.unmodifiable(_intermediates),
        byte,
      );
      _params.clear();
      _intermediates.clear();
      return data;
    }
    if (byte == Defaults.escapeByte) {
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
    if (byte >= Defaults.byteRangeUpperLow &&
        byte <= Defaults.byteRangeUpperHigh) {
      _state = VtState.ground;
      return null;
    }
    if (byte == Defaults.escapeByte) {
      _state = VtState.escape;
      return null;
    }
    return null;
  }

  SequenceData? _onOscString(int byte) {
    if (_oscExpectSt) {
      _oscExpectSt = false;
      if (byte == Defaults.dcsStByte) {
        _state = VtState.ground;
        final content = _oscBuffer.toString();
        _oscBuffer.clear();
        return OscSequenceData(content);
      }
      _oscBuffer.writeCharCode(Defaults.escapeByte);
      if (byte >= Defaults.byteRangePrintableLow && byte <= 0x7F) {
        _oscBuffer.writeCharCode(byte);
      }
      return null;
    }
    if (byte == Defaults.escapeByte) {
      _oscExpectSt = true;
      return null;
    }
    if (byte == Defaults.bellByte) {
      _state = VtState.ground;
      final content = _oscBuffer.toString();
      _oscBuffer.clear();
      return OscSequenceData(content);
    }
    if (byte == Defaults.stringTerminatorByte) {
      _state = VtState.ground;
      final content = _oscBuffer.toString();
      _oscBuffer.clear();
      return OscSequenceData(content);
    }
    if (byte >= Defaults.byteRangePrintableLow && byte <= 0x7F) {
      _oscBuffer.writeCharCode(byte);
      return null;
    }
    return null;
  }

  SequenceData? _onDcsEntry(int byte) {
    if (byte >= Defaults.byteRangeParamLow &&
        byte <= Defaults.byteRangeParamHigh) {
      if (byte >= Defaults.byteRangeDigitLow &&
          byte <= Defaults.byteRangeDigitHigh) {
        _dcsParams.add(byte - Defaults.byteRangeDigitLow);
      }
      _state = VtState.dcsParam;
      return null;
    }
    if (byte >= Defaults.byteRangeGraphicLow &&
        byte <= Defaults.byteRangeGraphicHigh) {
      _dcsIntermediates.add(byte);
      _state = VtState.dcsIntermediate;
      return null;
    }
    if (byte >= Defaults.byteRangeUpperLow &&
        byte <= Defaults.byteRangeUpperHigh) {
      _dcsFinalByte = byte;
      _state = VtState.dcsPassthrough;
      return null;
    }
    _state = VtState.dcsIgnore;
    return null;
  }

  SequenceData? _onDcsParam(int byte) {
    if (byte >= Defaults.byteRangeDigitLow &&
        byte <= Defaults.byteRangeDigitHigh) {
      final last = _dcsParams.isEmpty ? 0 : _dcsParams.removeLast();
      _dcsParams.add(last * 10 + (byte - Defaults.byteRangeDigitLow));
      return null;
    }
    if (byte == Defaults.semicolonByte) {
      _dcsParams.add(0);
      return null;
    }
    if (byte >= Defaults.byteRangeGraphicLow &&
        byte <= Defaults.byteRangeGraphicHigh) {
      _dcsIntermediates.add(byte);
      _state = VtState.dcsIntermediate;
      return null;
    }
    if (byte >= Defaults.byteRangeUpperLow &&
        byte <= Defaults.byteRangeUpperHigh) {
      _dcsFinalByte = byte;
      _state = VtState.dcsPassthrough;
      return null;
    }
    _state = VtState.dcsIgnore;
    return null;
  }

  SequenceData? _onDcsIntermediate(int byte) {
    if (byte >= Defaults.byteRangeGraphicLow &&
        byte <= Defaults.byteRangeGraphicHigh) {
      _dcsIntermediates.add(byte);
      return null;
    }
    if (byte >= Defaults.byteRangeUpperLow &&
        byte <= Defaults.byteRangeUpperHigh) {
      _dcsFinalByte = byte;
      _state = VtState.dcsPassthrough;
      return null;
    }
    _state = VtState.dcsIgnore;
    return null;
  }

  SequenceData? _onDcsIgnore(int byte) {
    if (byte == Defaults.bellByte || byte == Defaults.stringTerminatorByte) {
      _state = VtState.ground;
      return null;
    }
    if (byte == Defaults.escapeByte) {
      return _onGround(byte);
    }
    return null;
  }

  SequenceData? _onDcsPassthrough(int byte) {
    if (_dcsExpectSt) {
      _dcsExpectSt = false;
      if (byte == Defaults.dcsStByte) {
        _state = VtState.ground;
        final data = _dcsBuffer.toString();
        _dcsBuffer.clear();
        if (data.isEmpty) return null;
        return DcsSequenceData(
          List.unmodifiable(_dcsParams),
          List.unmodifiable(_dcsIntermediates),
          _dcsFinalByte,
          data,
        );
      }
      return null;
    }
    if (byte == Defaults.bellByte || byte == Defaults.stringTerminatorByte) {
      _state = VtState.ground;
      final data = _dcsBuffer.toString();
      _dcsBuffer.clear();
      if (data.isEmpty) return null;
      return DcsSequenceData(
        List.unmodifiable(_dcsParams),
        List.unmodifiable(_dcsIntermediates),
        _dcsFinalByte,
        data,
      );
    }
    if (byte == Defaults.escapeByte) {
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
