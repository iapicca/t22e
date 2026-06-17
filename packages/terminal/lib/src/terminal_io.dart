import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:notifier/notifier.dart'
    show Disposable, InitMixin, ValueNotifier;

import 'libc_signatures.dart';
import 'operating_system.dart';
import 'signal_bindings.dart';
import 'system_context.dart';
import 'system_io.dart';

final class TerminalIo with SystemIo, InitMixin, Disposable {
  final DynamicLibrary _libc;
  late final ValueNotifier<SystemContext> _context;
  NativeCallable<Void Function(Int32)>? _sigwinchCallback;

  TerminalIo({required this._libc});

  @override
  void init({String? message, bool throwIfExists = false}) {
    super.init(message: message, throwIfExists: throwIfExists);
    _context = ValueNotifier<SystemContext>(
      SystemContext(
        width: stdout.terminalColumns,
        height: stdout.terminalLines,
        hasTerminal: stdout.hasTerminal,
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
  void write(String data) => stdout.write(data);

  @override
  Future<void> flush() => stdout.flush();

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

    final cMalloc = _libc.lookupFunction<NativeMalloc, Malloc>('malloc');
    final cFree = _libc.lookupFunction<NativeFree, Free>('free');

    final buffer = cMalloc(bufferSize).cast<Uint8>();

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

    cFree(buffer.cast<Void>());
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
