# Story 3.1: TEA Event Loop (Program)

**Feature:** Application Architecture
**Estimate:** XL
**Depends on:** Parser Events (1.4), Diff Engine (2.4)

## Description

Implement the core Elm Architecture event loop — the Program. Drains all pending messages before each render, fires commands asynchronously, and throttles rendering to a configurable FPS.

## Tasks

| # | Task | Est. |
|---|------|------|
| 3.1.1 | Model abstract class | S |
| 3.1.2 | Msg base class and system messages | M |
| 3.1.3 | Cmd type and built-in commands | M |
| 3.1.4 | Program event loop | XL |

## Acceptance Criteria

- Event loop: drain queue → update model → render → wait for input → repeat
- All messages processed before any render (no partial-frame renders)
- Commands are fire-and-forget (unawaited futures) that enqueue results as Msg
- FPS throttle only caps screen output, not message processing
- ESC disambiguation timer (10ms) for standalone ESC vs escape sequence
- System messages handled: Quit, Interrupt, Suspend, Resume, WindowSize
- Clean shutdown on QuitMsg
