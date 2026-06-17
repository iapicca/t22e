/// VT500 state machine states for byte-level parsing.
enum VtState {
  ground,
  escape,
  escapeIntermediate,
  csiEntry,
  csiParam,
  csiIntermediate,
  csiIgnore,
  oscString,
  dcsEntry,
  dcsParam,
  dcsIntermediate,
  dcsIgnore,
  dcsPassthrough,
}
