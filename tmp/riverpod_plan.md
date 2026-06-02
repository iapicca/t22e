# Riverpod Migration Plan for t22e

## Overview

Replace the current manual constructor injection pattern with Riverpod (using code generation via `@riverpod` annotation). This is a **pure Dart library** (not Flutter), so we'll use `ProviderContainer` for dependency resolution.

## Current State

### DI Patterns in Use
- **Constructor injection with optional parameters** - Services accept interface-typed optional params with concrete defaults
- **Abstract factory pattern** - `PlatformService` factory for platform-specific implementations
- **Interface + Implementation pattern** - e.g., `RawModeBackend` <- `FfiRawModeBackend`, `IoRawModeBackend`
- **Custom state management** - `notifier` package with `ChangeNotifier`, `ValueNotifier`, `Disposable`

### Packages to Migrate (All)
1. **notifier** - Replace `ChangeNotifier`/`ValueNotifier` with Riverpod Notifiers
2. **terminal** - `TerminalRunner`, `FfiRawModeBackend`, `IoRawModeBackend`, `PlatformService`
3. **capability** - `ProbePipeline`, `Da1Probe`, `ColorProbe`, `SyncProbe`, `KeyboardProbe`
4. **lifecycle** - `TerminalGuard`, `SignalHandler`, `AltScreenManager`
5. **widgets** - TEA runtime, Model integration with Riverpod
6. **parser** - `TerminalParser`, sub-parsers (if state management needed)
7. **renderer** - Stateless renderers (likely no changes needed)
8. **core** - Pure data classes (no changes needed)
9. **protocol** - Pure constants (no changes needed)
10. **unicode** - Pure utilities (no changes needed)
11. **ansi** - Pure utilities (no changes needed)
12. **testing** - `VirtualTerminal`, `WidgetTester` (adapt to Riverpod)

---

## Phase 0: Setup & Dependencies

### 0.1 Add Riverpod dependencies to workspace packages that need them

**Packages needing Riverpod runtime (`riverpod` + `riverpod_annotation`):**
- notifier
- terminal
- capability
- lifecycle
- widgets
- testing

**Packages needing dev dependencies (`build_runner` + `riverpod_generator` + `riverpod_lint`):**
- notifier
- terminal
- capability
- lifecycle
- widgets
- testing

**Example pubspec.yaml additions:**
```yaml
dependencies:
  riverpod: ^3.2.1
  riverpod_annotation: ^4.0.2

dev_dependencies:
  build_runner: ^2.15.0
  riverpod_generator: ^4.0.3
  riverpod_lint: ^3.1.3
```

### 0.2 Update analysis_options.yaml

Add riverpod_lint plugin:
```yaml
plugins:
  riverpod_lint: ^3.1.3
```

### 0.3 Update workspace melos script

The existing `melos build` script already runs `dart run build_runner build` - this will work for Riverpod code generation.

---

## Phase 1: Migrate `notifier` Package

### 1.1 Replace `ChangeNotifier` with Riverpod Notifier

**Current:**
```dart
class ChangeNotifier with Disposable {
  final List<VoidCallback> _listeners = [];
  bool get hasListeners => _listeners.isNotEmpty;
  void addListener(VoidCallback listener, {String? message}) { ... }
  void removeListener(VoidCallback listener, {String? message}) { ... }
  void notifyListeners({String? message}) { ... }
  void dispose(String? message) { ... }
}
```

**New approach:** Use `@riverpod` annotated `Notifier` class. Riverpod handles disposal automatically via `ref.onDispose()`.

**Key decisions:**
- `Disposable` mixin becomes unnecessary - Riverpod manages lifecycle
- `ChangeNotifier` functionality replaced by `Notifier` with listeners managed via Riverpod's ref
- `ValueNotifier` replaced by `Notifier` with a state value

### 1.2 Migration Steps

1. Create `@riverpod` providers for any state that was previously managed by `ChangeNotifier`/`ValueNotifier`
2. Remove `Disposable` mixin usage - use `ref.onDispose()` instead
3. Keep the `notifier` package but transform it into a Riverpod-based state management layer
4. Update exports in `lib/notifier.dart`

