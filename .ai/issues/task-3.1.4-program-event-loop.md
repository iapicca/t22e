# Task 3.1.4: Program Event Loop

**Story:** TEA Event Loop
**Estimate:** XL

## Description

Implement the main Program event loop. This is the heart of the TEA architecture: it owns the message queue, handles input reading, manages the update → view → render cycle, and controls the FPS throttle.

## Implementation

```dart
class Program<M extends Model<M>> {
  M model;
  bool running = true;
  final msgQueue = Queue<Msg>();
  final FpsThrottle fpsThrottle;

  void run() {
    // 1. Enter raw mode, alt screen, hide cursor
    // 2. Start input reading (isolate/stream)
    // 3. Event loop:
    //    while (running):
    //      while (queue.isNotEmpty && running):
    //        model, cmd = model.update(msg)
    //        if cmd: fire(cmd)
    //        fpsThrottle.tick()
    //      if (needs_render && running):
    //        view = model.view()
    //        render()
    //      wait() with fps-throttled delay
    // 4. On exit: restore terminal, leave alt screen, show cursor
  }

  void fire(Cmd cmd) {
    // fire-and-forget: cmd().then((msg) => enqueue(msg))
  }
}
```

## Acceptance Criteria

- All pending messages drain before any render cycle
- FPS throttle: default 60fps (16ms between renders), configurable
- Input is read from stdin in background (via isolate or event loop integration)
- Commands execute concurrently and enqueue results back to the main loop
- ESC disambiguation: wait 10ms after ESC byte before deciding it's standalone
- Window resize detection via SIGWINCH or periodic polling
- Clean shutdown: quit message, signal, or exception all trigger proper restore
- Performance: can handle 1000 msg/s without falling behind
