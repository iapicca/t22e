import 'package:protocol/protocol.dart' show Defaults;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'probe_timeout_provider.g.dart';

@riverpod
Duration probeTimeout(Ref ref) => Defaults.defaultProbeTimeout;