### 1.3 Files to Modify
- `packages/notifier/lib/src/disposable.dart` - Deprecate/remove, replace with Riverpod disposal
- `packages/notifier/lib/src/disposed.dart` - Deprecate/remove
- `packages/notifier/lib/src/change_notifier.dart` - Replace with Riverpod Notifier
- `packages/notifier/lib/src/value_notifier.dart` - Replace with Riverpod Notifier
- `packages/notifier/pubspec.yaml` - Add Riverpod dependencies

---

## Phase 2: Migrate `terminal` Package

### 2.1 Current Architecture

```
TerminalRunner (orchestrates backends)
├── FfiRawModeBackend (FFI-based)
│   ├── TermiosBindings
│   │   └── TermiosBindingsImpl.fromPlatformService()
│   │       └── PlatformService (abstract factory)
│   │           ├── MacService
│   │           └── LinuxService
│   └── NativeIo
└── IoRawModeBackend (IO-based)
    └── NativeIo

TerminalIo (I/O facade)
└── NativeIo

SystemIo (abstraction)
└── NativeIo
```

### 2.2 Provider Design

```dart
// Platform service provider (auto-detects platform)
@riverpod
PlatformService platformService(Ref ref) {
  final io = ref.watch(systemIoProvider);
  return PlatformService(io: io);
}

// System IO provider
@riverpod
SystemIo systemIo(Ref ref) => const NativeIo();

// Termios bindings provider
@riverpod
TermiosBindings termiosBindings(Ref ref) {
  final platformService = ref.watch(platformServiceProvider);
  return TermiosBindingsImpl.fromPlatformService(platformService);
}

// FFI backend provider
@riverpod
FfiRawModeBackend ffiRawBackend(Ref ref) {
  final bindings = ref.watch(termiosBindingsProvider);
  final io = ref.watch(systemIoProvider);
  return FfiRawModeBackend(bindings: bindings, io: io);
}

// IO backend provider
@riverpod
IoRawModeBackend ioRawBackend(Ref ref) {
  final io = ref.watch(systemIoProvider);
  return IoRawModeBackend(io: io);
}

// Terminal runner provider (orchestrates backends)
@riverpod
TerminalRunner terminalRunner(Ref ref) {
  final ffiBackend = ref.watch(ffiRawBackendProvider);
  final ioBackend = ref.watch(ioRawBackendProvider);
  return TerminalRunner(backends: [ffiBackend, ioBackend]);
}

// Terminal IO provider
@riverpod
TerminalIo terminalIo(Ref ref) => const TerminalIo();
```

### 2.3 Key Changes

1. Remove optional constructor parameters - dependencies come from `ref.watch()`
2. Remove `Disposable` mixin from `TerminalRunner` - use `ref.onDispose()` in provider
3. `PlatformService` factory can become a provider that auto-selects implementation
4. Each backend becomes its own provider

### 2.4 Files to Modify
- `packages/terminal/lib/src/runner.dart`
- `packages/terminal/lib/src/ffi_raw_backend.dart`
- `packages/terminal/lib/src/io_raw_backend.dart`
- `packages/terminal/lib/src/platform_service.dart`
- `packages/terminal/lib/src/termios_bindings.dart`
- `packages/terminal/lib/src/terminal_io.dart`
- `packages/terminal/lib/src/system_io.dart`
- `packages/terminal/lib/src/native_io.dart`
- `packages/terminal/pubspec.yaml`

---

## Phase 3: Migrate `capability` Package

### 3.1 Current Architecture

```
ProbePipeline (aggregates probes)
├── Da1Probe
├── ColorProbe
├── SyncProbe
├── KeyboardProbe
└── TerminalIo
```

### 3.2 Provider Design

