import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'stdout_interface.dart' show StdoutWriter, StdoutInterface;

part 'stdout_interface_provider.g.dart';

/// Provides a default [StdoutWriter] instance.
@riverpod
StdoutInterface stdoutInterface(Ref ref) => StdoutWriter();
