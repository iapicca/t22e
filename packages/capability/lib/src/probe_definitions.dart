import 'package:core/core.dart' show ColorProfile;

import '../capability.dart' show Da1Result;
import 'capabilities.dart' show KeyboardProtocol, QueryResult;

typedef SyncProbe = Future<bool>;

typedef KeyboardProbe = Future<KeyboardProtocol>;

typedef Da1Probe = Future<QueryResult<Da1Result>>;

typedef ColorProbe = Future<ColorProfile>;