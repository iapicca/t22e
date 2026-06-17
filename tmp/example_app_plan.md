# Example Chat App — Implementation Plan

A terminal-based chat application demonstrating the **t22e** framework. This app showcases TEA (The Elm Architecture) state management, declarative widgets, colored output, and real-time input handling — with all package access going through **Riverpod providers** exclusively.

## Phase 0: Copy Plan to File

Create `./tmp/example_app_plan.md` with this full plan.

---

## Phase 1: Project Scaffolding

**Step 1.1** — Run `dart create --template console example` in project root. This generates:
```
example/
├── bin/example.dart
├── lib/example.dart
├── pubspec.yaml
├── analysis_options.yaml
├── README.md
└── .gitignore
```

**Step 1.2** — Remove generated files that won't be needed (root-level equivalents exist):
- Delete `example/README.md`, `example/.gitignore`, `example/analysis_options.yaml`
- Delete `example/test/` directory (generated stub test)

**Step 1.3** — Rewrite `example/pubspec.yaml` to match workspace conventions:
```yaml
name: example_app
description: Terminal chat application demonstrating the t22e framework.
version: 0.0.1
publish_to: none
resolution: workspace

environment:
  sdk: ^3.12.0

dependencies:
  ansi:         { path: ../packages/ansi }
  capability:   { path: ../packages/capability }
  core:         { path: ../packages/core }
  lifecycle:    { path: ../packages/lifecycle }
  parser:       { path: ../packages/parser }
  protocol:     { path: ../packages/protocol }
  renderer:     { path: ../packages/renderer }
  terminal:     { path: ../packages/terminal }
  unicode:      { path: ../packages/unicode }
  widgets:      { path: ../packages/widgets }
  freezed_annotation: ^3.1.0
  meta: ^1.18.2
  riverpod: ^3.2.1
  riverpod_annotation: ^4.0.2

dev_dependencies:
  build_runner: ^2.15.0
  freezed: ^3.2.5
  lints: ^6.1.0
  riverpod_generator: ^4.0.3
  riverpod_lint: ^3.1.3
  test: ^1.31.1
```

**Step 1.4** — Add `example` to the root workspace in `./pubspec.yaml`:
```yaml
workspace:
  - packages/*
  - example
```

**Step 1.5** — Run `dart pub get` from root to resolve the workspace.

**Step 1.6** — Verify with `dart pub workspace list` that `example_app` appears.

---

## Phase 2: Data Types (`lib/src/`)

**Step 2.1** — Create `lib/src/chat_message.dart` (freezed immutable):
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String text,
    required bool isBot,
    required DateTime timestamp,
  }) = _ChatMessage;
}
```
Run `dart run build_runner build --delete-conflicting-outputs` to generate `.freezed.dart`.

**Step 2.2** — Create `lib/src/messages.dart` — the app-level Msg definitions:
```dart
import 'package:widgets/widgets.dart';

final class BotReplyMsg extends Msg {
  final String originalText;
  const BotReplyMsg(this.originalText);
}
```

**Step 2.3** — Create `lib/src/chat_model.dart` — the TEA model extending `Model<ChatModel>`:
- State fields: `messages` (`List<ChatMessage>`), `input` (`TextInput`), `terminalWidth`, `terminalHeight`
- `copyWith(...)` method for immutable state transitions
- `update(Msg msg) -> (ChatModel, Cmd?)`:
  - `QuitMsg` → returns `(this, Cmd.none())` (quit handled externally via signal handler)
  - `WindowSizeMsg(:width, :height)` → updates dimensions, returns no cmd
  - `KeyMsg` with `codepoint == 0x03` (Ctrl+C in raw mode) → returns no cmd (quit handled by signal handler)
  - `KeyMsg` with `KeyCode.enter` → creates user `ChatMessage`, clears input, returns `TickCmd(250ms -> BotReplyMsg)` to simulate bot response
  - `KeyMsg` for other keys → delegates to `input.update(msg)`, returns updated model with propagated cmd (e.g., `CursorBlinkMsg` → `TickCmd`)
  - `BotReplyMsg(originalText)` → adds bot message "Your message was X characters" to list
- `view()` → returns the widget tree: `Column` with chat area + input area

---

## Phase 3: Widgets (`lib/src/`)

**Step 3.1** — Create `lib/src/chat_bubble.dart` — A `Widget` subclass for message bubbles:
- `layout(Constraints)` → measures bubble text with padding, returns `Size`
- `paint(PaintingContext)` → draws a `Box` with:
  - User messages: green text, right-aligned
  - Bot messages: blue text, left-aligned
  - Shows timestamp in dim text

**Step 3.2** — Create `lib/src/chat_view.dart` — A `Widget` subclass for the chat message area:
- `layout(Constraints)` → takes available space, reserves bottom portion for input
- `paint(PaintingContext)` → renders `Column` of `ChatBubble` widgets, scrolled to bottom
- Uses `WidgetRenderer.render()` internally to handle layout/paint of child bubbles

---

## Phase 4: ChatApp Wrapper + Riverpod Provider

**Step 4.1** — Create `lib/src/chat_app.dart` — Riverpod-accessible wrapper that holds model state and handles the dispatch loop:
```dart
class ChatApp {
  ChatModel _model;

