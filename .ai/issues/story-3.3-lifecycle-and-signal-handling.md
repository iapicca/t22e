# Story 3.3: Lifecycle & Signal Handling

**Feature:** Application Architecture
**Estimate:** M
**Depends on:** Raw Mode (1.2)

## Description

Implement robust lifecycle management: terminal state auto-restore on crash/exit, signal handling (SIGINT, SIGTERM, SIGTSTP), and alternate screen buffer management.

## Tasks

| # | Task | Est. |
|---|------|------|
| 3.3.1 | Terminal auto-restore on crash | M |
| 3.3.2 | Signal handling (SIGINT/SIGTERM/SIGTSTP) | M |
| 3.3.3 | Alternate screen mode management | S |

## Acceptance Criteria

- Terminal raw mode is always restored on: normal exit, exception, signal
- SIGINT (Ctrl+C): send interrupt to application, don't kill; if unhandled, quit cleanly
- SIGTERM: clean shutdown, restore terminal, exit
- SIGTSTP (Ctrl+Z): restore terminal, suspend, re-enter raw mode on resume
- Alt screen buffer is entered on start, exited on shutdown
- Multiple signal registrations don't cause double-restore
- Works on Linux and macOS
