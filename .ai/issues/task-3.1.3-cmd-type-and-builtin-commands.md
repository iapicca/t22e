# Task 3.1.3: Cmd Type and Built-in Commands

**Story:** TEA Event Loop
**Estimate:** M

## Description

Define the `Cmd` type and implement built-in command helpers for common side effects: timers, batches, sequences, and external process execution.

## Implementation

```dart
typedef Cmd = FutureOr<Msg?> Function();

Cmd tick(Duration duration, Msg Function(DateTime) createMsg);
Cmd every(Duration interval, Msg Function(DateTime) createMsg);
Cmd batch(List<Cmd?> commands);
Cmd sequence(List<Cmd> commands);
Cmd execProcess(String exe, List<String> args, {Msg Function(int exitCode)? onExit});
Cmd none(); // no-op command
```

## Acceptance Criteria

- `tick()`: one-shot timer that delivers a Msg after duration
- `every()`: repeating timer aligned to wall clock, delivers Msg on each tick
- `batch()`: runs all commands concurrently, collects results as messages
- `sequence()`: runs commands one after another, each result feeds next
- `execProcess()`: spawns external process, optionally signals completion
- All commands return null for no-message or Msg for the event loop to enqueue
- Commands are never awaited in the event loop (fire-and-forget)
- Unit tests: tick fires once, every fires multiple times, batch fires all
