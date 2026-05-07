const esc = '\x1b';
const csi = '\x1b[';
const osc = '\x1b]';
const dcs = '\x1bP';
const st = '\x1b\\';
const bel = '\x07';

String bold(bool on) => on ? '\x1b[1m' : '\x1b[22m';
String dim(bool on) => on ? '\x1b[2m' : '\x1b[22m';
String italic(bool on) => on ? '\x1b[3m' : '\x1b[23m';
String underline(bool on) => on ? '\x1b[4m' : '\x1b[24m';
String blink(bool on) => on ? '\x1b[5m' : '\x1b[25m';
String reverse(bool on) => on ? '\x1b[7m' : '\x1b[27m';
String strikethrough(bool on) => on ? '\x1b[9m' : '\x1b[29m';
String overLine(bool on) => on ? '\x1b[53m' : '\x1b[55m';
String resetAll() => '\x1b[0m';