  ChatApp(ChatModel initialModel) : _model = initialModel;

  ChatModel get model => _model;

  void dispatch(Msg msg) {
    final (newModel, cmd) = _model.update(msg);
    _model = newModel;
    if (cmd != null) {
      cmd.execute((Msg newMsg) => dispatch(newMsg));
    }
  }

  Widget view() => _model.view() as Widget;
}
```

**Step 4.2** — Create `lib/src/chat_app_provider.dart`:
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:terminal/terminal.dart';
import 'chat_app.dart';
import 'chat_model.dart';

part 'chat_app_provider.g.dart';

@riverpod
ChatApp chatApp(ChatAppRef ref) {
  final io = ref.read(systemIoProvider);
  final width = io.context.value.width;
  final height = io.context.value.height;
  return ChatApp(ChatModel(terminalWidth: width, terminalHeight: height));
}
```
Run `dart run build_runner build` to generate `.g.dart`.

---

## Phase 5: Barrel File

**Step 5.1** — Rewrite `lib/example.dart`:
```dart
export 'src/chat_message.dart';
export 'src/chat_model.dart';
export 'src/messages.dart';
export 'src/chat_app.dart';
export 'src/chat_app_provider.dart';
export 'src/chat_bubble.dart';
export 'src/chat_view.dart';
```

---

## Phase 6: Application Entry Point (`bin/example.dart`)

**Step 6.1** — The complete main loop using Riverpod providers for everything:

```dart
import 'dart:async';
import 'package:core/core.dart';
import 'package:widgets/widgets.dart';
import 'package:renderer/renderer.dart';
import 'package:parser/parser.dart';
import 'package:lifecycle/lifecycle.dart';
import 'package:capability/capability.dart';
import 'package:terminal/terminal.dart';
import 'package:ansi/ansi.dart';
import 'package:riverpod/riverpod.dart';
import 'package:example_app/example_app.dart';

void main() async {
  final container = ProviderContainer();

  try {
    // ----- 1. Terminal I/O (raw mode, stdin/stdout, dimension tracking) -----
    final io = container.read(systemIoProvider);

    // ----- 2. Capabilities probe (color, sync, keyboard) -----
    final capabilities = await container.read(capabilitiesProvider.future);

    // ----- 3. Terminal parser (bytes -> events) -----
    final parser = container.read(terminalParserProvider);

    // ----- 4. Guard: guaranteed terminal restoration -----
    final guard = container.read(
      terminalGuardProvider(onRestore: () {
        io.write(exitAltScreen());
        io.write(showCursor());
      }),
    );

    // ----- 5. Signal handler -----
    final signalHandler = container.read(
      signalHandlerProvider(
        onInterrupt: guard.restore,
        onCleanup: guard.restore,
      ),
    );
    signalHandler.install();

    // ----- 6. App state -----
    final app = container.read(chatAppProvider);

    // ----- 7. Renderer -----
    final renderer = SyncRenderer(syncSupported: capabilities.syncSupported);

    // ----- Initial render -----
    Frame? previousFrame;
    void render() {
      final widget = app.view();
      final surface = WidgetRenderer.render(
        widget,
        app.model.terminalWidth,
        app.model.terminalHeight,
      );
      final currentFrame = Frame.fromSurface(surface);
      final diff = DiffResult.fromFrames(
        previousFrame ?? Frame([], []),
        currentFrame,
      );
      if (diff.hasChanges) {
        io.write(renderer.render(diff, currentFrame));
      }
      previousFrame = currentFrame;
    }

    // ----- Alt screen + hide cursor -----
    io.write(enterAltScreen());
    io.write(hideCursor());
    render();

    // ----- Main event loop -----
    guard.runGuarded(() {
      final quitCompleter = Completer<void>();

      final subscription = io.inputStream.listen((bytes) {
        if (bytes.contains(0x03)) {
          // Ctrl+C in raw mode
          quitCompleter.complete();
          return;
        }

        final events = parser.advance(bytes);
        for (final event in events) {
          final msg = _eventToMsg(event);
          if (msg != null) {
            app.dispatch(msg);
          }
        }

        render();
      });

      // Block until quit
      await quitCompleter.future;
      subscription.cancel();
    });

  } finally {
    container.dispose();
  }
}

Msg? _eventToMsg(Event event) {
  return switch (event) {
    KeyEvent() => KeyMsg(event),
    MouseEvent() => MouseMsg(event),
    _ => null,
  };
}
```

---

## Phase 7: Tests

**Step 7.1** — Create `example/test/chat_message_test.dart`:
- Test `ChatMessage` freezed equality, `copyWith`, `toString`

**Step 7.2** — Create `example/test/chat_model_test.dart`:
- Test initial model state (empty messages, default input)
- Test `update(KeyMsg(KeyCode.char, codepoint: 0x61))` for character insertion (delegates to TextInput)
- Test `update(KeyMsg(KeyCode.enter))` — message added to list, input cleared, TickCmd returned
- Test `update(BotReplyMsg)` — bot response added with character count
- Test `update(WindowSizeMsg)` — dimensions updated
- Test `update(QuitMsg)` — returns NoCmd
- Test `view()` returns non-null widget tree

