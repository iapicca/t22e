import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:protocol/protocol.dart' show Defaults;

part 'engine.freezed.dart';

/// States for the VT500 state machine.
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

@freezed
sealed class SequenceData with _$SequenceData {
  const factory SequenceData.char(int codepoint) = CharData;
  const factory SequenceData.csi({
    required List<int> params,
    required List<int> intermediates,
    required int finalByte,
  }) = CsiSequenceData;
  const factory SequenceData.esc({
    required List<int> intermediates,
    required int finalByte,
  }) = EscSequenceData;
  const factory SequenceData.osc(String content) = OscSequenceData;
  const factory SequenceData.dcs({
    required List<int> params,
    required List<int> intermediates,
    required int finalByte,
    String? data,
  }) = DcsSequenceData;
}

/// VT500-compatible byte-level state machine engine.
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

  /// Feeds a single byte to the state machine, returning parsed data or null.
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

  /// Processes a byte in the ground state.
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
      return SequenceData.char(byte);
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

  /// Processes a byte in the ESC state.
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
      final data = SequenceData.esc(
        intermediates: List.unmodifiable(_intermediates),
        finalByte: byte,
      );
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

  /// Processes a byte during an ESC intermediate sequence.
  SequenceData? _onEscapeIntermediate(int byte) {
    if (byte >= Defaults.byteRangeGraphicLow &&
        byte <= Defaults.byteRangeGraphicHigh) {
      _intermediates.add(byte);
      return null;
    }
    if (byte >= Defaults.byteRangeParamLow &&
        byte <= Defaults.byteRangeUpperHigh) {
      _state = VtState.ground;
      final data = SequenceData.esc(
        intermediates: List.unmodifiable(_intermediates),
        finalByte: byte,
      );
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

  /// Processes a byte at CSI entry.
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
      final data = SequenceData.csi(
        params: List.unmodifiable(_params),
        intermediates: List.unmodifiable(_intermediates),
        finalByte: byte,
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

  /// Processes a byte during CSI parameter accumulation.
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
      final data = SequenceData.csi(
        params: List.unmodifiable(_params),
        intermediates: List.unmodifiable(_intermediates),
        finalByte: byte,
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

  /// Processes a byte during CSI intermediate.
  SequenceData? _onCsiIntermediate(int byte) {
    if (byte >= Defaults.byteRangeGraphicLow &&
        byte <= Defaults.byteRangeGraphicHigh) {
      _intermediates.add(byte);
      return null;
    }
    if (byte >= Defaults.byteRangeUpperLow &&
        byte <= Defaults.byteRangeUpperHigh) {
      _state = VtState.ground;
      final data = SequenceData.csi(
        params: List.unmodifiable(_params),
        intermediates: List.unmodifiable(_intermediates),
        finalByte: byte,
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

  /// Processes a byte during CSI ignore (malformed sequence).
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

  /// Processes a byte during an OSC string sequence.
  SequenceData? _onOscString(int byte) {
    if (_oscExpectSt) {
      _oscExpectSt = false;
      if (byte == Defaults.dcsStByte) {
        _state = VtState.ground;
        final content = _oscBuffer.toString();
        _oscBuffer.clear();
        return SequenceData.osc(content);
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
      return SequenceData.osc(content);
    }
    if (byte == Defaults.stringTerminatorByte) {
      _state = VtState.ground;
      final content = _oscBuffer.toString();
      _oscBuffer.clear();
      return SequenceData.osc(content);
    }
    if (byte >= Defaults.byteRangePrintableLow && byte <= 0x7F) {
      _oscBuffer.writeCharCode(byte);
      return null;
    }
    return null;
  }

  /// Processes a byte at DCS entry.
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

  /// Processes a byte during DCS parameter accumulation.
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

  /// Processes a byte during DCS intermediate.
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

  /// Processes a byte during DCS ignore.
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

  /// Processes a byte during DCS passthrough (data accumulation).
  SequenceData? _onDcsPassthrough(int byte) {
    if (_dcsExpectSt) {
      _dcsExpectSt = false;
      if (byte == Defaults.dcsStByte) {
        _state = VtState.ground;
        final data = _dcsBuffer.toString();
        _dcsBuffer.clear();
        if (data.isEmpty) return null;
        return SequenceData.dcs(
          params: List.unmodifiable(_dcsParams),
          intermediates: List.unmodifiable(_dcsIntermediates),
          finalByte: _dcsFinalByte,
          data: data,
        );
      }
      return null;
    }
    if (byte == Defaults.bellByte || byte == Defaults.stringTerminatorByte) {
      _state = VtState.ground;
      final data = _dcsBuffer.toString();
      _dcsBuffer.clear();
      if (data.isEmpty) return null;
      return SequenceData.dcs(
        params: List.unmodifiable(_dcsParams),
        intermediates: List.unmodifiable(_dcsIntermediates),
        finalByte: _dcsFinalByte,
        data: data,
      );
    }
    if (byte == Defaults.escapeByte) {
      _dcsExpectSt = true;
      return null;
    }
    _dcsBuffer.writeCharCode(byte);
    return null;
  }

  /// Feeds a list of bytes and collects all parsed sequence data.
  List<SequenceData> advanceAll(List<int> bytes) {
    final results = <SequenceData>[];
    for (final byte in bytes) {
      final result = advance(byte);
      if (result != null) results.add(result);
    }
    return results;
  }

  /// Resets the engine to its initial state.
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