```dart
// Individual probes as providers
@riverpod
Da1Probe da1Probe(Ref ref) {
  final io = ref.watch(terminalIoProvider);
  return Da1Probe(io: io);
}

@riverpod
ColorProbe colorProbe(Ref ref) {
  final io = ref.watch(terminalIoProvider);
  return ColorProbe(io: io);
}

@riverpod
SyncProbe syncProbe(Ref ref) {
  final io = ref.watch(terminalIoProvider);
  return SyncProbe(io: io);
}

@riverpod
KeyboardProbe keyboardProbe(Ref ref) {
  final io = ref.watch(terminalIoProvider);
  return KeyboardProbe(io: io);
}

// Pipeline provider
@riverpod
ProbePipeline probePipeline(Ref ref) {
  return ProbePipeline(
    da1Probe: ref.watch(da1ProbeProvider),
    colorProbe: ref.watch(colorProbeProvider),
    syncProbe: ref.watch(syncProbeProvider),
    keyboardProbe: ref.watch(keyboardProbeProvider),
    io: ref.watch(terminalIoProvider),
  );
}

// Capabilities provider (runs the pipeline)
@riverpod
Future<Capabilities> capabilities(Ref ref) async {
  final pipeline = ref.watch(probePipelineProvider);
  return pipeline.run();
}
```

### 3.3 Key Changes

1. Remove optional constructor parameters from probes
2. Remove `Disposable` mixin - Riverpod handles disposal
3. `ProbePipeline.run()` becomes an async provider
4. Individual probes can be overridden for testing

### 3.4 Files to Modify
- `packages/capability/lib/src/pipeline.dart`
- `packages/capability/lib/src/da1_probe.dart`
- `packages/capability/lib/src/color_probe.dart`
- `packages/capability/lib/src/sync_probe.dart`
- `packages/capability/lib/src/keyboard_probe.dart`
- `packages/capability/pubspec.yaml`

---

## Phase 4: Migrate `lifecycle` Package

### 4.1 Current Architecture

```
TerminalGuard (composes runner + alt screen)
├── TerminalRunner
└── AltScreenManager

SignalHandler (composes guard + callback)
├── TerminalGuard
└── onInterrupt callback

AltScreenManager
└── TerminalRunner
```

### 4.2 Provider Design

```dart
@riverpod
AltScreenManager altScreenManager(Ref ref) {
  final runner = ref.watch(terminalRunnerProvider);
  return AltScreenManager(runner);
}

@riverpod
TerminalGuard terminalGuard(Ref ref) {
  final runner = ref.watch(terminalRunnerProvider);
  final altScreen = ref.watch(altScreenManagerProvider);
  final guard = TerminalGuard(runner, altScreen);
  ref.onDispose(() => guard.dispose());
  return guard;
}

// Signal handler - requires callback, so use a functional provider with parameter
@riverpod
SignalHandler signalHandler(Ref ref, {required VoidCallback onInterrupt}) {
  final guard = ref.watch(terminalGuardProvider);
  return SignalHandler(guard: guard, onInterrupt: onInterrupt);
}
```

### 4.3 Key Changes

1. Remove `Disposable` mixin usage
2. `SignalHandler` uses a family parameter for the callback
3. `terminalGuardProvider` handles disposal via `ref.onDispose()`

### 4.4 Files to Modify
- `packages/lifecycle/lib/src/terminal_guard.dart`
- `packages/lifecycle/lib/src/signal_handler.dart`
- `packages/lifecycle/lib/src/alt_screen_manager.dart`
- `packages/lifecycle/pubspec.yaml`

---

## Phase 5: Migrate `widgets` Package

### 5.1 Current Architecture

TEA (The Elm Architecture) pattern:
```
Model<M> (abstract)
├── init() -> (M, Cmd<M>)
├── update(M, Msg) -> (M, Cmd<M>)
└── view(M) -> Widget

Msg (sealed hierarchy)
Cmd (sealed hierarchy)
```

### 5.2 Provider Design

The widgets package is trickier because it uses TEA architecture. Options:

**Option A: Wrap TEA runtime in a Notifier**
```dart
@riverpod
class AppRuntime extends _$AppRuntime {
  @override
  (Model, Cmd) build() {
    final initialModel = InitialModel();
    ref.onDispose(() { /* cleanup */ });
    return (initialModel, Cmd.none);
  }

  void sendMsg(Msg msg) {
    final (model, cmd) = state;
    final (newModel, newCmd) = model.update(msg);
    state = (newModel, newCmd);
    executeCmd(newCmd);
  }
}
```

