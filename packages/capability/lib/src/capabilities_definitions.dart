import 'package:capability/capability.dart' show QueryResult;
import 'package:core/core.dart' show ColorProfile;
import 'capabilities.dart' show Da1Result;

typedef Probe<T> = Future<T> Function([Duration? timeout]);
typedef ColorProbe = Probe<ColorProfile>;
typedef Da1Probe = Probe<QueryResult<Da1Result>>;