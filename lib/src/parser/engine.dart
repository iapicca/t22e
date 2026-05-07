import 'dart:core';

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
  if (b == 0x1B) return 1;
  if (b == 0x9B) return 2;
  if (b == 0x9D) return 3;
  if (b == 0x90) return 4;
  if (b == 0x9F) return 5;
  if (b == 0x07 || b == 0x9C) return 6;
  if (b >= 0x20 && b <= 0x2F) return 8;
  if (b >= 0x30 && b <= 0x3F) return 9;
  if (b >= 0x40 && b <= 0x7E) return 10;
  if (b >= 0x80 && b <= 0x8F) return 11;
  if (b >= 0x90 && b <= 0x9A) return 11;
  if (b >= 0x18 && b <= 0x1A) return 12;
  if (b == 0x9C) return 6;
  if (b >= 0x00 && b <= 0x17) return 13;
  if (b >= 0x19 && b <= 0x1F) return 13;
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
    if (byte == 0x1B) {
      _state = VtState.escape;
      return null;
    }
    if (byte == 0x9B) {
      _state = VtState.csiEntry;
      _params.clear();
      _intermediates.clear();
      return null;
    }
    if (byte == 0x9D) {
      _state = VtState.oscString;
      _oscBuffer.clear();
      return null;
    }
    if (byte == 0x90) {
      _state = VtState.dcsEntry;
      _dcsParams.clear();
      _dcsIntermediates.clear();
      _dcsBuffer.clear();
      return null;
    }
    if (byte >= 0x20 && byte <= 0x7E) {
      return CharData(byte);
    }
    if (byte >= 0x80 && byte <= 0x8F) {
      return null;
    }
    if (byte >= 0x00 && byte <= 0x1F && byte != 0x1B) {
      return null;
    }
    return null;
  }

  SequenceData? _onEscape(int byte) {
    if (byte == 0x5B) {
      _state = VtState.csiEntry;
      _params.clear();
      _intermediates.clear();
      return null;
    }
    if (byte == 0x5D) {
      _state = VtState.oscString;
      _oscBuffer.clear();
      return null;
    }
    if (byte == 0x50) {
      _state = VtState.dcsEntry;
      _dcsParams.clear();
      _dcsIntermediates.clear();
      _dcsBuffer.clear();
      return null;
    }
    if (byte == 0x4F) {
      _intermediates.add(byte);
      _state = VtState.escapeIntermediate;
      return null;
    }
    if (byte >= 0x20 && byte <= 0x2F) {
      _intermediates.add(byte);
      _state = VtState.escapeIntermediate;
      return null;
    }
    if (byte >= 0x30 && byte <= 0x7E) {
      _state = VtState.ground;
      final data = EscSequenceData(List.unmodifiable(_intermediates), byte);
      _intermediates.clear();
      return data;
    }
    if (byte == 0x1B) {
      _intermediates.clear();
      return null;
    }
    if (byte == 0x07 || byte == 0x9C) {
      _state = VtState.ground;
      _intermediates.clear();
      return null;
    }
    _state = VtState.ground;
    _intermediates.clear();
    return null;
  }

  SequenceData? _onEscapeIntermediate(int byte) {
    if (byte >= 0x20 && byte <= 0x2F) {
      _intermediates.add(byte);
      return null;
    }
    if (byte >= 0x30 && byte <= 0x7E) {
      _state = VtState.ground;
      final data = EscSequenceData(List.unmodifiable(_intermediates), byte);
      _intermediates.clear();
      return data;
    }
    if (byte == 0x1B) {
      _state = VtState.escape;
      _intermediates.clear();
      return null;
    }
    _state = VtState.ground;
    _intermediates.clear();
    return null;
  }

  SequenceData? _onCsiEntry(int byte) {
    if (byte >= 0x30 && byte <= 0x3F) {
      if (byte >= 0x30 && byte <= 0x39) {
        _params.add(byte - 0x30);
      } else if (byte == 0x3B) {
        _params.add(0);
      } else if (byte >= 0x3C && byte <= 0x3F) {
        _intermediates.add(byte);
      }
      _state = VtState.csiParam;
      return null;
    }
    if (byte >= 0x20 && byte <= 0x2F) {
      _intermediates.add(byte);
      _state = VtState.csiIntermediate;
      return null;
    }
    if (byte >= 0x40 && byte <= 0x7E) {
      _state = VtState.ground;
      final data = CsiSequenceData(List.unmodifiable(_params), List.unmodifiable(_intermediates), byte);
      _params.clear();
      _intermediates.clear();
      return data;
    }
    if (byte >= 0x00 && byte <= 0x1F && byte != 0x1B) {
      return null;
    }
    if (byte == 0x1B) {
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
    if (byte >= 0x30 && byte <= 0x39) {
      final last = _params.isEmpty ? 0 : _params.removeLast();
      _params.add(last * 10 + (byte - 0x30));
      return null;
    }
    if (byte == 0x3B) {
      _params.add(0);
      return null;
    }
    if (byte >= 0x3C && byte <= 0x3F) {
      _intermediates.add(byte);
      _state = VtState.csiParam;
      return null;
    }
    if (byte >= 0x20 && byte <= 0x2F) {
      _intermediates.add(byte);
      _state = VtState.csiIntermediate;
      return null;
    }
    if (byte >= 0x40 && byte <= 0x7E) {
      _state = VtState.ground;
      final data = CsiSequenceData(List.unmodifiable(_params), List.unmodifiable(_intermediates), byte);
      _params.clear();
      _intermediates.clear();
      return data;
    }
    if (byte == 0x1B) {
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
    if (byte >= 0x20 && byte <= 0x2F) {
      _intermediates.add(byte);
      return null;
    }
    if (byte >= 0x40 && byte <= 0x7E) {
      _state = VtState.ground;
      final data = CsiSequenceData(List.unmodifiable(_params), List.unmodifiable(_intermediates), byte);
      _params.clear();
      _intermediates.clear();
      return data;
    }
    if (byte == 0x1B) {
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
    if (byte >= 0x40 && byte <= 0x7E) {
      _state = VtState.ground;
      return null;
    }
    if (byte == 0x1B) {
      _state = VtState.escape;
      return null;
    }
    return null;
  }

  SequenceData? _onOscString(int byte) {
    if (_oscExpectSt) {
      _oscExpectSt = false;
      if (byte == 0x5C) {
        _state = VtState.ground;
        final content = _oscBuffer.toString();
        _oscBuffer.clear();
        return OscSequenceData(content);
      }
      _oscBuffer.writeCharCode(0x1B);
      if (byte >= 0x20 && byte <= 0x7F) {
        _oscBuffer.writeCharCode(byte);
      }
      return null;
    }
    if (byte == 0x1B) {
      _oscExpectSt = true;
      return null;
    }
    if (byte == 0x07) {
      _state = VtState.ground;
      final content = _oscBuffer.toString();
      _oscBuffer.clear();
      return OscSequenceData(content);
    }
    if (byte == 0x9C) {
      _state = VtState.ground;
      final content = _oscBuffer.toString();
      _oscBuffer.clear();
      return OscSequenceData(content);
    }
    if (byte >= 0x20 && byte <= 0x7F) {
      _oscBuffer.writeCharCode(byte);
      return null;
    }
    return null;
  }

  SequenceData? _onDcsEntry(int byte) {
    if (byte >= 0x30 && byte <= 0x3F) {
      if (byte >= 0x30 && byte <= 0x39) {
        _dcsParams.add(byte - 0x30);
      }
      _state = VtState.dcsParam;
      return null;
    }
    if (byte >= 0x20 && byte <= 0x2F) {
      _dcsIntermediates.add(byte);
      _state = VtState.dcsIntermediate;
      return null;
    }
    if (byte >= 0x40 && byte <= 0x7E) {
      _dcsFinalByte = byte;
      _state = VtState.dcsPassthrough;
      return null;
    }
    _state = VtState.dcsIgnore;
    return null;
  }

  SequenceData? _onDcsParam(int byte) {
    if (byte >= 0x30 && byte <= 0x39) {
      final last = _dcsParams.isEmpty ? 0 : _dcsParams.removeLast();
      _dcsParams.add(last * 10 + (byte - 0x30));
      return null;
    }
    if (byte == 0x3B) {
      _dcsParams.add(0);
      return null;
    }
    if (byte >= 0x20 && byte <= 0x2F) {
      _dcsIntermediates.add(byte);
      _state = VtState.dcsIntermediate;
      return null;
    }
    if (byte >= 0x40 && byte <= 0x7E) {
      _dcsFinalByte = byte;
      _state = VtState.dcsPassthrough;
      return null;
    }
    _state = VtState.dcsIgnore;
    return null;
  }

  SequenceData? _onDcsIntermediate(int byte) {
    if (byte >= 0x20 && byte <= 0x2F) {
      _dcsIntermediates.add(byte);
      return null;
    }
    if (byte >= 0x40 && byte <= 0x7E) {
      _dcsFinalByte = byte;
      _state = VtState.dcsPassthrough;
      return null;
    }
    _state = VtState.dcsIgnore;
    return null;
  }

  SequenceData? _onDcsIgnore(int byte) {
    if (byte == 0x07 || byte == 0x9C) {
      _state = VtState.ground;
      return null;
    }
    if (byte == 0x1B) {
      return _onGround(byte);
    }
    return null;
  }

  SequenceData? _onDcsPassthrough(int byte) {
    if (_dcsExpectSt) {
      _dcsExpectSt = false;
      if (byte == 0x5C) {
        _state = VtState.ground;
        final data = _dcsBuffer.toString();
        _dcsBuffer.clear();
        if (data.isEmpty) return null;
        return DcsSequenceData(List.unmodifiable(_dcsParams), List.unmodifiable(_dcsIntermediates), _dcsFinalByte, data);
      }
      return null;
    }
    if (byte == 0x07 || byte == 0x9C) {
      _state = VtState.ground;
      final data = _dcsBuffer.toString();
      _dcsBuffer.clear();
      if (data.isEmpty) return null;
      return DcsSequenceData(List.unmodifiable(_dcsParams), List.unmodifiable(_dcsIntermediates), _dcsFinalByte, data);
    }
    if (byte == 0x1B) {
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
