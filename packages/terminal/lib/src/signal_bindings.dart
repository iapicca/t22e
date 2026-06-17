import 'dart:ffi';

/// Native C function signature for `sigaction`.
typedef NativeSigaction =
    Int32 Function(Int32 signum, Pointer<Void> act, Pointer<Void> oldact);

/// Dart-facing function signature for `sigaction`.
typedef DartSigaction =
    int Function(int signum, Pointer<Void> act, Pointer<Void> oldact);
