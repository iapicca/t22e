import 'dart:ffi';
import 'dart:io';

import 'package:protocol/protocol.dart' show Defaults;

import 'raw_mode_state.dart';
import 'pointer_extensions.dart';
import 'symbols_ffi.dart';

/// Raw mode management via libc FFI (tcgetattr/tcsetattr).
final class RawMode {
  RawModeState? _state;
  DynamicLibrary? _libc;

  void enable() {
    if (_state != null) return;
    final libc = _openLibc();
    final getAttr = libc
        .lookupFunction<
          Int32 Function(Int32, Pointer<Uint8>),
          int Function(int, Pointer<Uint8>)
        >(SymbolsFFI.getAttrName);
    final setAttr = libc
        .lookupFunction<
          Int32 Function(Int32, Int32, Pointer<Uint8>),
          int Function(int, int, Pointer<Uint8>)
        >(SymbolsFFI.setAttrName);
    final malloc = libc
        .lookupFunction<
          Pointer<Void> Function(IntPtr),
          Pointer<Void> Function(int)
        >(SymbolsFFI.mallocName);
    final free = libc
        .lookupFunction<
          Void Function(Pointer<Void>),
          void Function(Pointer<Void>)
        >(SymbolsFFI.freeName);

    final buf = malloc(Defaults.termiosStructSize).cast<Uint8>();
    final result = getAttr(Defaults.stdinFd, buf);
    if (result != 0) {
      free(buf.cast());
      throw StateError('tcgetattr failed (stdin is not a TTY?)');
    }

    final saved = RawModeState(
      buf,
      buf.read32(Defaults.termiosOffsetIFlag),
      buf.read32(Defaults.termiosOffsetOFlag),
      buf.read32(Defaults.termiosOffsetCFlag),
      buf.read32(Defaults.termiosOffsetLFlag),
    );

    final clflag =
        saved.cLflag &
        ~(Defaults.termiosEcho |
            Defaults.termiosICanon |
            Defaults.termiosISig |
            Defaults.termiosIExten);
    buf.write32(Defaults.termiosOffsetLFlag, clflag);
    buf.write8(Defaults.termiosOffsetCCMin, Defaults.termiosVminRaw);
    buf.write8(Defaults.termiosOffsetCCTime, Defaults.termiosVtimeRaw);

    final setResult = setAttr(Defaults.stdinFd, Defaults.tcsaNow, buf);
    if (setResult != 0) {
      free(buf.cast());
      throw StateError('tcsetattr failed');
    }

    _libc = libc;
    _state = saved;
  }

  void disable() {
    final state = _state;
    final libc = _libc;
    if (state == null || libc == null) return;

    final setAttr = libc
        .lookupFunction<
          Int32 Function(Int32, Int32, Pointer<Uint8>),
          int Function(int, int, Pointer<Uint8>)
        >(SymbolsFFI.setAttrName);
    final free = libc
        .lookupFunction<
          Void Function(Pointer<Void>),
          void Function(Pointer<Void>)
        >(SymbolsFFI.freeName);

    state.buf.write32(Defaults.termiosOffsetIFlag, state.cIflag);
    state.buf.write32(Defaults.termiosOffsetOFlag, state.cOflag);
    state.buf.write32(Defaults.termiosOffsetCFlag, state.cCflag);
    state.buf.write32(Defaults.termiosOffsetLFlag, state.cLflag);
    setAttr(Defaults.stdinFd, Defaults.tcsaNow, state.buf);
    free(state.buf.cast());
    _state = null;
    _libc = null;
  }

  DynamicLibrary _openLibc() {
    final os = Platform.operatingSystem;
    return switch (os) {
      'macos' => DynamicLibrary.open(SymbolsFFI.libcMacOS),
      'linux' => _openLibcLinux(),
      _ => throw UnsupportedError('FFI raw mode is not supported on $os'),
    };
  }

  DynamicLibrary _openLibcLinux() {
    try {
      return DynamicLibrary.open(SymbolsFFI.libcLinux6);
    } catch (_) {
      return DynamicLibrary.open(SymbolsFFI.libcLinux7);
    }
  }
}
