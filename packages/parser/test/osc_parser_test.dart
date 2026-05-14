import 'package:test/test.dart';
import 'package:parser/terminal_parser.dart';

void main() {
  late OscParser parser;

  setUp(() {
    parser = OscParser();
  });

  test('terminal title', () {
    final event = parser.parse(SequenceData.osc('0;Hello World'));
    expect(event, isA<InternalEvent>());
    expect((event as InternalEvent).kind, equals('title_changed'));
    expect(event.data!['title'], equals('Hello World'));
  });

  test('foreground color query response', () {
    final event = parser.parse(SequenceData.osc('10;rgb:ff00/8000/4000'));
    expect(event, isA<ColorQueryEvent>());
    final colorEvent = event as ColorQueryEvent;
    expect(colorEvent.colorNumber, equals(10));
    expect(colorEvent.r, equals(0xFF));
    expect(colorEvent.g, equals(0x80));
    expect(colorEvent.b, equals(0x40));
  });

  test('background color query response', () {
    final event = parser.parse(SequenceData.osc('11;rgb:0000/0000/0000'));
    expect(event, isA<ColorQueryEvent>());
    final colorEvent = event as ColorQueryEvent;
    expect(colorEvent.colorNumber, equals(11));
    expect(colorEvent.r, equals(0x00));
    expect(colorEvent.g, equals(0x00));
    expect(colorEvent.b, equals(0x00));
  });

  test('hyperlink', () {
    final event = parser.parse(SequenceData.osc('8;;https://dart.dev'));
    expect(event, isA<InternalEvent>());
    expect((event as InternalEvent).kind, equals('hyperlink'));
    expect(event.data!['uri'], equals('https://dart.dev'));
  });

  test('clipboard', () {
    final event = parser.parse(SequenceData.osc('52;c;SGVsbG8='));
    expect(event, isA<ClipboardEvent>());
    expect((event as ClipboardEvent).clipboard, equals('c'));
    expect(event.base64, equals('SGVsbG8='));
  });

  test('unknown OSC command returns null', () {
    final event = parser.parse(SequenceData.osc('99;unknown'));
    expect(event, isNull);
  });

  test('malformed content without semicolon returns null', () {
    final event = parser.parse(SequenceData.osc('notvalid'));
    expect(event, isNull);
  });
}
