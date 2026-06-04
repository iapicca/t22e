# lifecycle

Application lifecycle management.

## Purpose

Manages terminal lifecycle — entering/exiting alternate screen, handling POSIX
signals, and ensuring terminal restoration on exit or crash.

## Exports

- **TerminalGuard** — composes runner + alt screen, ensures restoration on
  exit. Methods: `arm()`, `restore()`, `disarm()`, `runGuarded()`
- **SignalHandler** — handles SIGINT, SIGTERM, SIGTSTP, SIGCONT with
  customizable callbacks
- **AltScreenManager** — manages alternate screen buffer, cursor visibility,
  mouse capture
- **ProcessSignal** — sealed class: `Sigint`, `Sigterm`, `Sigtstp`, `Sigcont`
- **ProcessResult** — sealed class: `ProcessSuccess`, `ProcessTimeout`
- **Riverpod providers** — managed lifecycle components

## Usage

Wrap your application with `TerminalGuard.runGuarded()`. Signal handler
automatically restores terminal state on interrupt. Alt screen manager handles
enter/exit transitions.