**Option B: Keep TEA as-is, use Riverpod for DI only**
- Keep `Model`, `Msg`, `Cmd` classes unchanged
- Use Riverpod providers for services that widgets need (terminal, capabilities, etc.)
- Widget rendering accesses providers via `ref.watch()`

**Recommendation: Option B** - TEA is a good fit for this use case. Riverpod provides the DI layer, TEA handles the state machine.

### 5.3 Provider Design (Option B)

```dart
// Provide the runtime services to widgets
@riverpod
TerminalRunner terminalRunnerForWidgets(Ref ref) =>
    ref.watch(terminalRunnerProvider);

@riverpod
Future<Capabilities> capabilitiesForWidgets(Ref ref) =>
    ref.watch(capabilitiesProvider);

// Widget models can access providers via ref
@riverpod
class CounterModel extends _$CounterModel {
  @override
  int build() => 0;

  void increment() => state++;
}
```

### 5.4 Key Changes

1. Keep TEA architecture (`Model`, `Msg`, `Cmd`) as pure classes
2. Add Riverpod providers for services widgets need
3. Widget tests use `ProviderContainer` with overrides
4. `WidgetRenderer` may need to accept a `ProviderContainer` or `Ref`

### 5.5 Files to Modify
- `packages/widgets/lib/src/model.dart`
- `packages/widgets/lib/src/renderer.dart`
- `packages/widgets/pubspec.yaml`
- Add new provider files as needed

---

## Phase 6: Migrate `testing` Package

### 6.1 Current Architecture

```
VirtualTerminal (simulates terminal in memory)
WidgetTester (tests widgets)
```

### 6.2 Provider Design

```dart
// Testing providers that override real implementations
@riverpod
TerminalIo virtualTerminalIo(Ref ref) {
  final virtualTerminal = ref.watch(virtualTerminalProvider);
  return virtualTerminal;
}

// WidgetTester creates a ProviderContainer with test overrides
class WidgetTester {
  late ProviderContainer container;

  Future<void> pumpWidget(Widget widget, {List<Override>? overrides}) async {
    container = ProviderContainer(
      overrides: [
        ...?overrides,
        terminalIoProvider.overrideWithValue(virtualTerminal),
        // ... other test overrides
      ],
    );
    // ... render widget
  }
}
```

### 6.3 Key Changes

1. `VirtualTerminal` provides test doubles for terminal I/O
2. `WidgetTester` creates `ProviderContainer` with overrides
3. Tests can override any provider for mocking

### 6.4 Files to Modify
- `packages/testing/lib/src/virtual_terminal.dart`
- `packages/testing/lib/src/widget_tester.dart`
- `packages/testing/pubspec.yaml`

---

## Phase 7: Cross-Cutting Changes

### 7.1 ProviderContainer Setup

Since this is a library (not an application), consumers will create their own `ProviderContainer`:

```dart
// Example consumer code
void main() {
  final container = ProviderContainer();

  // Access services
  final runner = container.read(terminalRunnerProvider);
  final capabilities = container.read(capabilitiesProvider.future);

  // Run with raw mode
  runner.runWithRawMode(() {
    // ... application code
  });

  // Cleanup
  container.dispose();
}
```

### 7.2 Testing Strategy

```dart
void main() {
  test('terminal runner works', () {
    final container = ProviderContainer(
      overrides: [
        ffiRawBackendProvider.overrideWith((ref) => MockFfiBackend()),
        ioRawBackendProvider.overrideWith((ref) => MockIoBackend()),
      ],
    );
    addTearDown(container.dispose);

    final runner = container.read(terminalRunnerProvider);
    // ... test
  });
}
```

### 7.3 Export Structure

Each package should export its providers:

```dart
// packages/terminal/lib/terminal.dart
export 'src/runner.dart';
export 'src/providers.dart'; // New file with @riverpod providers
```

---

## Phase 8: Cleanup & Verification

### 8.1 Remove Deprecated Code