**Step 7.3** — Create `example/test/chat_view_test.dart`:
- Test `ChatBubble.layout()` returns correct size
- Test `ChatBubble.paint()` produces surface with correct colors (green user, blue bot)
- Test `ChatView.layout()` allocates space correctly
- Test `ChatView.paint()` renders all messages in order

**Step 7.4** — Create `example/test/chat_app_test.dart`:
- Test `ChatApp.dispatch(KeyMsg(...))` updates internal model
- Test `ChatApp.dispatch(enter KeyMsg)` triggers bot reply Cmd execution
- Test `ChatApp.view()` returns widget tree

**Step 7.5** — Create `example/test/chat_app_provider_test.dart`:
- Test provider creates a ChatApp with terminal dimensions from systemIoProvider
- Use `ProviderContainer` to read the provider

---

## Phase 8: Verification

**Step 8.1** — Run code generation: `dart run build_runner build --delete-conflicting-outputs` from example directory (or `melos build` from root).

**Step 8.2** — Run `melos analyze` from root → must pass.

**Step 8.3** — Run `melos format` from root → must pass.

**Step 8.4** — Run `melos test` from root → all tests (including example tests) must pass.

---

## Phase 9: Build & Run

```bash
# Build executable
dart compile exe bin/example.dart -o example_app

# Run
./example_app
```

---

## File Tree Summary

```
example/
├── pubspec.yaml
├── bin/
│   └── example.dart                 # Entry point, main loop with ProviderContainer
├── lib/
│   ├── example_app.dart             # Barrel exports
│   └── src/
│       ├── chat_message.dart         # Freezed data class
│       ├── chat_message.freezed.dart # Generated
│       ├── messages.dart             # App-level Msg subclasses (BotReplyMsg)
│       ├── chat_model.dart           # TEA Model<ChatModel> with update/view
│       ├── chat_app.dart             # ChatApp wrapper (state + dispatch)
│       ├── chat_app_provider.dart    # @riverpod provider for ChatApp
│       ├── chat_app_provider.g.dart  # Generated
│       ├── chat_bubble.dart          # Widget for message bubbles
│       └── chat_view.dart            # Widget for chat area
└── test/
    ├── chat_message_test.dart
    ├── chat_model_test.dart
    ├── chat_view_test.dart
    ├── chat_app_test.dart
    └── chat_app_provider_test.dart
```

---

## Key Architecture: Riverpod Everywhere

Every external package object is accessed through a Riverpod provider. No direct instantiation of framework classes in application code.

| Concern | Provider | Usage |
|---------|----------|-------|
| Terminal I/O | `systemIoProvider` | `ref.read(systemIoProvider).inputStream` / `.write()` |
| Raw mode | `rawModeProvider` | Auto-initialized via `systemIoProvider` dependency |
| Input parsing | `terminalParserProvider` | `ref.read(terminalParserProvider).advance(bytes)` |
| Capabilities | `capabilitiesProvider` | `await ref.read(capabilitiesProvider.future)` |
| Lifecycle guard | `terminalGuardProvider(onRestore:)` | `guard.runGuarded(() { ... })` |
| Signals | `signalHandlerProvider(onInterrupt:onCleanup:)` | `handler.install()` |
| App state | `chatAppProvider` | `ref.read(chatAppProvider).dispatch(msg)` / `.view()` |
| Renderer | (stateless, direct construction per code standards §l.189) | `SyncRenderer(syncSupported: caps.syncSupported)` |

## TEA Architecture (unchanged from draft)

- **Model**: `ChatModel` holds messages, input value, cursor position, and terminal dimensions
- **Messages**: `KeyMsg`, `WindowSizeMsg`, `CursorBlinkMsg`, `BotReplyMsg` drive state transitions
- **Commands**: `TickCmd` handles bot reply delay (250ms) and cursor blinking (500ms)
- **View**: Composed of `ChatView` (bubbles) + `TextInput` area via `Column` layout

## UI Layout (unchanged from draft)

```
┌─────────────────────────────────────┐
│                                     │
│  ┌──────────────────┐               │
│  │ Hello            │  (bot, blue)  │
│  └──────────────────┘               │
│               ┌──────────────────┐  │
│               │ hi!              │  (user, green)
│               └──────────────────┘  │
│                                     │
│        Chat Area (top 2/3)          │
├─────────────────────────────────────┤
│ > user types here█                  │
│                                     │
│ Press Enter to send - Ctrl+C to quit│
│        Input Area (bottom 1/3)      │
└─────────────────────────────────────┘
```

## Usage (unchanged from draft)

| Key | Action |
|-----|--------|
| **Letters/Numbers** | Type your message |
| **Enter** | Send message and get bot reply |
| **Left/Right arrows** | Move cursor within input |
| **Backspace** | Delete character before cursor |
| **Delete** | Delete character after cursor |
| **Ctrl+C** | Quit the application |

## Requirements

- macOS or Linux — Windows is not supported
- Dart SDK `^3.12.0`
