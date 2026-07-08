import 'package:meta/meta.dart' show internal;

import 'ansi_parser_symbols.dart' show AnsiParserSymbols;
import 'terminal_bytes_symbols.dart' show TerminalBytesSymbols;

/// Whether [byte] is a control byte that should not be decoded as UTF-8.
@internal
bool isControlByte(int byte) =>
    byte < TerminalBytesSymbols.controlMax || byte == AnsiParserSymbols.del;

/// Whether [byte] is a CSI parameter byte (`0x30`–`0x3F`).
@internal
bool isCsiParamByte(int byte) =>
    byte >= TerminalBytesSymbols.csiParamMin &&
    byte <= TerminalBytesSymbols.csiParamMax;

/// Whether [byte] is a CSI intermediate byte (`0x20`–`0x2F`).
@internal
bool isCsiIntermediateByte(int byte) =>
    byte >= TerminalBytesSymbols.csiIntermediateMin &&
    byte <= TerminalBytesSymbols.csiIntermediateMax;

/// Whether [byte] is a CSI final byte (`0x40`–`0x7E`).
@internal
bool isCsiFinalByte(int byte) =>
    byte >= TerminalBytesSymbols.csiFinalMin &&
    byte <= TerminalBytesSymbols.csiFinalMax;