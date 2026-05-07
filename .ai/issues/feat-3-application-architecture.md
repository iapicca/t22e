# Feature: Application Architecture (TEA)

**Phase:** 3
**Priority:** P0 - Must have
**Depends on:** Feature 2 (rendering can be integrated after)

## Description

Implement the Elm Architecture (TEA) application framework: the event loop (Program), Model/Msg/Cmd types, terminal capability probing, lifecycle management, and signal handling. This is the runtime that wires everything together.

## Stories

| # | Story | Est. |
|---|-------|------|
| 3.1 | TEA Event Loop (Program) | XL |
| 3.2 | Terminal Capability Detection | L |
| 3.3 | Lifecycle & Signal Handling | M |

## Acceptance Criteria

- Program event loop drains all pending messages before rendering
- Model is immutable — update() returns new Model with optional Cmd
- View() returns a declarative widget tree or rendering instructions
- Commands are fire-and-forget side effects that enqueue results as messages
- Terminal capability probing detects color depth, sync support, keyboard protocol, etc.
- Terminal state is always restored on exit, crash, or signal
- Alt screen, cursor hide, and raw mode are managed automatically
