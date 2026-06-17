import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:notifier/notifier.dart'
    show Disposable, InitMixin, ValueNotifier;

import 'libc_signatures.dart';
import 'operating_system.dart';
import 'signal_bindings.dart';
import 'system_context.dart';
import 'system_io.dart';

/// TODO rework FFI to live in a init/dispose class with narrow lifecycle
final class TerminalIo with SystemIo, InitMixin, Disposable {
  final DynamicLibrary _libc;
  late final ValueNotifier<SystemContext> _context;
  NativeCallable<Void Function(Int32)>? _sigwinchCallback;
  late final Malloc _malloc;
  late final Free _free;
  late final DartWrite _writeFFI;
  /// TODO this shouls be in a class like SymbolsFFI
  static const _stdoutFd = 1;

  TerminalIo({required this._libc});

  @override
  void init({String? message, bool throwIfExists = false}) {
    super.init(message: message, throwIfExists: throwIfExists);

    var hasTerminal = stdout.hasTerminal;
    if (!hasTerminal) {
      throw StdoutException('stdout has no terminal!');
    }

    _malloc = _libc.lookupFunction<NativeMalloc, Malloc>('malloc');
    _free = _libc.lookupFunction<NativeFree, Free>('free');
    _writeFFI = _libc.lookupFunction<NativeWrite, DartWrite>('write');

    _context = ValueNotifier<SystemContext>(
      SystemContext(
        width: stdout.terminalColumns,
        height: stdout.terminalLines,
        hasTerminal: hasTerminal,

        /// TODO the internal "OperatingSystem" should be used!
        operatingSystem: Platform.operatingSystem == 'macos'
            ? OperatingSystem.macOS
            : OperatingSystem.linux,
        environment: Map<String, String>.from(Platform.environment),
      ),
    );
    _initSigwinch();
  }

  @override
  Stream<List<int>> get inputStream => stdin;

  @override
  void write(String data) {
    final encoded = utf8.encode(data);
    final buffer = _malloc(encoded.length).cast<Uint8>();
    for (var i = 0; i < encoded.length; i++) {
      buffer[i] = encoded[i];
    }
    _writeFFI(_stdoutFd, buffer, encoded.length);
    _free(buffer.cast<Void>());
  }

  @override
  Future<void> flush() => Future.value();

  @override
  ValueNotifier<SystemContext> get context => _context;

  void _initSigwinch() {
    if (!_context.value.hasTerminal) return;

    final DartSigaction sigaction;
    try {
      sigaction = _libc.lookupFunction<NativeSigaction, DartSigaction>(
        'sigaction',
      );
    } on ArgumentError {
      return;
    }

    const sigwinch = 28;
    const bufferSize = 256;

    final buffer = _malloc(bufferSize).cast<Uint8>();

    for (var i = 0; i < bufferSize; i++) {
      buffer[i] = 0;
    }

    final callback = NativeCallable<Void Function(Int32)>.listener((int _) {
      final width = stdout.terminalColumns;
      final height = stdout.terminalLines;
      if (width != _context.value.width || height != _context.value.height) {
        _context.value = _context.value.copyWith(width: width, height: height);
      }
    });

    _sigwinchCallback = callback;

    buffer.cast<Pointer<Void>>()[0] = callback.nativeFunction.cast<Void>();

    sigaction(sigwinch, buffer.cast<Void>(), nullptr);

    _free(buffer.cast<Void>());
  }

  @override
  void dispose({String? message}) {
    final callback = _sigwinchCallback;
    _sigwinchCallback = null;
    if (callback != null) {
      try {
        final sigaction = _libc.lookupFunction<NativeSigaction, DartSigaction>(
          'sigaction',
        );
        sigaction(28, nullptr, nullptr);
      } on ArgumentError {
        // sigaction not available; handler will close regardless
      }
      callback.close();
    }

    _context.dispose();
    super.dispose(message: message);
  }
}
