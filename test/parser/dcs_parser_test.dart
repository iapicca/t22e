import 'package:test/test.dart';
import 'package:t22e/src/parser/dcs_parser.dart';
import 'package:t22e/src/parser/engine.dart';
import 'package:t22e/src/parser/events.dart';

void main() {
  late DcsParser parser;

  setUp(() {
    parser = DcsParser();
  });

  test('kitty graphics protocol', () {
    final event = parser.parse(DcsSequenceData([], [0x2B], 0x70, 'some data'));
    expect(event, isA<InternalEvent>());
    expect((event as InternalEvent).kind, equals('kitty_graphics'));
  });

  test('unknown DCS returns null', () {
    final event = parser.parse(DcsSequenceData([], [], 0x50));
    expect(event, isNull);
  });
}