- Remove `Disposable` mixin and related classes from `notifier`
- Remove optional constructor parameters from all services
- Remove manual dependency wiring code

### 8.2 Run Code Generation

```bash
melos build  # Runs build_runner in all packages
```

### 8.3 Run Analysis

```bash
melos analyze  # Code generation + dart analyze
```

### 8.4 Run Tests

```bash
melos test  # Code generation + dart test
```

### 8.5 Update Documentation

- Update README with Riverpod usage examples
- Document `ProviderContainer` setup for consumers
- Document testing with provider overrides

---

## Implementation Order

1. **Phase 0** - Setup dependencies (all packages)
2. **Phase 1** - Migrate `notifier` package (foundation)
3. **Phase 2** - Migrate `terminal` package (depends on notifier)
4. **Phase 3** - Migrate `capability` package (depends on terminal)
5. **Phase 4** - Migrate `lifecycle` package (depends on terminal, notifier)
6. **Phase 5** - Migrate `widgets` package (depends on notifier, core, parser)
7. **Phase 6** - Migrate `testing` package (depends on all above)
8. **Phase 7** - Cross-cutting changes (exports, documentation)
9. **Phase 8** - Cleanup & verification

---

## Key Benefits

1. **Testability** - Easy to override providers in tests
2. **Discoverability** - `ref.watch()` makes dependencies explicit
3. **Lifecycle management** - Automatic disposal via `ref.onDispose()`
4. **Code generation** - Less boilerplate, consistent patterns
5. **Linting** - `riverpod_lint` catches common mistakes
6. **Hot reload** - Stateful hot reload during development (when applicable)

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Breaking API changes | Keep backward-compatible constructors during transition |
| Learning curve for consumers | Provide clear documentation and examples |
| Package bloat | Only add Riverpod to packages that need it |
| Code generation complexity | Use `melos build` script already in place |
| Pure Dart compatibility | Riverpod 3.x supports pure Dart natively |

---

## File-by-File Change Summary

### notifier package
| File | Change |
|------|--------|
| `pubspec.yaml` | Add riverpod, riverpod_annotation, riverpod_generator, riverpod_lint |
| `lib/src/disposable.dart` | Deprecate/remove |
| `lib/src/disposed.dart` | Deprecate/remove |
| `lib/src/change_notifier.dart` | Replace with @riverpod Notifier |
| `lib/src/value_notifier.dart` | Replace with @riverpod Notifier |
| `lib/notifier.dart` | Update exports |

### terminal package
| File | Change |
|------|--------|
| `pubspec.yaml` | Add riverpod dependencies |
| `lib/src/runner.dart` | Remove Disposable, add @riverpod provider |
| `lib/src/ffi_raw_backend.dart` | Remove optional params, add provider |
| `lib/src/io_raw_backend.dart` | Remove optional params, add provider |
| `lib/src/platform_service.dart` | Convert factory to provider |
| `lib/src/termios_bindings.dart` | Add provider |
| `lib/src/terminal_io.dart` | Add provider |
| `lib/src/system_io.dart` | Add provider |
| `lib/src/native_io.dart` | No changes (concrete impl) |
| `lib/src/providers.dart` | **NEW** - All terminal providers |

### capability package
| File | Change |
|------|--------|
| `pubspec.yaml` | Add riverpod dependencies |
| `lib/src/pipeline.dart` | Remove optional params, add provider |
| `lib/src/da1_probe.dart` | Remove Disposable, add provider |
| `lib/src/color_probe.dart` | Remove Disposable, add provider |
| `lib/src/sync_probe.dart` | Remove Disposable, add provider |
| `lib/src/keyboard_probe.dart` | Remove Disposable, add provider |
| `lib/src/providers.dart` | **NEW** - All capability providers |

### lifecycle package
| File | Change |
|------|--------|
| `pubspec.yaml` | Add riverpod dependencies |
| `lib/src/terminal_guard.dart` | Remove Disposable, add provider |
| `lib/src/signal_handler.dart` | Add provider with family parameter |
| `lib/src/alt_screen_manager.dart` | Add provider |
| `lib/src/providers.dart` | **NEW** - All lifecycle providers |

