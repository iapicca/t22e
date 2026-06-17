# Example Chat App

A terminal-based chat application demonstrating the capabilities of the **t22e** framework. This app showcases TEA (The Elm Architecture) state management, declarative widgets, colored output, and real-time input handling.

## Features

- **Chat bubbles**: Green bubbles for user messages (right-aligned), blue bubbles for bot messages (left-aligned)
- **Real-time input**: Character-by-character input with a blinking cursor
- **Automatic bot replies**: Every message you send gets a reply showing its character count
- **Terminal management**: Raw mode via FFI, alternate screen, and guaranteed restoration on any exit path

## Requirements

- **Real terminal (TTY) required** — this app cannot run with:
  - Piped input: `echo "hello" | dart run bin/example.dart`
  - Redirected output: `dart run bin/example.dart > output.txt`
  - Non-interactive shells (CI, cron, etc.)
- macOS or Linux — Windows is not supported
- Dart SDK `^3.12.0`

## Troubleshooting

### App exits immediately with no output

You are not running in a real terminal. This app requires an interactive TTY.
If you need to run tests, use `melos test` instead.

## Building

From the repository root:

```bash
# Install dependencies
cd example
dart pub get
```

## Running

```bash
# Run directly from source
dart run bin/example.dart

# Or compile to a native executable first
dart compile exe bin/example.dart -o example_app
./example_app
```

## Usage

| Key | Action |
|-----|--------|
| **Letters/Numbers** | Type your message |
| **Enter** | Send message and get bot reply |
| **Left/Right arrows** | Move cursor within input |
| **Backspace** | Delete character before cursor |
| **Delete** | Delete character after cursor |
| **Home** | Move cursor to start of input |
| **End** | Move cursor to end of input |
| **q** | Quit the application |

## UI Layout

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
│ Press Enter to send - q to quit     │
│        Input Area (bottom 1/3)      │
└─────────────────────────────────────┘
```

## Architecture

This app follows The Elm Architecture (TEA):

- **Model**: `ChatModel` holds messages, input value, cursor position, and terminal dimensions
- **Messages**: `KeyMsg`, `WindowSizeMsg`, `CursorBlinkMsg` drive state transitions
- **Commands**: `TickCmd` handles cursor blinking at 500ms intervals
- **View**: Composed of `ChatView` (bubbles) + `TextInput` area via `Column` layout

## Project Structure

```
example/
├── pubspec.yaml
├── bin/
│   └── example.dart          # Entry point + main loop
└── lib/
    ├── example.dart           # Barrel exports
    └── src/
        ├── chat_model.dart    # TEA model with update/view
        ├── chat_message.dart  # Message data class
        ├── chat_view.dart     # Chat area widget
        └── chat_bubble.dart   # Individual bubble widget
```
