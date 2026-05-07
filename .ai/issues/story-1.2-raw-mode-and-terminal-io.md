# Story 1.2: Raw Mode & Terminal I/O

**Feature:** Terminal Foundation
**Estimate:** M
**Depends on:** None (standalone)

## Description

Implement raw terminal mode setup (disabling echo, canonical mode, signal generation, etc.) and terminal lifecycle management. Two implementations: a dart:io fallback and a proper FFI-to-libc approach for Unix.

## Tasks

| # | Task | Est. |
|---|------|------|
| 1.2.1 | Raw mode via dart:io (echoMode, lineMode fallback) | S |
| 1.2.2 | Raw mode via FFI to libc (tcgetattr/tcsetattr) | M |
| 1.2.3 | Terminal lifecycle runner (enter/restore) | M |

## Acceptance Criteria

- Raw mode disables ECHO, ICANON, ISIG, IEXTEN
- VMIN=1, VTIME=0 (blocking reads) are set
- Terminal state is always restored on crash or normal exit
- dart:io path works everywhere; FFI path provides full control on Unix
- Tests verify the tcgetattr/tcsetattr calls (integration test on Unix)
