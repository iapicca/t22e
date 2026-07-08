import 'package:meta/meta.dart' show internal;
import 'package:riverpod/riverpod.dart';

import 'stdout_interface.dart' show StdoutWriter, StdoutInterface;

/// Provides a default [StdoutWriter] instance.
@internal
final stdoutInterfaceProvider =
    Provider<StdoutInterface>((ref) => StdoutWriter());