### widgets package
| File | Change |
|------|--------|
| `pubspec.yaml` | Add riverpod dependencies |
| `lib/src/model.dart` | Keep TEA, add Riverpod integration helpers |
| `lib/src/renderer.dart` | Accept ProviderContainer/Ref |
| `lib/src/providers.dart` | **NEW** - Widget-related providers |

### testing package
| File | Change |
|------|--------|
| `pubspec.yaml` | Add riverpod dependencies |
| `lib/src/virtual_terminal.dart` | Integrate with ProviderContainer |
| `lib/src/widget_tester.dart` | Create ProviderContainer with overrides |

---

## Phase 1-6 Implementation Notes (Completed)

### Architecture: Riverpod as Lifecycle Manager for Legacy Objects

**Decision:** Keep legacy classes (`ChangeNotifier`, `ValueNotifier`, `Disposable`, `Disposed`, and all domain classes) **unchanged**. Riverpod providers act as **lifecycle-managed factories** that instantiate, return, and dispose of these objects.

### Why This Approach

1. **Zero breaking changes** - All existing code continues to work without modification
2. **Gradual migration** - Downstream packages can adopt Riverpod incrementally
3. **No inheritance** - Providers are functional (`@riverpod` on functions), returning instances of the existing classes
4. **Riverpod handles lifecycle** - `ref.onDispose()` replaces manual `dispose()` calls
5. **Test overrides** - `ProviderContainer(overrides: [...])` enables easy mocking in tests

### Pattern

```dart
@riverpod
TerminalRunner terminalRunner(Ref ref) {
  final runner = TerminalRunner();
  ref.onDispose(() => runner.dispose(null));
  return runner;
}
```

**Key details:**
- Providers are functional (annotated functions, not classes)
- `ref.onDispose()` wraps the legacy `dispose(String?)` call with a closure
- Some dispose methods may fail in non-terminal environments (e.g., `IoRawModeBackend.disable()`), so try-catch is used where needed
- Cross-package dependencies are handled by importing providers from other packages (e.g., `terminalRunnerProvider` in lifecycle)

### Completed Packages

| Package | Providers Added | Tests | Status |
|---------|----------------|-------|--------|
| `terminal` | `terminalIoProvider`, `ioRawBackendProvider`, `ffiRawBackendProvider`, `terminalRunnerProvider` | 8 new tests | ✅ |
| `capability` | `da1ProbeProvider`, `colorProbeProvider`, `syncProbeProvider`, `keyboardProbeProvider`, `probePipelineProvider` | 10 new tests | ✅ |
| `lifecycle` | `altScreenManagerProvider`, `terminalGuardProvider`, `signalHandlerProvider` (family) | 8 new tests | ✅ |
| `widgets` | `everyCmdProvider` (family) | 3 new tests | ✅ |
| `testing` | `virtualTerminalProvider`, `virtualTerminalWithSizeProvider` (family), `widgetTesterProvider` | 6 new tests | ✅ |

### File-by-File Summary

| Package | Files Created | Files Modified |
|---------|--------------|----------------|
| `terminal` | `lib/src/providers.dart`, `lib/src/providers.g.dart`, `test/providers_test.dart` | `lib/terminal.dart` |
| `capability` | `lib/src/providers.dart`, `lib/src/providers.g.dart`, `test/providers_test.dart` | `lib/capability.dart` |
| `lifecycle` | `lib/src/providers.dart`, `lib/src/providers.g.dart`, `test/providers_test.dart` | `lib/lifecycle.dart` |
| `widgets` | `lib/src/providers.dart`, `lib/src/providers.g.dart`, `test/providers_test.dart` | `lib/widgets.dart` |
| `testing` | `lib/src/providers.dart`, `lib/src/providers.g.dart`, `test/providers_test.dart` | `lib/testing.dart` |

### Implications for Future Work

- All existing classes remain usable without Riverpod
- Consumers can choose to use providers or instantiate classes directly
- `ProviderContainer` can be used in tests for provider overrides
- The `notifier` package was excluded from this implementation per user request
