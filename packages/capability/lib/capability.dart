/// Terminal capability probing: color, sync, keyboard, DA1.
export 'src/result.dart'
    show
        QueryResult,
        Supported,
        Unavailable,
        Capabilities,
        Da1Result,
        KeyboardProtocol;
export 'src/terminal_probe_extension.dart' show probeTerminal;
export 'src/da1_probe_provider.dart';
export 'src/color_probe_provider.dart';
export 'src/sync_probe_provider.dart';
export 'src/keyboard_probe_provider.dart';
export 'src/capabilities_provider.dart';
