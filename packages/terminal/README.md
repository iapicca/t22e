# terminal

Terminal raw mode management via FFI with IO fallback.

## Purpose

Disables line buffering and echo so the TUI receives individual keystrokes.
Provides stdin/stdout I/O abstraction.

## Exports

- **TerminalRunner** — orchestrates backends with FFI-first fallback
- **FfiRawModeBackend** — libc FFI via tcgetattr/tcsetattr
- **IoRawModeBackend** — dart:io stdin mode (simpler fallback)
- **TerminalIo** — facade for input stream, write, flush, dimensions
- **RawModeState** — captured termios state with auto-restore
- **TermiosBindings** — FFI bindings to libc
- **Riverpod providers** — managed terminal instances

## Usage

Use `TerminalRunner.runWithRawMode()` for scoped raw mode. Terminal state is
automatically restored on disposal. Use `TerminalIo` for stdin/stdout access.
