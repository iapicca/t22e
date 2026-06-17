# capability

Terminal capability probing.

## Purpose

Discovers terminal features at startup through a sequential probing pipeline.
Drives rendering quality and input handling decisions.

## Exports

- **Da1Query** — sealed class: `Da1QuerySupported` or `Da1QueryUnsupported`
- **Da1Value** — parsed DA1 response with terminal ID and attributes
- **Capabilities** — complete record: DA1, color profile, sync support,
  keyboard protocol, terminal dimensions
- **Probe functions**: `probeDa1()`, `probeColor()`, `probeSync()`,
  `probeKeyboard()`
- **Detection functions**: `detectColorFromEnv()`, `detectColorFromDa1()`
- **TerminalProbeExtension** — generic probe helper with timeout
- **Riverpod providers** — individual probes and aggregated capabilities

## Usage

Read `capabilitiesProvider` to get all detected features. Use individual probe
providers for targeted queries. Probes run sequentially at startup.
