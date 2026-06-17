import 'package:core/core.dart' show ColorProfile;

import 'da1_query.dart' show Da1Query;
import 'capabilities.dart' show KeyboardProtocol;

typedef SyncProbe = Future<bool>;

typedef KeyboardProbe = Future<KeyboardProtocol>;

typedef Da1Probe = Future<Da1Query>;

typedef ColorProbe = Future<ColorProfile>;
